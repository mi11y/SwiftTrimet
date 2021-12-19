import Alamofire
import SwiftyJSON
import Foundation

public class StopsClient {
    private let sessionManager: Alamofire.Session
    private var queryParams: StopsQueryParameters
    public var onSuccess: ((JSON?) -> Void)?
    public var onFailure: ((Int?, String?) -> Void)?
    
    
    public struct StopsQueryParameters: Encodable {
        public init() {}
        var json = "true"
        var appID = "APIKEY"
        var ll = "45.511922,-122.681772"
        var feet = "3000"
    }
    
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: StopsQueryParameters) {
        self.sessionManager = session
        self.queryParams = parameters
    }
}
