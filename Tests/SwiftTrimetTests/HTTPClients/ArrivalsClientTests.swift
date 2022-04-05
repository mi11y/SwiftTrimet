
import XCTest
import Foundation
import SwiftyJSON
import SwiftHelpers

@testable import SwiftTrimet

class ArrivalsClientTests: XCTestCase {
    
    func testConformsToHTTPClient() {
        let expectation = self.expectation(description: "It conforms to HTTPClient protocol")
        
        if ArrivalsClient.self is HTTPClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func testFetchArrivalsOnSuccess() {
        let mockConfiguration = MockConfiguration.init()
        mockConfiguration.setStatusCode(200)
        mockConfiguration.setDataResponse(TestData.arrivalsJSON.data)
        mockConfiguration.setAPIURL(ServiceLocator.arrivals())
        mockConfiguration.ignoreQuery = true //TODO: Remove the use of ignoreQuery for more a durable test.
        let session = mockConfiguration.mockAPIResponse()

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
        let mockConfiguration = MockConfiguration.init()
        mockConfiguration.setStatusCode(400)
        mockConfiguration.setError("Bad Request")
        mockConfiguration.setDataResponse(TestData.arrivalsJSON.data)
        mockConfiguration.setAPIURL(ServiceLocator.arrivals())
        let session = mockConfiguration.mockAPIResponse()
        
        let expectation = self.expectation(description: "onError handler called")
        let client = ArrivalsClient(
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
            "locIDs": "10764,7618"
        ]
    }
}
