protocol TrimetArrivalClient {
    var queryParams: ArrivalQueryParameters { get set }
    func setQueryParameters(_ params: ArrivalQueryParameters)
}
