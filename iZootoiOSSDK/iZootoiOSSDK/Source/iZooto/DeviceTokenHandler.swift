//
//  DeviceTokenHandler.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 08/05/25.
//

import Foundation

class DeviceTokenHandler {

    // MARK: - Singleton Instance
    static let shared = DeviceTokenHandler()

    // MARK: - Private Initializer
    private init() {}

    // MARK: - Public Method
    @objc public func handleDeviceToken(_ deviceToken: Data) {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: AppConstant.BUNDLE_IDENTIFIER) as? String ?? ""
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        
        handleToken(bundleName: bundleName, token: token)
    }

    // MARK: - Unified Token Handler
    private func handleToken(bundleName: String, token: String) {
        guard let pid = AppStorage.shared.getString(forKey: AppConstant.REGISTERED_ID), !pid.isEmpty else {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "Pid or token is empty", className: "DeviceTokenHandler", methodName: "handleDeviceToken", rid: nil, cid: nil, userInfo: nil)
            return
        }

        let storedToken = AppStorage.shared.getString(forKey: AppConstant.IZ_DEVICE_TOKEN)

        let isSameToken = storedToken == token
        let lastVisitDate = AppStorage.shared.getString(forKey: AppConstant.iZ_KEY_LAST_VISIT)

        let currentAppVersion = Utils.getAppVersion()
        let savedAppVersion = AppStorage.shared.getString(forKey: AppConstant.iZ_APP_VERSION)
        let savedSDKVersion = AppStorage.shared.getString(forKey: AppConstant.iZ_SDK_VERSION)

        let shouldRegister = !isSameToken || currentAppVersion != savedAppVersion || ApiConfig.SDK_VERSION != savedSDKVersion

        if shouldRegister {
            DispatchQueue.main.async {
                RestAPI.registerToken(bundleName: bundleName, token: token, pid: pid)
                
                if let data = UserDefaults.standard.dictionary(forKey: AppConstant.FAILED_EMAIL) as? [String: String],
                   let email = data["email"] {
                    EmailManager.addEmailDetails(bundleName: bundleName, token: token, pid: pid, email: email, fName: data["fName"] ?? "", lName: data["lName"] ?? "")
                }
            }
        }else{
            debugPrint(AppConstant.DEVICE_TOKEN, token) //else it will print twice for the very first time
            let formattedDate = Date().getFormattedDate()
            if formattedDate != lastVisitDate {
                RestAPI.lastVisit(bundleName: bundleName, pid: pid, token: token)
                AppStorage.shared.set(formattedDate, forKey: AppConstant.iZ_KEY_LAST_VISIT)
            }
            if let data = UserDefaults.standard.dictionary(forKey: AppConstant.FAILED_EMAIL) as? [String: String],
               let email = data["email"] {
                EmailManager.addEmailDetails(bundleName: bundleName, token: token, pid: pid, email: email, fName: data["fName"] ?? "", lName: data["lName"] ?? "")
            }
        }
    }
}
