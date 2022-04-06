
import XCTest
import Foundation
import SwiftyJSON
import SwiftHelpers

@testable import SwiftTrimet

class VehiclesClientTests: XCTestCase {
    
    func testConformsToTrimetClient() {
        let expectation = self.expectation(description: "It conforms to HTTPClient protocol")
        
        if VehiclesClient.self is HTTPClient.Type {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchVehiclesOnSuccess() {
        let mockConfiguration = MockConfiguration.init()
        mockConfiguration.setStatusCode(200)
        mockConfiguration.setDataResponse(TestData.vehiclesJSON.data)
        mockConfiguration.setAPIURL(ServiceLocator.vehicles())
        mockConfiguration.ignoreQuery = true //TODO: Remove the use of ignoreQuery for more a durable test.
        let session = mockConfiguration.mockAPIResponse()

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
            XCTFail("onFailure handler was not supposed to be called")
        }
        client.fetch()

        wait(for: [expectation], timeout: 2.0)
        
    }
    
    func testFetchVehiclesOnError() {
        let mockConfiguration = MockConfiguration.init()
        mockConfiguration.setStatusCode(400)
        mockConfiguration.setError("Bad Request")
        mockConfiguration.setDataResponse(TestData.vehiclesJSON.data)
        mockConfiguration.setAPIURL(ServiceLocator.vehicles())
        let session = mockConfiguration.mockAPIResponse()
        
        let expectation = self.expectation(description: "onError handler called")
        let client = VehiclesClient(
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
            "routes": "20,15"
        ]
    }
}
