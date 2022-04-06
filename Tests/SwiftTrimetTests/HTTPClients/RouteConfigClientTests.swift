
import XCTest
import Foundation
import SwiftyJSON
import Alamofire
import SwiftHelpers

@testable import SwiftTrimet

class RouteConfigClientTests: XCTestCase {
    
    func testConformsToHTTPClient() {
        let expectation = self.expectation(description: "It conforms to HTTPClient protocol")
        
        if RouteConfigClient.self is HTTPClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchRoutesOnSuccess() {
        let mockConfiguration = MockConfiguration.init()
        mockConfiguration.setStatusCode(200)
        mockConfiguration.setDataResponse(TestData.routesJSON.data)
        mockConfiguration.setAPIURL(ServiceLocator.routeConfig())
        mockConfiguration.ignoreQuery = true //TODO: Remove the use of ignoreQuery for more a durable test.
        let session = mockConfiguration.mockAPIResponse()

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
            XCTFail("onFailure handler was not supposed to be called")
        }
        client.fetch()

        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchRoutesOnError() {
        let mockConfiguration = MockConfiguration.init()
        mockConfiguration.setStatusCode(400)
        mockConfiguration.setError("Bad Request")
        mockConfiguration.setDataResponse(TestData.routesJSON.data)
        mockConfiguration.setAPIURL(ServiceLocator.routeConfig())
        let session = mockConfiguration.mockAPIResponse()
        
        let expectation = self.expectation(description: "onError handler called")
        let client = RouteConfigClient(
            sessionManager: session,
            queryParameters: initQueryParameters())
        client.onSuccess = { (_: JSON?) -> Void in
            XCTFail("onSuccess should not have been called")
        }
        client.onFailure = { (_: Int?, _: String? ) -> Void in
            expectation.fulfill()
        }
        client.fetch()
        
        wait(for: [expectation], timeout: 2.0)
        
    }
    
    private func initQueryParameters() -> [String:String] {
        return [
            "appID": "APIKEY",
            "routes": "12,15",
            "json": "true"
        ]
    }
}
