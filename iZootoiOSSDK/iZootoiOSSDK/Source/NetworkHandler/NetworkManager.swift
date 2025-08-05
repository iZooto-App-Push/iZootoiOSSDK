//
//  NetworkManager.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 08/05/25.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func sendRequest(_ request: APIRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let urlRequest = request.asURLRequest
        let session = URLSession(configuration: .default)
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Invalid response from server"
                ])))
                return
            }

            if httpResponse.statusCode == 200 {
                completion(.success(data ?? Data()))
            } else {
                let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                let apiError = NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: message
                ])
                completion(.failure(apiError))
            }
        }.resume()
    }
}

