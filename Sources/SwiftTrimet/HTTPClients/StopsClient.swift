import Alamofire
import SwiftyJSON
import Foundation

public class StopsClient: TrimetClient, TrimetStopClient {
    internal var sessionManager: Alamofire.Session
    internal var queryParams: StopQueryParameters
    public var onSuccess: ((JSON?) -> Void)?
    public var onFailure: ((Int?, String?) -> Void)?
    
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: StopQueryParameters) {
        self.sessionManager = session
        self.queryParams = parameters
    }
    
    func setQueryParameters(_ params: StopQueryParameters) {
        self.queryParams = params
    }
    
    public func fetch() {
        guard let urlString = ServiceLocator.stops().string else { return }
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        guard let url = URL(string: encoded) else { return }
                
        
        sessionManager.request(url, parameters: queryParams).responseString { response in
            self.handleResponse(response)
        }
    }
}
