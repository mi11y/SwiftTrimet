import Alamofire
import SwiftyJSON
import Foundation

public class RouteConfigClient {
    private let sessionManager: Alamofire.Session
    private var queryParams: RoutesQueryParameters
    public var onSuccess: ((JSON?) -> Void)?
    public var onFailure: ((Int?, String?) -> Void)?
    
    public struct RoutesQueryParameters: Encodable {
        public init() {}
        var json = "true"
        var routes = "12,15"
        var appID = "APIKEY"
    }
    
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: RoutesQueryParameters) {
        self.sessionManager = session
        self.queryParams = parameters
    }
    
    public func setQueryParameters(_ params: RoutesQueryParameters) {
        self.queryParams = params
    }
    
    public func fetchRoutes() {
        guard let urlString = ServiceLocator.routeConfig().string else { return }
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        guard let url = URL(string: encoded) else { return }
                
        
        sessionManager.request(url, parameters: queryParams).responseString { response in
            self.handleResponse(response)
        }
    }

    private func handleResponse(_ response: AFDataResponse<String>) -> Void {
        switch response.result {
        case .success(let value):
            if let onSuccess = self.onSuccess {
                onSuccess(JSON(parseJSON: value))
            }
        case .failure(let error):
            debugPrint(error)
            if let onFailure = onFailure {
                onFailure(error.responseCode, error.errorDescription)
            }
        }
    }
}
