import Alamofire
import SwiftyJSON
import Foundation
import SwiftHelpers

class VehiclesClient: HTTPClient {
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: [String:String]) {
        super.init(sessionManager: session, serviceLocatorURL: ServiceLocator.vehicles())
        setQueryParameters(parameters)
    }
}
