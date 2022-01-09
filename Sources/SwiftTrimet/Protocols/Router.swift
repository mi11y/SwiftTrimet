
protocol TrimetRouteClient {
    var queryParams: RouteQueryParameters { get set }
    
    func setQueryParameters(_ params: RouteQueryParameters)
}
