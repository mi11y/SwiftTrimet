import Alamofire
import SwiftyJSON
import Foundation

class ArrivalsClient: TrimetClient, TrimetArrivalClient {
    var sessionManager: Session
    var queryParams: ArrivalQueryParameters
    public var onSuccess: ((JSON?) -> Void)?
    public var onFailure: ((Int?, String?) -> Void)?

    public init(sessionManager session: Alamofire.Session, queryParameters parameters: ArrivalQueryParameters) {
        self.sessionManager = session
        self.queryParams = parameters
    }
    
    func setQueryParameters(_ params: ArrivalQueryParameters) {
        self.queryParams = params
    }
    
    func fetch() {
        guard let urlString = ServiceLocator.arrivals().string else { return }
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        guard let url = URL(string: encoded) else { return }
                
        
        sessionManager.request(url, parameters: queryParams).responseString { response in
            self.handleResponse(response)
        }
    }
}
