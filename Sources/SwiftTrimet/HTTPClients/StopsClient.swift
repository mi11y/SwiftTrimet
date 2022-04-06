import Alamofire
import SwiftyJSON
import Foundation
import SwiftHelpers

public class StopsClient: HTTPClient {
    public init(sessionManager session: Alamofire.Session, queryParameters parameters: [String:String]) {
        super.init(sessionManager: session, serviceLocatorURL: ServiceLocator.stops())
        setQueryParameters(parameters)
    }
}
