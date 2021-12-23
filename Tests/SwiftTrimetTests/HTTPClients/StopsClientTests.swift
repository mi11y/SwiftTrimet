import XCTest
import Alamofire
import Foundation
import Mocker
import SwiftyJSON

@testable import SwiftTrimet

class StopsClientTests: XCTestCase {
    
    func testConformsToTrimetClient() {
        let expectation = self.expectation(description: "It conforms to TrimetClient protocol")
        
        if StopsClient.self is TrimetClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConformsToStopClient() {
        let expectation = self.expectation(description: "It conforms to TrimetStopClient protocol")
        
        if StopsClient.self is TrimetStopClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchStopsOnSuccess() {
        let session = mockAPIResponse(MockConfigration())

        let expectation = self.expectation(description: "The correct endpoint was called")
        guard let expectedJSON = try? JSON(data: TestData.stopsJSON.data) else { XCTFail("Failed to parse test JSON"); return }
        
        let client = StopsClient(
            sessionManager: session,
            queryParameters: initQueryParameters()
        )
        client.onSuccess = { (actualResponse: JSON?) -> Void in
            XCTAssertNotNil(actualResponse)
            XCTAssertEqual(actualResponse, expectedJSON)
            expectation.fulfill()
        }
        client.onFailure = { (_: Int?, _: String?) -> Void in
            XCTFail("onFailuer handler was not supposed to be called")
        }
        client.fetch()

        wait(for: [expectation], timeout: 2.0)
        
    }
    
    func testFetchStopsOnError() {
        var mockConfig = MockConfigration()
        mockConfig.statusCode = 400
        mockConfig.payload = try! JSONEncoder().encode("Bad Request")
        mockConfig.error = TestAPIError.message("Bad Request")
        let session = mockAPIResponse(mockConfig)
        
        let expectation = self.expectation(description: "onError handler called")
        let client = StopsClient(sessionManager: session, queryParameters: initQueryParameters())
        client.onSuccess = { (_: JSON?) -> Void in
            XCTFail("onSuccess should not have been called")
        }
        client.onFailure = { (_: Int?, _: String? ) -> Void in
            expectation.fulfill()
        }
        client.fetch()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testSetQueryParameters() {
        var config = MockConfigration()
        config.feetRadius = "2000"
        config.longitude = "12"
        config.lattiude = "14"
        
        var queryParameters = initQueryParameters()
        queryParameters.ll = config.ll()
        queryParameters.feet = config.feetRadius
        
        let session = mockAPIResponse(config)
        
        let expectation = self.expectation(description: "The correct query parameters were used.")
        guard let expectedJSON = try? JSON(data: TestData.stopsJSON.data) else { return XCTFail("Failed to parse test JSON"); return }
        
        let client = StopsClient(sessionManager: session, queryParameters: StopQueryParameters())
        client.onSuccess = { (actualResponse: JSON?) -> Void in
            XCTAssertNotNil(actualResponse)
            XCTAssertEqual(actualResponse, expectedJSON)
            expectation.fulfill()
        }
        client.setQueryParameters(queryParameters)
        client.fetch()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // Test Helpers
    
    private enum TestAPIError: Error {
        case message(String)
    }
    
    private struct MockConfigration {
        var statusCode = 200
        var payload: Data = TestData.stopsJSON.data
        var lattiude = "45.511922"
        var longitude = "-122.681772"
        var feetRadius = "3000"
        var error: TestAPIError? = nil
        
        func ll() -> String {
            return lattiude + "," + longitude
        }
    }

    
    private func mockAPIResponse(_ config: MockConfigration) -> Session {
        
        let urlComponents = createURLComponents(config)
        mockSessionWithComponents(config, urlComponents)
        
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        return Alamofire.Session(configuration: configuration)
    }
    
    private func mockSessionWithComponents(_ config: MockConfigration, _ urlComponenets: URLComponents) {
        let apiEndpoint = createURLFromComponents(urlComponenets)
        
        if let error = config.error {
            Mock(
                url: apiEndpoint,
                ignoreQuery: false,
                dataType: .json,
                statusCode: config.statusCode,
                data: [
                    .get: config.payload
                ],
                requestError: error
            ).register()
        } else {
            Mock(
                url: apiEndpoint,
                ignoreQuery: false,
                dataType: .json,
                statusCode: config.statusCode,
                data: [
                    .get: config.payload
                ]
            ).register()
        }

    }
    
    private func createURLComponents(_ config: MockConfigration) -> URLComponents {
        var urlComponenets: URLComponents = ServiceLocator.stops()
        urlComponenets.queryItems = [
            URLQueryItem(name: "appID", value: "APIKEY"),
            URLQueryItem(name: "feet", value: config.feetRadius),
            URLQueryItem(name: "json", value: "true"),
            URLQueryItem(name: "ll", value: config.ll())
        ]
        return urlComponenets
    }
    
    private func initQueryParameters() -> StopQueryParameters {
        var newParameters = StopQueryParameters()
        newParameters.appID = "APIKEY"
        return newParameters
    }
    
    private func createURLFromComponents(_ components: URLComponents) -> URL {
        let characterSet = NSCharacterSet(charactersIn: ",").inverted
        return URL(
            string: components.string!.addingPercentEncoding(
                withAllowedCharacters: characterSet
            )!
        )!
    }
    
    private func initAlamofireSessionManager() -> Session {
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        return Alamofire.Session(configuration: configuration)
    }
}
