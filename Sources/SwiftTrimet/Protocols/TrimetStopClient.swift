protocol TrimetStopClient {
    var queryParams: StopQueryParameters { get set }
    func setQueryParameters(_ params: StopQueryParameters)
}
