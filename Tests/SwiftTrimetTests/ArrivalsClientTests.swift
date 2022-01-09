
import XCTest
import Alamofire
import Foundation
import Mocker
import SwiftyJSON

@testable import SwiftTrimet

class ArrivalsClientTests: XCTestCase {
    
    func testConformsToTrimetClient() {
        let expectation = self.expectation(description: "It conforms to TrimetClient protocol")
        
        if ArrivalsClient.self is TrimetClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConformsToArrivalClient() {
        let expectation = self.expectation(description: "It conforms to TrimetArrivalClient protocol")
        
        if ArrivalsClient.self is TrimetArrivalClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchArrivalsOnSuccess() {
        let session = mockAPIResponse(MockConfigration())

        let expectation = self.expectation(description: "The correct endpoint was called")
        guard let expectedJSON = try? JSON(data: TestData.arrivalsJSON.data) else { XCTFail("Failed to parse test JSON"); return }
        
        let client = ArrivalsClient(
            sessionManager: session,
            queryParameters: initQueryParameters()
        )
        client.onSuccess = { (actualResponse: JSON?) -> Void in
            XCTAssertNotNil(actualResponse)
            XCTAssertEqual(actualResponse, expectedJSON)
            expectation.fulfill()
        }
        client.onFailure = { (_: Int?, _: String?) -> Void in
            XCTFail("onFailure handler was not supposed to be called")
        }
        client.fetch()

        wait(for: [expectation], timeout: 2.0)
        
    }
    
    
    func testFetchArrivalsOnError() {
        var mockConfig = MockConfigration()
        mockConfig.statusCode = 400
        mockConfig.payload = try! JSONEncoder().encode("Bad Request")
        mockConfig.error = TestAPIError.message("Bad Request")
        let session = mockAPIResponse(mockConfig)
        
        let expectation = self.expectation(description: "onError handler called")
        let client = ArrivalsClient(sessionManager: session, queryParameters: initQueryParameters())
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
        config.locations = ["1","2","3"]
        
        var queryParameters = initQueryParameters()
        queryParameters.locIDs = config.locIDs()
        
        let session = mockAPIResponse(config)
        
        let expectation = self.expectation(description: "The correct query parameters were used.")
        guard let expectedJSON = try? JSON(data: TestData.arrivalsJSON.data) else { return XCTFail("Failed to parse test JSON"); return }
        
        let client = ArrivalsClient(sessionManager: session, queryParameters: ArrivalQueryParameters())
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
        var payload: Data = TestData.arrivalsJSON.data
        var locations: [String] = ["10764","7618"]
        var error: TestAPIError? = nil
        
        func locIDs() -> String {
            return locations.joined(separator: ",")
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
        var urlComponenets: URLComponents = ServiceLocator.arrivals()
        urlComponenets.queryItems = [
            URLQueryItem(name: "appID", value: "APIKEY"),
            URLQueryItem(name: "locIDs", value: config.locIDs())
        ]
        return urlComponenets
    }
    
    
    private func initQueryParameters() -> ArrivalQueryParameters {
        var newParameters = ArrivalQueryParameters()
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
