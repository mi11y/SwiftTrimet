import Alamofire
import SwiftyJSON
import Foundation

class VehiclesClient: TrimetClient, TrimetVehicleClient {
    internal var sessionManager: Alamofire.Session
    internal var queryParams: VehicleQueryParameters
    public var onSuccess: ((JSON?) -> Void)?
    public var onFailure: ((Int?, String?) -> Void)?
    
    
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: VehicleQueryParameters) {
        self.sessionManager = session
        self.queryParams = parameters
    }
    
    
    func setQueryParameters(_ params: VehicleQueryParameters) {
        self.queryParams = params
    }
    
    public func fetch() {
        guard let urlString = ServiceLocator.vehicles().string else { return }
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        guard let url = URL(string: encoded) else { return }
                
        
        sessionManager.request(url, parameters: queryParams).responseString { response in
            self.handleResponse(response)
        }
    }
}
