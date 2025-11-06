//
//  FallbackAdsManager.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 09/06/25.
//

import Foundation
import UserNotifications
final class FallbackAdsManager {
    static let shared = FallbackAdsManager()
        private init() {}
    
    @available(iOS 11.0, *)
    func handleFallback(bundleName: String, fallCategory: String, notiRid: String, userInfo: [AnyHashable: Any]?, bestAttemptContent: UNMutableNotificationContent, contentHandler: ((UNNotificationContent) -> Void)?) {
        
        guard let aps = userInfo?[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary,
              let receivedNotification = Payload(dictionary: aps) else {
            contentHandler?(bestAttemptContent)
            return
        }
        
        let startDate = Date()
        let flbk: [String]
        if let gArray = aps["g"] as? [String: Any] {
            let fsd = (gArray["fsd"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "flbk"
            let fbu = (gArray["fbu"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "default.json"
            flbk = [fsd.isEmpty ? "flbk" : fsd, fbu.isEmpty ? "default.json" : fbu]
        } else {
            let fsd = (aps["fsd"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "flbk"
            let fbu = (aps["fbu"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "default.json"
            flbk = [fsd.isEmpty ? "flbk" : fsd, fbu.isEmpty ? "default.json" : fbu]
        }
        
        let urlStr = "https://\(flbk[0]).izooto.com/\(flbk[1])"
        guard let encodedURL = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            contentHandler?(bestAttemptContent)
            return
        }
        
        fetchFallbackData(
            from: url,
            startDate: startDate,
            bundleName: bundleName,
            fallCategory: fallCategory,
            notiRid: notiRid,
            userInfo: userInfo,
            bestAttemptContent: bestAttemptContent,
            receivedNotification: receivedNotification,
            contentHandler: contentHandler
        )
    }
    
    private func fetchFallbackData(
        from url: URL,
        startDate: Date,
        bundleName: String,
        fallCategory: String,
        notiRid: String,
        userInfo: [AnyHashable: Any]?,
        bestAttemptContent: UNMutableNotificationContent,
        receivedNotification: Payload,
        contentHandler: ((UNNotificationContent) -> Void)?
    ) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                contentHandler?(bestAttemptContent)
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let notificationData = Payload(dictionary: json as NSDictionary) else {
                    contentHandler?(bestAttemptContent)
                    return
                }
                
                self.populateNotificationContent(
                    json: json,
                    startDate: startDate,
                    bundleName: bundleName,
                    fallCategory: fallCategory,
                    userInfo: userInfo,
                    bestAttemptContent: bestAttemptContent,
                    receivedNotification: receivedNotification,
                    notificationData: notificationData,
                    contentHandler: contentHandler
                )
                
            } catch {
                Utils.handleOnceException(
                    bundleName: bundleName,
                    exceptionName: "Fallback ad Api error \(error.localizedDescription)",
                    className: "FallbackAdsManager",
                    methodName: "fetchFallbackData",
                    rid: notiRid,
                    cid: "0",
                    userInfo: userInfo
                )
                contentHandler?(bestAttemptContent)
            }
            
        }.resume()
    }
    
    private func populateNotificationContent(
        json: [String: Any],
        startDate: Date,
        bundleName: String,
        fallCategory: String,
        userInfo: [AnyHashable: Any]?,
        bestAttemptContent: UNMutableNotificationContent,
        receivedNotification: Payload,
        notificationData: Payload,
        contentHandler: ((UNNotificationContent) -> Void)?
    ) {
        if let title = json[AppConstant.iZ_T_KEY] as? String {
            bestAttemptContent.title = title
            notificationData.alert?.title = title
        }
        
        if let body = json["m"] as? String {
            bestAttemptContent.body = body
            notificationData.alert?.body = body
        }
        
        if let newUrl = json["bi"] as? String {
            var finalUrl = newUrl
            if finalUrl.contains(".webp") {
                finalUrl = finalUrl.replacingOccurrences(of: ".webp", with: ".png")
            }
            if finalUrl.contains("http:") {
                finalUrl = finalUrl.replacingOccurrences(of: "http:", with: "https:")
            }
            notificationData.alert?.attachment_url = finalUrl
        }
        
        
        // Final payload which we get on notification click.
        var user = userInfo // Copy of the original userInfo
        if var aps = user?[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any] {
            finalDataValue.setValue("0", forKey: "result")
            let t = Int(Date().timeIntervalSince(startDate) * 1000)
            finalDataValue.setValue(t, forKey: "ta")
            if var served = json[AppConstant.iZ_SERVEDKEY] as? [String: Any] {
                served[AppConstant.iZ_LNKEY] = json[AppConstant.iZ_LNKEY]
                served[AppConstant.iZ_TITLE_KEY] = json["t"]
                var updatedFinalDataValue = finalDataValue
                updatedFinalDataValue[AppConstant.iZ_SERVEDKEY] = served
                aps[AppConstant.IZ_FETCH_AD_DETAILS] = updatedFinalDataValue
            }else{
                var served: [String: Any] = [:]
                served[AppConstant.iZ_LNKEY] = notificationData.url
                served[AppConstant.iZ_TITLE_KEY] = "\(bestAttemptContent.title)"
                finalDataValue[AppConstant.iZ_SERVEDKEY] = served
                aps[AppConstant.IZ_FETCH_AD_DETAILS] = finalDataValue
            }
            if var finalAlertData = aps[AppConstant.iZ_ALERTKEY] as? [String: Any]{
                finalAlertData["title"] = bestAttemptContent.title
                finalAlertData["body"] = bestAttemptContent.body
                if let binarImageUrl = json["bi"]{
                    finalAlertData["attachment-url"] = binarImageUrl
                }
                aps[AppConstant.iZ_ALERTKEY] = finalAlertData
            }
            if let falbackLandingUrl = json[AppConstant.iZ_LNKEY] {
                aps[AppConstant.iZ_LNKEY] = falbackLandingUrl
                let btn1Name = receivedNotification.act1name ?? receivedNotification.global?.act1name
                let btn2Name = receivedNotification.act2name ?? receivedNotification.global?.act2name
                if btn1Name != nil && btn1Name != ""{
                    aps["l1"] = falbackLandingUrl
                }
                if btn2Name != nil && btn2Name != ""{
                    aps["l2"] = falbackLandingUrl
                }
            }
            if let cfg = json["cfg"]{
                aps["cfg"] = cfg
            }
            if let cid = json["id"]{
                aps["id"] = cid
            }
            if let ct = json["ct"]{
                aps["ct"] = ct
            }
            if let rid = json["r"]{
                aps["r"] = rid
            }
            aps["ia"] = "0"
            aps["an"] = nil
            aps["g"] = nil
            user?["aps"] = aps
        }
        // Safely assign the modified user to bestAttemptContent.userInfo
        if let validUser = user as? [AnyHashable: Any] {
            bestAttemptContent.userInfo = validUser
        } else {
            print("Error: Modified userInfo is not valid.")
        }
        //end
                 
        // CTA Buttons
        if !fallCategory.isEmpty {
            NotificationCategoryManager.shared.storeCategories(notificationData: receivedNotification, category: "")
            if let act1 = receivedNotification.act1name ?? receivedNotification.global?.act1name, !act1.isEmpty {
                NotificationCategoryManager.shared.addCTAButtons()
            }
        }
        
        // Impression API
        if let aps = bestAttemptContent.userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any],
           let finalDict = aps[AppConstant.IZ_FETCH_AD_DETAILS] as? NSDictionary {
            RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo, url: ApiConfig.mediationImpressionUrl)
            
            let cid = aps["id"] as? String ?? ""
            let rid = aps["r"] as? String ?? ""
            if let alert = aps["alert"] as? [String: Any] {
                if let imgurl = alert["attachment-url"] as? String {
                    // Load image attachment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        autoreleasepool {
                            if let attachment = UNNotificationAttachment.saveImageToDisk(
                                bundleName: bundleName,
                                cid: cid,
                                rid: rid,
                                imgUrl: imgurl,
                                userInfo: userInfo,
                                options: nil
                            ) {
                                bestAttemptContent.attachments = [attachment]
                            } else {
                                debugPrint(AppConstant.IMAGE_ERROR)
                            }
                            contentHandler?(bestAttemptContent)
                        }
                    }
                }
            }
        }
    }
}
