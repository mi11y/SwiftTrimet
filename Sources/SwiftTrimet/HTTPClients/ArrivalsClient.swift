import Alamofire
import SwiftyJSON
import Foundation
import SwiftHelpers

class ArrivalsClient: HTTPClient {
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: [String:String]) {
        super.init(sessionManager: session, serviceLocatorURL: ServiceLocator.arrivals())
        setQueryParameters(parameters)
    }
}
