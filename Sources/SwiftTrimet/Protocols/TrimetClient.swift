import Alamofire
import SwiftyJSON

protocol TrimetClient {
    var sessionManager: Alamofire.Session { get set }
    var onSuccess: ((JSON?) -> Void)? { get set }
    var onFailure: ((Int?, String?) -> Void)? { get set }
    
    func fetch() -> Void
    func handleResponse(_ response: AFDataResponse<String>) -> Void
}

extension TrimetClient {
    func handleResponse(_ response: AFDataResponse<String>) -> Void {
        switch response.result {
        case .success(let value):
            if let onSuccess = self.onSuccess {
                onSuccess(JSON(parseJSON: value))
            }
        case .failure(let error):
            debugPrint(error)
            if let onFailure = onFailure {
                onFailure(error.responseCode, error.errorDescription)
            }
        }
    }
}
