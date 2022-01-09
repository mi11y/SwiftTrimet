import Alamofire
import SwiftyJSON
import Foundation

public class RouteConfigClient: TrimetClient, TrimetRouteClient {
    internal var sessionManager: Alamofire.Session
    internal var queryParams: RouteQueryParameters
    public var onSuccess: ((JSON?) -> Void)?
    public var onFailure: ((Int?, String?) -> Void)?
    
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: RouteQueryParameters) {
        self.sessionManager = session
        self.queryParams = parameters
    }
    
    func setQueryParameters(_ params: RouteQueryParameters) {
        self.queryParams = params
    }

    public func fetch() {
        guard let urlString = ServiceLocator.routeConfig().string else { return }
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        guard let url = URL(string: encoded) else { return }
                
        
        sessionManager.request(url, parameters: queryParams).responseString { response in
            self.handleResponse(response)
        }
    }
}
