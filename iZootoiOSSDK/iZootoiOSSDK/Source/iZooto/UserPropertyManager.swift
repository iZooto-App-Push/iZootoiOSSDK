//
//  UserPropertyManager.swift
//  Pods
//
//  Created by Amit Gupta on 20/05/25.
//


import Foundation
import UIKit
class UserPropertyManager {
    private static let PREF_NAME = "user_properties"
    private static let tag = "UserPropertyManager"
    private static let method_name = "sendUserPropertiesToServer"
    private static let validation_msg = "User Properties data is blank"
    private static let key_properties = "userPropertiesData"
    
    static func sendUserProperties(properties: [String: Any],bundleName:String) {
        guard !properties.isEmpty else {
            debugPrint("UserProperty: Properties are empty. Aborting.")
            return
        }
        DispatchQueue.global(qos: .background).async {
            var filteredProperties = [String: String]()
            let userDefaults = UserDefaults.standard
            
            for (rawKey, rawValue) in properties {
                let lowerKey = rawKey.lowercased()
                let lowerValue = "\(rawValue)".lowercased()
                
                let key = String(lowerKey.prefix(32))
                let newValue = String(lowerValue.prefix(64))
                let previousValue = userDefaults.string(forKey: key)
                
                if newValue != previousValue {
                    filteredProperties[key] = newValue
                }
            }
            
            if !filteredProperties.isEmpty {
                sendUserPropertiesToServer(properties: filteredProperties,bundleName: bundleName)
            } else {
                debugPrint("UserPropertyManager: Already Added -> \(properties)")
            }
        }
    }
    private static func sendUserPropertiesToServer(properties: [String: String], bundleName: String) {
        guard !properties.isEmpty else {
            Utils.handleOnceException(bundleName: bundleName,exceptionName: validation_msg,className: tag,methodName: method_name,rid: nil, cid: nil, userInfo: nil)
            return
        }

        let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
        let pid = Utils.getUserId(bundleName: bundleName) ?? ""

        var mapData: [String: String] = [
            AppConstant.iZ_KEY_PID: pid,
            "act": "add",
            "et": "userp",
            AppConstant.iZ_KEY_DEVICE_TOKEN: token
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: properties, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            mapData["val"] = jsonString
        }

        let headers: [String: String] = [AppConstant.iZ_CONTENT_TYPE: AppConstant.iZ_CONTENT_TYPE_VALUE]
        guard let url = URL(string: RestAPI.PROPERTIES_URL) else {
            debugPrint("Error: Invalid URL\(RestAPI.PROPERTIES_URL)")
            if let jsonData = try? JSONSerialization.data(withJSONObject: properties, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                UserDefaults.standard.set(jsonString, forKey: key_properties)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = AppConstant.iZ_POST_REQUEST
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "referrer")
        request.allHTTPHeaderFields = headers
        request.httpBody = mapData.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                if let jsonData = try? JSONSerialization.data(withJSONObject: properties, options: []),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    UserDefaults.standard.set(jsonString, forKey: key_properties)
                }
                Utils.handleOnceException(bundleName: bundleName,
                                    exceptionName: error.localizedDescription,
                                          className: tag,
                                          methodName: method_name,
                                          rid: nil, cid: nil, userInfo: nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                debugPrint("UserPropertyManager: Invalid response (not HTTPURLResponse)")

                if let jsonData = try? JSONSerialization.data(withJSONObject: properties, options: []),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    UserDefaults.standard.set(jsonString, forKey: key_properties)
                }

                return
            }

            if httpResponse.statusCode == 200 {
                for (key, value) in properties {
                    UserDefaults.standard.set(value, forKey: key)
                }
                UserDefaults.standard.synchronize()
                UserDefaults.standard.set("", forKey: "userPropertiesData")
                debugPrint("UserPropertyManager: Added Successfully -> \(mapData)")
            } else {
                if let jsonData = try? JSONSerialization.data(withJSONObject: properties, options: []),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    UserDefaults.standard.set(jsonString, forKey: key_properties)
                }
            }
        }.resume()
    }

}
