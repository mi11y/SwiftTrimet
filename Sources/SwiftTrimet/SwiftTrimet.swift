import Alamofire
import SwiftyJSON
import Foundation

public class SwiftTrimet {
    private let TRIMET_API_URL = "http://developer.trimet.org/ws/v1/routeConfig"
    private var latestResponse: JSON? = nil
    private let sessionManager: Alamofire.Session
    private let queryParams: RoutesQueryParameters
    
    public struct RoutesQueryParameters: Encodable {
        public init() {}
        var json = "true"
        var routes = "12,15"
        var appID = ProcessInfo.processInfo.environment["TRIMET_API_KEY"]!
    }
    
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: RoutesQueryParameters) {
        self.sessionManager = session
        self.queryParams = parameters
    }
    
    public func fetchRoutes() -> JSON? {
        if let encoded = TRIMET_API_URL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let url = URL(string: encoded) {
            let request = sessionManager.request(url, parameters: queryParams)
            request.responseString { response in
                self.latestResponse = self.handleResponse(response)
            }
        }
        return self.latestResponse
    }
    
    public func lastResponse() -> JSON? {
        return self.latestResponse
    }
    
    private func handleResponse(_ response: AFDataResponse<String>) -> JSON? {
        var parsedJSON: JSON? = nil
        switch response.result {
        case .success(let value):
            debugPrint(value)
            parsedJSON = try! JSON(parseJSON: value)
            debugPrint(parsedJSON!["resultSet"])
        case .failure(let error):
            debugPrint("[TrimetRoutes] ERROR: \(error)")
            debugPrint(error.errorDescription ?? "[TrimetRoutes] No additional information.")
        }
        return parsedJSON
    }
}
