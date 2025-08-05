//
//  FetcherAds.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 18/07/25.
//

import Foundation

final class FetcherAds {
    static let shared = FetcherAds()
    private init() {}
    
    func handleFetcherNotification( notificationData: Payload, bundleName: String, userInfo: [AnyHashable: Any], bestAttemptContent: UNMutableNotificationContent, contentHandler: ((UNNotificationContent) -> Void)?) {
        
        guard let jsonDictionary = userInfo as? [String:Any],
              let apsDictionary = jsonDictionary[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary,
              let notificationData = Payload(dictionary: apsDictionary as NSDictionary) else {
            return
        }
        
        guard let fetchUrl = notificationData.fetchurl, !fetchUrl.isEmpty else { return }
        
        let startDate = Date()
        bidsData.removeAll()
        finalDataValue.removeAllObjects()
        servedData.removeAllObjects()
        
        if let pid = AppStorage.shared.getString(forKey: AppConstant.REGISTERED_ID),
           let token = AppStorage.shared.getString(forKey: AppConstant.IZ_DEVICE_TOKEN) {
            finalDataValue.setValue(pid, forKey: AppConstant.iZ_KEY_PID)
            finalDataValue.setValue(token, forKey: AppConstant.iZ_KEY_DEVICE_TOKEN)
        }
        
        let served: [String: Any] = ["a": 0, "b": 0, "t": -1]
        finalDataValue.setValue([String](), forKey: AppConstant.iZ_BIDSKEY)
        finalDataValue.setValue(notificationData.rid, forKey: AppConstant.iZ_RID_KEY)
        finalDataValue.setValue(ApiConfig.SDK_VERSION, forKey: AppConstant.iZ_KEY_APP_SDK_VERSION)
        finalDataValue.setValue(served, forKey: AppConstant.iZ_SERVEDKEY)
        
        if notificationData.t == nil || notificationData.t == "" {
            FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
            return
        }
        
        // URL setup
        let izUrlString = fetchUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 2
            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        }()
        
        guard let url = MediationManager.getDecodedUrl(from: izUrlString ?? "") else {
            FallbackAdsManager.shared.handleFallback(
                bundleName: bundleName,
                fallCategory: notificationData.category ?? "",
                notiRid: notificationData.rid ?? "",
                userInfo: userInfo,
                bestAttemptContent: bestAttemptContent,
                contentHandler: contentHandler
            )
            return
        }
        
        session.dataTask(with: url) { [self] data, response, error in
            // Handle error cases
            guard error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "",notiRid: notificationData.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                return
            }
            
            do {
                try processFetcherResponse(
                    data: data,
                    notificationData: notificationData,
                    bundleName: bundleName,
                    startDate: startDate,
                    userInfo: userInfo,
                    bestAttemptContent: bestAttemptContent,
                    contentHandler: contentHandler
                )
            } catch {
                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
            }
            
        }.resume()
    }
    
    
    private func processFetcherResponse(
        data: Data,
        notificationData: Payload,
        bundleName: String,
        startDate: Date,
        userInfo: [AnyHashable: Any],
        bestAttemptContent: UNMutableNotificationContent,
        contentHandler: ((UNNotificationContent) -> Void)?
    ) throws {
        let json = try JSONSerialization.jsonObject(with: data)
        
        // Handle Dictionary response
        if let jsonDictionary = json as? [String: Any] {
            if MediationManager.shared.shouldHandleOutbrainFallback(json: jsonDictionary) || jsonDictionary[AppConstant.AD_RESPONSE_KEY] != nil {
                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                return
            }
            updateNotificationData(from: jsonDictionary, notificationData: notificationData)
        }
        // Handle Array response
        else if let jsonArray = json as? [[String: Any]] {
            if jsonArray.first?[AppConstant.AD_RESPONSE_KEY] is String {
                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                return
            }
            updateNotificationData(from: jsonArray, notificationData: notificationData)
        }
        
        // Manage categories and CTA buttons
        if let category = notificationData.category, !category.isEmpty {
            NotificationCategoryManager.shared.storeCategories(notificationData: notificationData, category: "")
            if let act1 = notificationData.act1name, !act1.isEmpty {
                NotificationCategoryManager.shared.addCTAButtons()
            }
        }
        
        // Update time taken
        let t = Int(Date().timeIntervalSince(startDate) * 1000)
        finalDataValue.setValue(t, forKey: "ta")
        
        // Build final payload for bestAttemptContent.userInfo
        var updatedUserInfo = userInfo
        if var aps = updatedUserInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any] {
            if let finalAlert = notificationData.alert {
                aps[AppConstant.iZ_ALERTKEY] = finalAlert.dictionaryRepresentation() as? [String: Any]
                if let title = finalAlert.title, !title.isEmpty {
                    bestAttemptContent.title = title
                    finalDataValue.setValue("1", forKey: "result")
                }else {
                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: "", notiRid: aps["rid"] as? String ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                    return
                }
                
                if let body = notificationData.m, !body.isEmpty {
                    bestAttemptContent.body = body
                }else{
                    bestAttemptContent.body = ""
                }
                aps[AppConstant.iZ_LNKEY] = notificationData.url
            }
            aps[AppConstant.IZ_FETCH_AD_DETAILS] = finalDataValue
            if var served = finalDataValue[AppConstant.iZ_SERVEDKEY] as? [String: Any] {
                served[AppConstant.iZ_LNKEY] = notificationData.url
                served[AppConstant.iZ_TITLE_KEY] = bestAttemptContent.title
                var updatedFinalDataValue = finalDataValue
                updatedFinalDataValue[AppConstant.iZ_SERVEDKEY] = served
                aps[AppConstant.IZ_FETCH_AD_DETAILS] = updatedFinalDataValue
            }
            if notificationData.act1name != nil && notificationData.act1link != nil {
                aps["l1"] = notificationData.act1link
            }
            if notificationData.act2name != nil && notificationData.act2link != nil {
                aps["l2"] = notificationData.act2link
            }
            if notificationData.furc != nil {
                aps["rc"] = notificationData.furc
            }
            updatedUserInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] = aps
        }
        bestAttemptContent.userInfo = updatedUserInfo as! [String: Any]
        
        // Call impression API
        if let aps = bestAttemptContent.userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any],
           let finalDict = aps[AppConstant.IZ_FETCH_AD_DETAILS] as? NSDictionary {
            RestAPI.callAdMediationImpressionApi(
                finalDict: finalDict,
                bundleName: bundleName,
                userInfo: userInfo,
                url: ApiConfig.mediationImpressionUrl
            )
        }
        
        // Attach image and finalize notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            autoreleasepool {
                guard let attachmentUrl = notificationData.alert?.attachment_url,
                      let attachment = UNNotificationAttachment.saveImageToDisk(
                        bundleName: bundleName,
                        cid: notificationData.id,
                        rid: notificationData.rid,
                        imgUrl: attachmentUrl,
                        userInfo: userInfo,
                        options: nil
                      )
                else {
                    debugPrint(AppConstant.IMAGE_ERROR)
                    contentHandler?(bestAttemptContent)
                    return
                }
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler?(bestAttemptContent)
        }
    }
    
    
    
    // MARK: - Update notification data from JSON
    private func updateNotificationData(
        from json: Any,
        notificationData: Payload
    ) {
        func parseValue(_ source: String?, using parser: (Any, String) -> String?) -> String? {
            guard let source = source, !source.isEmpty else { return nil }
            return parser(json, source)
        }
        
        let parser: (Any, String) -> String? = { json, source in
            if let dict = json as? [String: Any] {
                return MediationManager.getParseValue(jsonData: dict, sourceString: source)
            } else if let array = json as? [[String: Any]] {
                return MediationManager.getParseArrayValue(jsonData: array, sourceString: source)
            }
            return nil
        }
        
        // Title
        if let title = notificationData.t, !title.isEmpty {
            if let parsedTitle = parseValue(title, using: parser) {
                notificationData.t = parsedTitle
                notificationData.alert?.title = parsedTitle
            }
        }
        
        // Message
        if let message = notificationData.m, !message.isEmpty {
            if let parsedMessage = parseValue(message, using: parser){
                notificationData.m = parsedMessage
                notificationData.alert?.body = parsedMessage
            }
        }
        
        // Landing URL
        if let landUrl = notificationData.url, !landUrl.isEmpty {
            if let parsedUrl = parseValue(landUrl, using: parser), !parsedUrl.isEmpty {
                notificationData.url = parsedUrl
            }
        }
        
        // Banner Image
        if let imageAd = notificationData.bi, !imageAd.isEmpty {
            if var parsedImageAd = parseValue(imageAd, using: parser), !parsedImageAd.isEmpty {
                if parsedImageAd.contains(".webp") {
                    parsedImageAd = parsedImageAd.replacingOccurrences(of: ".webp", with: ".jpeg")
                }
                if parsedImageAd.contains("http:") {
                    parsedImageAd = parsedImageAd.replacingOccurrences(of: "http:", with: "https:")
                }
                notificationData.bi = parsedImageAd
                notificationData.alert?.attachment_url = parsedImageAd
            }else{
                notificationData.bi = imageAd
                notificationData.alert?.attachment_url = imageAd
            }
            
            
        }
        
        // Action URLs
        if let action1url = notificationData.act1link,
           notificationData.act1name != nil,
           let parsed = parseValue(action1url, using: parser), !parsed.isEmpty {
            notificationData.act1link = parsed
        }
        
        if let action2url = notificationData.act2link,
           notificationData.act2name != nil,
           let parsed = parseValue(action2url, using: parser), !parsed.isEmpty {
            notificationData.act2link = parsed
        }
        
        // RC URLs
        if let rcUrls = notificationData.furc {
            notificationData.furc = rcUrls.map { parser(json, $0) ?? $0 }
        }
        
        // RV URLs
        if let rvUrls = notificationData.furv {
            let parsedRV = rvUrls.map { parser(json, $0) ?? $0 }
            notificationData.furv = parsedRV
            
            // Call RV requests
            for url in parsedRV {
                RestAPI.callRV_RC_Request(bundleName: Bundle.main.bundleIdentifier ?? "", urlString: url)
            }
        }
    }
}
