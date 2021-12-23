
import XCTest
import Alamofire
import Foundation
import Mocker
import SwiftyJSON

@testable import SwiftTrimet

class VehiclesClientTests: XCTestCase {
    
    func testConformsToTrimetClient() {
        let expectation = self.expectation(description: "It conforms to TrimetClient protocol")
        
        if VehiclesClient.self is TrimetClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConformsToVehicleClient() {
        let expectation = self.expectation(description: "It conforms to TrimetVehicleClient protocol")
        
        if VehiclesClient.self is TrimetVehicleClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchVehiclesOnSuccess() {
        let session = mockAPIResponse(MockConfigration())

        let expectation = self.expectation(description: "The correct endpoint was called")
        guard let expectedJSON = try? JSON(data: TestData.vehiclesJSON.data) else { XCTFail("Failed to parse test JSON"); return }
        
        let client = VehiclesClient(
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
    
    func testFetchVehiclesOnError() {
        var mockConfig = MockConfigration()
        mockConfig.statusCode = 400
        mockConfig.payload = try! JSONEncoder().encode("Bad Request")
        mockConfig.error = TestAPIError.message("Bad Request")
        let session = mockAPIResponse(mockConfig)
        
        let expectation = self.expectation(description: "onError handler called")
        let client = VehiclesClient(sessionManager: session, queryParameters: initQueryParameters())
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
        config.routes = "63"
        
        var queryParameters = initQueryParameters()
        queryParameters.routes = "63"
        
        let session = mockAPIResponse(config)
        
        let expectation = self.expectation(description: "The correct query parameters were used.")
        guard let expectedJSON = try? JSON(data: TestData.vehiclesJSON.data) else { return XCTFail("Failed to parse test JSON"); return }
        
        let client = VehiclesClient(sessionManager: session, queryParameters: VehicleQueryParameters())
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
        var payload: Data = TestData.vehiclesJSON.data
        var routes = "20,15"
        var error: TestAPIError? = nil
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
        var urlComponenets: URLComponents = ServiceLocator.vehicles()
        urlComponenets.queryItems = [
            URLQueryItem(name: "appID", value: "APIKEY"),
            URLQueryItem(name: "routes", value: config.routes)
        ]
        return urlComponenets
    }
    
    private func initQueryParameters() -> VehicleQueryParameters {
        var newParameters = VehicleQueryParameters()
        newParameters.appID = "APIKEY"
        newParameters.routes = "20,15"
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
