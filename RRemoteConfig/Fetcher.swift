internal class Fetcher {
    let apiClient: APIClient
    let environment: Environment

    init(client: APIClient,
         environment: Environment) {
        self.apiClient = client
        self.environment = environment
    }

    func fetchConfig(completionHandler: @escaping (ConfigModel?) -> Void) {
        guard let url = environment.configUrl else {
            return completionHandler(nil)
        }
        var request = URLRequest(url: url)
        request.addValue("ras-\(environment.subscriptionKey)", forHTTPHeaderField: "apiKey")
        apiClient.send(request: request, decodeAs: ConfigModel.self) { (result, response) in
            switch result {
            case .success(let resultConfig):
                var config = resultConfig as? ConfigModel
                config?.signature = response?.allHeaderFields["Signature"] as? String
                completionHandler(config)
            case .failure(let error):
                print("Error: ", error)
                completionHandler(nil)
            }
        }
    }

    func fetchKey(with keyId: String, completionHandler: @escaping (KeyModel?) -> Void) {
        guard let url = environment.keyUrl(with: keyId) else {
            return completionHandler(nil)
        }
        var request = URLRequest(url: url)
        request.addValue("ras-\(environment.subscriptionKey)", forHTTPHeaderField: "apiKey")
        apiClient.send(request: request, decodeAs: KeyModel.self) { (result, _) in
            switch result {
            case .success(let keyModel):
                completionHandler(keyModel as? KeyModel)
            case .failure(let error):
                print("Error: ", error)
                completionHandler(nil)
            }
        }
    }
}

internal struct KeyModel: Decodable {
    let id: String
    let key: String
    let createdAt: String
}