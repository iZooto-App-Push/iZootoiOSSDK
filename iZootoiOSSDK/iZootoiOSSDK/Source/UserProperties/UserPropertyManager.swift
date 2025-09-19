//
//  UserPropertyManager.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 09/05/25.
//

import Foundation

final class UserPropertyManager {
    
    static let shared = UserPropertyManager()
    private init() {}
    
    @objc public func addUserProperties(data: [String: Any]) {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: AppConstant.BUNDLE_IDENTIFIER) as? String ?? ""
        AppStorage.shared.configureAppGroup(Utils.getGroupName(bundleName: bundleName) ?? "")

        let validatedData = Utils.dataValidate(data: data)
        let cleanedData = validatedData.reduce(into: [String: Any]()) { result, item in
            let trimmedKey = item.key.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !trimmedKey.isEmpty else {
                debugPrint("Invalid user property key: empty or whitespace")
                return
            }
            if let stringValue = item.value as? String {
                let trimmedValue = stringValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                guard !trimmedValue.isEmpty else {
                    debugPrint("Invalid user property value for key '\(trimmedKey)': empty or whitespace")
                    return
                }
                result[trimmedKey] = trimmedValue
            } else {
                result[trimmedKey] = item.value
            }
        }

        guard !cleanedData.isEmpty else {
            debugPrint("No valid data found in userProperties dictionary: \(data)")
            return
        }

        guard let currentJSONString = cleanedData.toSortedJSONString() else {
            print("Failed to serialize current user properties.")
            return
        }

        if let previousJSONString = AppStorage.shared.getString(forKey: "SuccessUserData"),
           previousJSONString == currentJSONString {
            print("User Property already sent.")
            return
        }

        guard let token = AppStorage.shared.getString(forKey: AppConstant.IZ_DEVICE_TOKEN),
              let pid = AppStorage.shared.getString(forKey: AppConstant.REGISTERED_ID) else {
            AppStorage.shared.setAnyValue(cleanedData, forKey: AppConstant.iZ_USERPROPERTIES_KEY)
            return
        }

        UserPropertyManager.shared.callUserProperties(bundleName: bundleName, data: currentJSONString, pid: pid, token: token)
    }
    
    func callUserProperties(bundleName: String, data: String, pid: String, token: String) {
        guard !data.isEqual(""), !pid.isEmpty else {
            return
        }
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
//            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
//            URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
            URLQueryItem(name: "act", value: "add"),
            URLQueryItem(name: "et", value: "userp"),
            URLQueryItem(name: "val", value: "\(data)")
        ]
        let bodyData = requestBodyComponents.query?.data(using: .utf8)
        guard let url = URL(string: ApiConfig.propertiesUrl) else {
            return
        }
        
        let request = APIRequest(
            url: url,
            method: .POST,
            contentType: .formURLEncoded,
            body: bodyData
        )
        
        NetworkManager.shared.sendRequest(request) { result in
            switch result {
            case .success:
                AppStorage.shared.removeValue(forKey: AppConstant.iZ_USERPROPERTIES_KEY)
                AppStorage.shared.setAnyValue(data, forKey: "SuccessUserData")
                print("User properties added.")
            case .failure(let error):
                Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription, className: "UserPropertyManager", methodName: "callUserProperties", rid: nil, cid: nil, userInfo: nil)
            }
        }
    }
}



extension Dictionary where Key == String, Value: Any {
    func toSortedJSONString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: [.sortedKeys]) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
