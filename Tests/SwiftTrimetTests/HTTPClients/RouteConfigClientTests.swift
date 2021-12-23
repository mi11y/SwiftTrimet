import XCTest
import Alamofire
import Foundation
import Mocker
import SwiftyJSON

@testable import SwiftTrimet

class RouteConfigClientTests: XCTestCase {
    
    func testConformsToTrimetClient() {
        let expectation = self.expectation(description: "It conforms to TrimetClient protocol")
        
        if RouteConfigClient.self is TrimetClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testConformsToRouter() {
        let expectation = self.expectation(description: "It conforms to Router protocol")
        
        if RouteConfigClient.self is TrimetRouteClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchRoutesOnSuccess() {
        let session = mockAPIResponse(MockConfigration())

        let expectation = self.expectation(description: "The correct endpoint was called")
        guard let expectedJSON = try? JSON(data: TestData.routesJSON.data) else { XCTFail("Failed to parse test JSON"); return }
        
        let client = RouteConfigClient(
            sessionManager: session,
            queryParameters: initQueryParameters()
        )
        client.onSuccess = { (actualResponse: JSON?) -> Void in
            XCTAssertNotNil(actualResponse)
            XCTAssertEqual(actualResponse, expectedJSON)
            expectation.fulfill()
        }
        client.onFailure = { (_: Int?, _: String?) -> Void in
            XCTFail()
        }
        client.fetch()

        wait(for: [expectation], timeout: 2.0)
        
    }
    
    func testFetchRoutesOnError() {
        var mockConfig = MockConfigration()
        mockConfig.statusCode = 400
        mockConfig.payload = try! JSONEncoder().encode("Bad Request")
        mockConfig.error = TestAPIError.message("Bad Request")
        let session = mockAPIResponse(mockConfig)

        
        let expectation = self.expectation(description: "onError handler called")
        let client = RouteConfigClient(
            sessionManager: session,
            queryParameters: initQueryParameters()
        )
        client.onSuccess = { (_: JSON?) -> Void in
            XCTFail()
        }
        client.onFailure = { (_: Int?, _: String? ) -> Void in
            expectation.fulfill()
        }
        client.fetch()

        wait(for: [expectation], timeout: 2.0)
        
    }
    
    
    func testSetQueryParameters() {
        var config = MockConfigration()
        config.routeNumbers = "44,128"
        
        var queryParams = initQueryParameters()
        queryParams.routes = config.routeNumbers
        
        let session = mockAPIResponse(config)

        let expectation = self.expectation(description: "The correct query parameters were used.")
        guard let expectedJSON = try? JSON(data: TestData.routesJSON.data) else {
            XCTFail("Failed to parse test JSON"); return
        }
        
        let client = RouteConfigClient(
            sessionManager: session,
            queryParameters: RouteQueryParameters()
        )
        client.onSuccess = { (actualResponse: JSON?) -> Void in
            XCTAssertNotNil(actualResponse)
            XCTAssertEqual(actualResponse, expectedJSON)
            expectation.fulfill()
        }
        client.setQueryParameters(queryParams)
        client.fetch()

        wait(for: [expectation], timeout: 2.0)
    }
    
    // Test Helpers
    
    private enum TestAPIError: Error {
        case message(String)
    }
    
    private struct MockConfigration {
        var statusCode = 200
        var payload: Data = TestData.routesJSON.data
        var routeNumbers = "12,15"
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
        var urlComponenets: URLComponents = ServiceLocator.routeConfig()
        urlComponenets.queryItems = [
            URLQueryItem(name: "appID", value: "foo"),
            URLQueryItem(name: "json", value: "true"),
            URLQueryItem(name: "routes", value: config.routeNumbers)
        ]
        return urlComponenets
    }
    
    private func initQueryParameters() -> RouteQueryParameters {
        var newParameters = RouteQueryParameters()
        newParameters.appID = "foo"
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
