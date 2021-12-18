import XCTest
import Alamofire
import Foundation
import Mocker

@testable import SwiftTrimet

final class SwiftTrimetTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        var components = URLComponents()
        components.scheme = "http"
        components.host = "developer.trimet.org"
        components.path = "/ws/v1/routeConfig"
        components.queryItems = [
            URLQueryItem(name: "appID", value: "foo"),
            URLQueryItem(name: "json", value: "true"),
            URLQueryItem(name: "routes", value: "12,15")
        ]
        
        let characterSet = NSCharacterSet(charactersIn: ",").inverted
        let apiEndpoint = URL(string: components.string!.addingPercentEncoding(withAllowedCharacters: characterSet)!)!
        
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let sessionManager = Alamofire.Session(configuration: configuration)


        let expectation = self.expectation(description: "Data request should succeed")
        Mock(url: apiEndpoint, ignoreQuery: true, dataType: .json, statusCode: 200, data: [
           .get: TestData.exampleJSON.data
        ]
        ).register()

        
        sessionManager
            .request(apiEndpoint)
            .responseString { response in
                switch response.result {
                case .success(let value):
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail()
                }
            }.resume()
        
        _ = SwiftTrimet(sessionManager: sessionManager, queryParameters: SwiftTrimet.RoutesQueryParameters()).fetchRoutes()

        wait(for: [expectation], timeout: 10.0)
    }
}
