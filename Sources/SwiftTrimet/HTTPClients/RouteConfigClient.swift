import Alamofire
import Foundation
import SwiftHelpers

public class RouteConfigClient: HTTPClient {
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: [String:String]) {
        super.init(sessionManager: session, serviceLocatorURL: ServiceLocator.routeConfig())
        setQueryParameters(parameters)
    }
}
