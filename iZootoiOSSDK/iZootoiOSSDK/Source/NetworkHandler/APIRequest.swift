//
//  APIRequest.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 08/05/25.
//


import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

enum ContentType: String {
    case json = "application/json"
    case formURLEncoded = "application/x-www-form-urlencoded"
}

struct APIRequest {
    let url: URL
    let method: HTTPMethod
    let contentType: ContentType
    let headers: [String: String]
    let body: Data?

    init(
        url: URL,
        method: HTTPMethod,
        contentType: ContentType = .json,
        body: Any? = nil,
        additionalHeaders: [String: String] = [:]
    ) {
        self.url = url
        self.method = method
        self.contentType = contentType

        // Set default headers
        var defaultHeaders: [String: String] = [
            "Content-Type": contentType.rawValue,
            "Accept": "application/json"
        ]

        // Add Referer if available
        if let bundleID = Bundle.main.bundleIdentifier {
            defaultHeaders["Referer"] = bundleID
        }

//         Merge custom headers
        self.headers = defaultHeaders.merging(additionalHeaders) { _, new in new }

        // Encode body
        if let body = body {
            switch contentType {
            case .json:
                do {
                    if let dict = body as? [String: Any] {
                        self.body = try JSONSerialization.data(withJSONObject: dict)
                    } else if let nsDict = body as? NSDictionary {
                        self.body = try JSONSerialization.data(withJSONObject: nsDict)
                    } else if let data = body as? Data {
                        self.body = data
                    } else {
                        self.body = nil
                    }
                } catch {
                    debugPrint("JSON serialization failed: \(error.localizedDescription)")
                    self.body = nil
                }
            case .formURLEncoded:
                if let dict = body as? [String: Any] ?? (body as? NSDictionary as? [String: Any]) {
                    let formString = dict.map {
                        "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                    }.joined(separator: "&")
                    self.body = formString.data(using: .utf8)
                } else if let data = body as? Data {
                    self.body = data
                } else {
                    self.body = nil
                }
            }
        } else {
            self.body = nil
        }
    }

    var asURLRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        // Skip body for GET
        guard method != .GET else { return request }

        // Handle pid/token injection only for formURLEncoded
        if contentType == .formURLEncoded,
           var bodyString = body.flatMap({ String(data: $0, encoding: .utf8) }) {

            if let pid = AppStorage.shared.getString(forKey: AppConstant.REGISTERED_ID),
               let token = AppStorage.shared.getString(forKey: AppConstant.IZ_DEVICE_TOKEN) {
                let injected = "pid=\(pid)&token=\(token)"
                bodyString += "&" + injected
            }

            request.httpBody = bodyString.data(using: .utf8)
        } else {
            request.httpBody = body
            
            // for log purpose
            let data = request.httpBody ?? Data()
            if let bodyString = String(data: data, encoding: .utf8) {
//                print("HTTP Body: \(bodyString)")
            } 
        }
        return request
    }
}
