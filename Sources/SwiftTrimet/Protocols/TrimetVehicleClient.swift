protocol TrimetVehicleClient {
    var queryParams: VehicleQueryParameters { get set }
    func setQueryParameters(_ params: VehicleQueryParameters)
}
