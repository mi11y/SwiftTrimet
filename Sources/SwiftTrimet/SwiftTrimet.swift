import Alamofire
import SwiftyJSON
import Foundation

public struct SwiftTrimet {
    
    public let routeConfigClient: RouteConfigClient
    
    public init(AlamoFireSessionManager manager: Session?) {
        
        let sessionManager = manager ?? Alamofire.Session()
        
        self.routeConfigClient = RouteConfigClient(
            sessionManager: sessionManager,
            queryParameters: RouteConfigClient.RoutesQueryParameters()
        )
    }
    
}
