//
//  MediationManager.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 23/06/25.
//

//tp 4
var cpcValue = ""
var ctrValue = ""

var finalCPCValue = "0.00000"

//tp 5
var succ = "false"
var fuCount = 0
var anData: [[String: Any]] = []
var cpcFinalValue = ""


var finalDataValue = NSMutableDictionary()
let tempData = NSMutableDictionary()
var finalData = [String: Any]()
var bidsData = [NSMutableDictionary()]
var alertData = [String: Any]()
var gData = [String: Any]()
var servedData = NSMutableDictionary()

var winnerServed: [String:Any] = [:]



final class MediationManager {
    
    var returnBid = 0.0
    
    static let shared = MediationManager()
    private init() {}
    
    func payLoadDataChange(payload: [String: Any], bundleName: String, isBadge: Bool, isEnabled: Bool, soundName: String, userInfo: [AnyHashable: Any]?, bestAttemptContent: UNMutableNotificationContent, contentHandler: ((UNNotificationContent) -> Void)?) {
        
        guard let jsonDictionary = payload as? [String:Any],
              let aps = jsonDictionary[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary else {
            
            return
        }
        
        resetSharedData()
        extractBasicData(from: aps, bundleName: bundleName)
        
        
        guard let gData = aps[AppConstant.iZ_G_KEY] as? [String: Any],
              let tpValue = gData[AppConstant.iZ_TPKEY] as? String else {
            return
        }
        
        guard let anKeyArray = aps[AppConstant.iZ_ANKEY] as? [[String: Any]], let anKeyDict = anKeyArray.first else {
            return
        }
        
        switch tpValue {
        case "4":
            handleTP4Case(anKey: anKeyDict,
                          aps: aps,
                          bundleName: bundleName,
                          isBadge: isBadge,
                          isEnabled: isEnabled,
                          soundName: soundName,
                          userInfo: userInfo,
                          bestAttemptContent: bestAttemptContent,
                          contentHandler: contentHandler)
            return
            
        case "5":
            guard let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray, anKey.count > 0 else {
                return
            }
            tempData.setValue(anKey, forKey: AppConstant.iZ_ANKEY)
            finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] = tempData
            
            if let apsDict = finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary,
               let notificationData = Payload(dictionary: apsDict) {
                
                // Handle Relevance Score
                iZooto.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                
                // Setup badge, sound, impression
                iZooto.setupBadgeSoundAndHandleImpression(
                    bundleName: bundleName,
                    isBadge: isBadge,
                    bestAttemptContent: bestAttemptContent,
                    notificationData: notificationData,
                    userInfo: userInfo,
                    isEnabled: isEnabled,
                    soundName: soundName
                )
            }
            succ = "false"
            bidsData.removeAll()
            // Prepare encoded FU URLs
            var fuDataArray = [String]()
            for (index,valueDict) in anKey.enumerated()   {
                
                if let dict = valueDict as? [String: Any] {
                    let fuValue = dict["fu"] as? String ?? ""
                    //hit fu
                    if let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)){
                        fuDataArray.append(izUrlString)
                    }
                }
            }
            
            guard let firstURL = fuDataArray.first else {
                return
            }
            
            fuCount = 0
            MediationManager.callFetchUrlForTp5(
                fuArray: fuDataArray,
                anKey: anKeyArray,
                bundleName: bundleName,
                userInfo: userInfo,
                bestAttemptContent: bestAttemptContent,
                contentHandler: contentHandler
            )
            
            return
            
        case "6":
            //            handleTP6Case(aps: aps, gData: gData)
            MediationManager.handleTp6Mediation(aps: aps as NSDictionary, bundleName: bundleName, isBadge: isBadge, isEnabled: isEnabled, soundName: soundName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
            
            return
        default:
            FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
            return
        }
        
        
        
        
    }
    
    // MARK: - Helper Methods
    
    private func resetSharedData() {
        finalDataValue.removeAllObjects()
        bidsData.removeAll()
        tempData.removeAllObjects()
        finalData.removeAll()
        alertData.removeAll()
        gData.removeAll()
        servedData.removeAllObjects()
        anData.removeAll()
        fuCount = 0
        succ = "false"
        cpcFinalValue = ""
        returnBid = 0
        ctrValue = ""
        
    }
    
    
    //MARK: getting basic data
    private func extractBasicData(from aps: NSDictionary, bundleName: String) {
        if let category = aps["category"] {
            tempData.setValue(category, forKey: "category")
        }
        
        if let alert = aps[AppConstant.iZ_ALERTKEY] as? [String: Any] {
            alertData = alert
            tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
        }
        tempData.setValue(1, forKey: "mutable-content")
        tempData.setValue(0, forKey: "content_available")
        
        if let gDataDict = aps[AppConstant.iZ_G_KEY] as? [String: Any] {
            gData = gDataDict
            tempData.setValue(gDataDict, forKey: AppConstant.iZ_G_KEY)
            
            let groupName = "group.\(bundleName).iZooto"
            let userDefaults = UserDefaults(suiteName: groupName)
            let pid = userDefaults?.string(forKey: AppConstant.REGISTERED_ID) ?? gDataDict[AppConstant.iZ_IDKEY] as? String
            let token = userDefaults?.value(forKey: AppConstant.IZ_DEVICE_TOKEN)
            
            finalDataValue.setValue(pid, forKey: AppConstant.iZ_KEY_PID)
            finalDataValue.setValue(token, forKey: AppConstant.iZ_KEY_DEVICE_TOKEN)
            finalDataValue.setValue(gDataDict[AppConstant.iZ_RKEY], forKey: AppConstant.iZ_RID_KEY)
            finalDataValue.setValue(gDataDict[AppConstant.iZ_TPKEY], forKey: "type")
            finalDataValue.setValue("0", forKey: "result")
            finalDataValue.setValue(ApiConfig.SDK_VERSION, forKey: AppConstant.iZ_KEY_APP_SDK_VERSION)
        }
    }
    
    //MARK: decoding the fu url
    static func getDecodedUrl(from rawString: String) -> URL? {
        // Step 1: Decode percent encoding (%5Cu0026 → \u0026)
        guard let percentDecoded = rawString.removingPercentEncoding else {
            return nil
        }

        // Step 2: Decode unicode escapes (\u0026 → &), using JSON trick
        let wrapped = "\"\(percentDecoded)\""
        guard let data = wrapped.data(using: .utf8) else {
            return nil
        }
        let fullyDecoded: String
        do {
            fullyDecoded = try JSONDecoder().decode(String.self, from: data)
        } catch {
            return nil
        }
        // Step 3: Validate and return URL
        guard let url = URL(string: fullyDecoded) else {
            return nil
        }

        return url
    }
    
    
    //MARK: Tp 4
    private func handleTP4Case(anKey: [String: Any],
                               aps: NSDictionary,
                               bundleName: String,
                               isBadge: Bool,
                               isEnabled: Bool,
                               soundName: String,
                               userInfo: [AnyHashable: Any]?,
                               bestAttemptContent: UNMutableNotificationContent,
                               contentHandler: ((UNNotificationContent) -> Void)?) {
        
        let startDate = Date()
        tempData.setValue([anKey], forKey: AppConstant.iZ_ANKEY)
        finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] = tempData
        
        guard let apsDictionary = finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String:Any],
              var notificationData = Payload(dictionary: apsDictionary as NSDictionary),
              let rid = notificationData.global?.rid,
              notificationData.global?.created_on != nil else {
            debugPrint("May be another Payload verify the rid and ct key in payload.")
            return
        }
        
        // Badge, sound, and impression
        iZooto.setupBadgeSoundAndHandleImpression(bundleName: bundleName,
                                                  isBadge: isBadge,
                                                  bestAttemptContent: bestAttemptContent,
                                                  notificationData: notificationData,
                                                  userInfo: userInfo,
                                                  isEnabled: isEnabled,
                                                  soundName: soundName)
        
        iZooto.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
        var returnBid = 0.0
        let fuValue = anKey["fu"] as? String ?? ""
        cpcValue = anKey["cpc"] as? String ?? ""
        ctrValue = (anKey["ctr"] as? String ?? "").removingTilde()
        let cpmValue = anKey["cpm"] as? String ?? ""
        let rb = anKey["rb"] as? String ?? ""
        
        if cpcValue != ""{
            cpcFinalValue = cpcValue
        }else{
            cpcFinalValue = cpmValue
        }
        
        guard let fetchUrl = anKey["fu"] as? String,
              let url = MediationManager.getDecodedUrl(from: fetchUrl) else {
            MediationManager.falbackBidsTp4(startDate: startDate)
            FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
            return
        }
        
        let session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 2
            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        }()
        
        session.dataTask(with: url) {(data, response, error) in
            if(error != nil)
            {
                MediationManager.falbackBidsTp4(startDate: startDate)
                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    //To Check FallBack
                    if let jsonDictionary = json as? [String:Any] {
                        if let value = jsonDictionary[AppConstant.AD_RESPONSE_KEY] as? String {
                            MediationManager.falbackBidsTp4(startDate: startDate)
                            FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: rid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            return
                            
                        }else{
                            if let jsonDictionary = json as? [String: Any] {
                                
                                if self.shouldHandleOutbrainFallback(json: jsonDictionary) {
                                    //for outbrain empty doc in case of success
                                    MediationManager.falbackBidsTp4(startDate: startDate)
                                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: rid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    return
                                }
                                
                                if cpmValue != "" {
                                    if let cpcString = MediationManager.getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue) as? String,
                                       let cpcValue = Double(cpcString),
                                       let cprValue = Double(ctrValue) {
                                        finalCPCValue = String(cpcValue / (10 * cprValue))
                                    } else {
                                        finalCPCValue = "0.0"
                                    }
                                } else {
                                    finalCPCValue = "\(MediationManager.getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                }
                                
                                if !rb.isEmpty {
                                    let rbSTR  = MediationManager.getParseValue(jsonData: jsonDictionary, sourceString: rb)
                                    returnBid = Double(rbSTR) ?? 0
                                    if rbSTR.isEmpty {
                                        returnBid = Double(rb.removingTilde()) ?? 0
                                    }
                                }
                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                let finalCPCValueDouble = Double(finalCPCValue) ?? 0.0
                                let finalCPC = Double(floor(finalCPCValueDouble * 10000) / 10000)
                                servedData = [AppConstant.iZ_A_KEY: 1,AppConstant.iZ_B_KEY: finalCPC,AppConstant.iZ_T_KEY: t,AppConstant.iZ_RETURN_BIDS: returnBid, AppConstant.iZ_CTR_KEY: ctrValue]
                                finalDataValue.setValue("1", forKey: "result")
                                // get title
                                if notificationData.ankey?.titleAd != nil {
                                    MediationManager.processNotificationData(notificationData: &notificationData, jsonDictionary: jsonDictionary, apsDictionary: apsDictionary as NSDictionary, bundleName: bundleName)
                                } else {
                                    MediationManager.falbackBidsTp4(startDate: startDate)
                                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    return
                                }
                            }
                        }
                    }else{
                        if let jsonArray = json as? [[String:Any]] {
                            if jsonArray[0][AppConstant.AD_RESPONSE_KEY] is String{
                                MediationManager.falbackBidsTp4(startDate: startDate)
                                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: rid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                return
                            }else{
                                if notificationData.ankey?.titleAd != nil {
                                    MediationManager.handleCPCAndServe(from: jsonArray, apsDictionary: apsDictionary as NSDictionary, cpcFinalValue: cpcFinalValue, ctrValue: ctrValue, rbValue: rb, cpmValue: cpmValue, startDate: startDate, notificationData: &notificationData, bundleName: bundleName, anKeyIndex: 1, isArray: true, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    
                                } else {
                                    MediationManager.falbackBidsTp4(startDate: startDate)
                                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    return
                                }
                            }
                        }
                    }
                    if notificationData.category != "" && notificationData.category != nil
                    {
                        NotificationCategoryManager.shared.storeCategories(notificationData: notificationData, category: "")
                        if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                            NotificationCategoryManager.shared.addCTAButtons()
                        }
                    }
                    //Bids & Served
                    
                    let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                    finalDataValue.setValue(ta, forKey: "ta")
                    finalDataValue.setValue("1", forKey: "result")
                    
                    finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                    
                    guard MediationManager.finalNotificationPayload(bundleName: bundleName, userInfo: userInfo, notificationData: notificationData, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler) else {
                        return
                    }
                    
                    if notificationData.ankey?.adrv != nil{
                        if let rvArr = notificationData.ankey?.adrv{
                            for url in rvArr {
                                RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: url)
                            }
                        }
                    }
                    
                    if let aps = bestAttemptContent.userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any] {
                        if let finalDict = aps[AppConstant.IZ_FETCH_AD_DETAILS] as? NSDictionary
                        {
                            RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo, url: ApiConfig.mediationImpressionUrl)
                        }
                    }
                    
                    MediationManager.attachBannerImageAsync( notificationData: notificationData, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                    
                } catch {
                    MediationManager.falbackBidsTp4(startDate: startDate)
                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: rid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                }
            }
        }.resume()
        
    }
    
    
    
    //MARK: Handle tp6
    private static func handleTp6Mediation(aps: NSDictionary,bundleName: String, isBadge: Bool,isEnabled: Bool,soundName: String?,userInfo: [AnyHashable : Any]?,bestAttemptContent: UNMutableNotificationContent,contentHandler: ((UNNotificationContent) -> Void)?) {
        
        guard let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray else {
            return
        }
        
        bidsData.removeAll()
        var winnerData: Payload? = nil
        var winnerCpc : Double = 0.0
        var fuCount: Int = 0
        
        let myGroup = DispatchGroup()
        var taboolaAnKey: [String: Any]?
        var pfIndex: Int?
        finalCPCValue = "0.0"
        
        for (index,valueDict) in anKey.enumerated(){
            myGroup.enter()
            guard let dict = valueDict as? [String: Any] else {
                return
            }
            if let element = anKey[index] as? [String: Any] {
                anData = [element]
            }
            tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
            finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] = tempData
            guard let apsDictionary = finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary,
                  var notificationData = Payload(dictionary: apsDictionary) else {
                return
            }
            guard (notificationData.global?.rid != nil && notificationData.global?.created_on != nil) else {
                debugPrint("May be another Payload verify the rid and ct key in payload.")
                return
            }
            
            var cpcFinalValue = ""
            var cpcValue = ""
            var ctrValue = ""
            var cpmValue = ""
            var fpValue: Double = 0.0
            let fuValue = dict["fu"] as? String ?? ""
            cpcValue = dict["cpc"] as? String ?? ""
            ctrValue = (dict["ctr"] as? String ?? "").removingTilde()
            cpmValue = dict["cpm"] as? String ?? ""
            let rbString = dict["rb"] as? String ?? ""
            fpValue = Double((dict["fp"] as? String)?.removingTilde() ?? "") ?? 0.0
            if cpcValue != ""{
                cpcFinalValue = cpcValue
            }else{
                cpcFinalValue = cpmValue
            }
            if let pf = dict["pf"] as? String{
                if pf == "1" {
                    taboolaAnKey = dict
                    fuCount += 1
                    pfIndex = index+1
                    //Handle if only one ad with pf =1
                    if fuCount == anKey.count{
                        fuCount -= 1
                    }else{
                        continue
                    }
                }
            }
            let startDate = Date()
            let session: URLSession = {
                let configuration = URLSessionConfiguration.default
                //                                                    configuration.timeoutIntervalForRequest = 2
                return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
            }()
            guard let url = MediationManager.getDecodedUrl(from: fuValue) else {
                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00, AppConstant.iZ_CTR_KEY: ctrValue])
                finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                fuCount += 1
                if fuCount == anKey.count{
                    handleWinnerOrFallback(winnerPayload: winnerData,
                                           notificationData: notificationData,
                                           userInfo: userInfo,
                                           bundleName: bundleName,
                                           bestAttemptContent: bestAttemptContent,
                                           contentHandler: contentHandler)
                    return
                }
                continue
            }
            session.dataTask(with: url) { data, response, error in
                defer { myGroup.leave()}
                if(error != nil)
                {
                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                    bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00, AppConstant.iZ_CTR_KEY: ctrValue])
                    fuCount += 1
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        //To Check FallBack
                        if let jsonDictionary = json as? [String:Any] {
                            if MediationManager.shared.shouldHandleOutbrainFallback(json: jsonDictionary) || jsonDictionary[AppConstant.AD_RESPONSE_KEY] != nil {
                                if let msg = jsonDictionary[AppConstant.AD_RESPONSE_KEY] as? String {
                                }
                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                bidsData.append([
                                    AppConstant.iZ_A_KEY: index + 1,
                                    AppConstant.iZ_B_KEY: 0.00,
                                    AppConstant.iZ_T_KEY: t,
                                    AppConstant.iZ_RETURN_BIDS: 0.00,
                                    AppConstant.iZ_CTR_KEY: ctrValue
                                ])
                            }else{
                                if let jsonDictionary = json as? [String: Any] {
                                    if notificationData.ankey?.titleAd != nil{
                                        MediationManager.handleCPCAndServe(from: jsonDictionary, apsDictionary: apsDictionary, cpcFinalValue: cpcFinalValue, ctrValue: ctrValue, rbValue: rbString, cpmValue: cpmValue, startDate: startDate, notificationData: &notificationData, bundleName: bundleName, anKeyIndex: index+1, isArray: false, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)

                                    }else {
                                        let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                        bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00, AppConstant.iZ_CTR_KEY: ctrValue])
                                        
                                    }
                                    
                                }
                            }
                        }else{
                            if let jsonArray = json as? [[String:Any]] {//Adgebra
                                
                                if let value = jsonArray[0][AppConstant.AD_RESPONSE_KEY] as? String{
                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                    bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00, AppConstant.iZ_CTR_KEY: ctrValue])
                                }else{
                                    if notificationData.ankey?.titleAd != nil {
                                        MediationManager.handleCPCAndServe(from: jsonArray, apsDictionary: apsDictionary, cpcFinalValue: cpcFinalValue, ctrValue: ctrValue, rbValue: rbString, cpmValue: cpmValue, startDate: startDate, notificationData: &notificationData, bundleName: bundleName, anKeyIndex: index+1, isArray: true, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    } else {
                                        let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                        bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00, AppConstant.iZ_CTR_KEY: ctrValue])
                                    }
                                }
                            }
                        }
                        fuCount += 1
                        if let doubleCpc =  Double(finalCPCValue) {
//                            let finalCPC = Double(floor(doubleCpc * 10000) / 10000)
                            if Double(finalCPCValue) ?? 0.0 > fpValue {
                                if winnerCpc < doubleCpc {
                                    winnerCpc = doubleCpc
                                    winnerData = notificationData
                                    finalDataValue.setValue(winnerServed, forKey: AppConstant.iZ_SERVEDKEY)
                                    finalDataValue.setValue("\(index + 1)", forKey: "result")
                                }
                            }
                        }
                    } catch let error {
                        debugPrint(" Error",error)
                        let t = Int(Date().timeIntervalSince(startDate) * 1000)
                        bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00, AppConstant.iZ_CTR_KEY: ctrValue])
                        fuCount += 1
                    }
                }
                if fuCount == (anKey as AnyObject).count{
                    //Relevance Score
                    iZooto.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                    
                    // to handle badgeCount, Sound, and call impression
                    iZooto.setupBadgeSoundAndHandleImpression(bundleName: bundleName, isBadge: isBadge, bestAttemptContent: bestAttemptContent, notificationData: notificationData, userInfo: userInfo, isEnabled: isEnabled, soundName: soundName ?? "")
                    
                    //Bids & Served
                    let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                    finalDataValue.setValue(ta, forKey: "ta")
                    
                    // To save final served as per cpc
                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
//                    completion(finalData)
                    if let Tdata = taboolaAnKey,
                       let tIndex = pfIndex,
                       let cpcString = Tdata["cpc"] as? String
                    {
                        let tcpc = cpcString.removingTilde()
                        var Tcpc = 0.0
                        if let tempCpc = Double(tcpc){
                            Tcpc = tempCpc
                        }else{
                            Tcpc = 0.0
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "Index : \(tIndex), Cpc conversion into Double failled : \(tcpc)", className: "MediationManager", methodName: "handleTp6Mediation", rid: notificationData.global?.rid, cid: notificationData.global?.id, userInfo: userInfo)
                        }
                        let tfpValue = Double((Tdata["fp"] as? String)?.removingTilde() ?? "") ?? 0.0
                        if (tfpValue < Tcpc) && (Tcpc > winnerCpc){
                            MediationManager.shared.returnBid = Double((Tdata["rb"] as? String)?.removingTilde() ?? "") ?? 0.0
                            ctrValue = String(Double((Tdata["ctr"] as? String)?.removingTilde() ?? "") ?? 0.0)
                            servedData = [AppConstant.iZ_A_KEY: tIndex,AppConstant.iZ_B_KEY: Tcpc, AppConstant.iZ_T_KEY: ta, AppConstant.iZ_RETURN_BIDS: MediationManager.shared.returnBid, AppConstant.iZ_CTR_KEY: ctrValue]
                            finalDataValue.setValue("\(tIndex)", forKey: "result")
                            bidsData.append(servedData)
                            finalDataValue.setValue(ta, forKey: "ta")
                            finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                            finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                            self.taboolaAds(anKey: taboolaAnKey, index: tIndex, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            return
                        }else{
                            MediationManager.shared.returnBid = Double((Tdata["rb"] as? String)?.removingTilde() ?? "") ?? 0.0
                            ctrValue = String(Double((Tdata["ctr"] as? String)?.removingTilde() ?? "") ?? 0.0)
                            servedData = [AppConstant.iZ_A_KEY: tIndex, AppConstant.iZ_B_KEY: Tcpc, AppConstant.iZ_T_KEY: ta, AppConstant.iZ_RETURN_BIDS: MediationManager.shared.returnBid, AppConstant.iZ_CTR_KEY: ctrValue]
                            bidsData.append(servedData)
                            finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                        }
                    }
                    
                    handleWinnerOrFallback(winnerPayload: winnerData, notificationData: notificationData, userInfo: userInfo, bundleName: bundleName,  bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                    
                }
            }.resume()
        }
        myGroup.notify(queue: .main) {
            
        }
    }
    //MARK: for tp 6 logic
    private static func handleWinnerOrFallback(winnerPayload: Payload?,
                                               notificationData: Payload,
                                               userInfo: [AnyHashable: Any]?,
                                               bundleName: String,
                                               bestAttemptContent: UNMutableNotificationContent,
                                               contentHandler: ((UNNotificationContent) -> Void)?) {
        
        if let winnerPayload = winnerPayload {
            if let category = notificationData.category, !category.isEmpty {
                NotificationCategoryManager.shared.storeCategories(notificationData: notificationData, category: "")
                if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                    NotificationCategoryManager.shared.addCTAButtons()
                }
            }

            guard finalNotificationPayload(bundleName: bundleName, userInfo: userInfo,
                                     notificationData: winnerPayload,
                                           bestAttemptContent: bestAttemptContent, contentHandler: contentHandler) else {
                return
            }

            if let rvArr = winnerPayload.ankey?.adrv {
                for url in rvArr {
                    RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: url)
                }
            }

            if let aps = bestAttemptContent.userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any],
               let finalDict = aps[AppConstant.IZ_FETCH_AD_DETAILS] as? NSDictionary {
                RestAPI.callAdMediationImpressionApi(finalDict: finalDict,
                                                     bundleName: bundleName,
                                                     userInfo: userInfo,
                                                     url: ApiConfig.mediationImpressionUrl)
            }

            attachBannerImageAsync(notificationData: winnerPayload,
                                   bundleName: bundleName,
                                   userInfo: userInfo,
                                   bestAttemptContent: bestAttemptContent,
                                   contentHandler: contentHandler)
            
        } else {
            FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
        }
    }

        
    static func attachBannerImageAsync(
        notificationData: Payload,
        bundleName: String,
        userInfo: [AnyHashable: Any]?,
        bestAttemptContent: UNMutableNotificationContent,
        contentHandler: ((UNNotificationContent) -> Void)?
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            autoreleasepool {
                guard let imageUrl = notificationData.ankey?.bannerImageAd else {
                    contentHandler?(bestAttemptContent)
                    return
                }
                
                guard let attachment = UNNotificationAttachment.saveImageToDisk(
                    bundleName: bundleName,
                    cid: notificationData.global?.id,
                    rid: notificationData.global?.rid,
                    imgUrl: imageUrl,
                    userInfo: userInfo,
                    options: nil
                ) else {
                    debugPrint(AppConstant.IMAGE_ERROR)
                    contentHandler?(bestAttemptContent)
                    return
                }
                
                bestAttemptContent.attachments = [attachment]
                contentHandler?(bestAttemptContent)
            }
        }
    }

    
    //MARK: Taboola ads if winner it tp 6
    private static func taboolaAds(anKey: [String:Any]?, index: Int, bundleName: String, userInfo: [AnyHashable : Any]?, bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)?){
        if let anData = anKey, let fuUrl = anData["fu"]{
            let startDate = Date()
            tempData.setValue([anData], forKey: AppConstant.iZ_ANKEY)
            finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] = tempData
            finalDataValue.setValue([], forKey: AppConstant.iZ_SERVEDKEY)
            if let apsDictionary = finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary {
                if var notificationData = Payload(dictionary: apsDictionary){
                    if(notificationData.global?.rid != nil && notificationData.global?.created_on != nil)
                    {
                        let session: URLSession = {
                            let configuration = URLSessionConfiguration.default
                            configuration.timeoutIntervalForRequest = 2
                            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                        }()
                        guard let url = MediationManager.getDecodedUrl(from: fuUrl as? String ?? "") else {
//                            finalDataValue.setValue("0", forKey: "result")
                            FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            return
                        }
                        session.dataTask(with: url) { data, response, error in
                            if(error != nil)
                            {
//                                finalDataValue.setValue("0", forKey: "result")
                                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                return
                            }
                            if let data = data {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data)
                                    //To Check FallBack
                                    if let jsonDictionary = json as? [String:Any] {
                                        if MediationManager.shared.shouldHandleOutbrainFallback(json: jsonDictionary) || jsonDictionary[AppConstant.AD_RESPONSE_KEY] != nil {
                                            debugPrint("msgCode Value found.")
//                                            finalDataValue.setValue("\(index)", forKey: "result")
                                                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                            return
                                        }else{
                                            if let jsonDictionary = json as? [String:Any] {
                                                // get title
                                                if notificationData.ankey?.titleAd != nil {
                                                    processNotificationData(notificationData: &notificationData, jsonDictionary: jsonDictionary, apsDictionary: apsDictionary, bundleName: bundleName)
                                                }else{
                                                    finalDataValue.setValue("0", forKey: "result")
                                                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                    return
                                                }
                                            }
                                        }
                                    } else {
                                        if let jsonArray = json as? [[String:Any]] {//if adgebra has pf = 1.
                                            if let value = jsonArray[0][AppConstant.AD_RESPONSE_KEY] as? String{
                                                finalDataValue.setValue("\(index)", forKey: "result")
                                                FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                return
                                            }else{
                                                //title
                                                if notificationData.ankey?.titleAd != nil {
                                                    processArrayNotificationData(notificationData: &notificationData, jsonArray: jsonArray)
                                                } else {
                                                    finalDataValue.setValue("0", forKey: "result")
                                                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                    return
                                                }
                                            }
                                        }
                                    }
                                    //Bids & Served
                                    let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                                    finalDataValue.setValue(ta, forKey: "ta")
                                    finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                    if notificationData.category != "" && notificationData.category != nil
                                    {
                                        NotificationCategoryManager.shared.storeCategories(notificationData: notificationData, category: "")
                                        if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                                            NotificationCategoryManager.shared.addCTAButtons()
                                        }
                                    }
                                    guard finalNotificationPayload(bundleName: bundleName, userInfo: userInfo, notificationData: notificationData, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)else {
                                        return
                                    }
                                    //call impression
                                    if let aps = bestAttemptContent.userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any] {
                                        if let finalDict = aps[AppConstant.IZ_FETCH_AD_DETAILS] as? NSDictionary
                                        {
                                            RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo, url: ApiConfig.mediationImpressionUrl)
                                        }
                                    }
                                    
                                    //call rv api here for pf = 1 ads
                                    if notificationData.ankey?.adrv != nil{
                                        if let rvArr = notificationData.ankey?.adrv{
                                            for url in rvArr {
                                                RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: url)
                                            }
                                        }
                                    }
                                    attachBannerImageAsync(
                                        notificationData: notificationData,
                                        bundleName: bundleName,
                                        userInfo: userInfo,
                                        bestAttemptContent: bestAttemptContent,
                                        contentHandler: contentHandler
                                    )
                                    
                                } catch let error {
                                    finalDataValue.setValue("0", forKey: "result")
                                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                }
                            }
                        }.resume()
                    }else{
                        finalDataValue.setValue("0", forKey: "result")
                        FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "Other Payload", className: "MediationManager", methodName: "taboolaAds", rid: notificationData.global?.rid , cid: notificationData.global?.id, userInfo: userInfo)
                    }
                }
            }
        }else{
            finalDataValue.setValue("0", forKey: "result")
            FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
        }
    }
    //MARK:  handle Outbrain empty ad
    func shouldHandleOutbrainFallback(json: [String: Any]) -> Bool {
        guard let response = json["response"] as? [String: Any],
              let documents = response["documents"] as? [String: Any] else {
            return false
        }
        
        if let docArray = documents["doc"] as? [[String: Any]] {
            return docArray.isEmpty //true
        } else {
            return true
        }
    }
    
    
    
    static func handleCPCAndServe(
        from json: Any,
        apsDictionary: NSDictionary,
        cpcFinalValue: String,
        ctrValue: String,
        rbValue: String,
        cpmValue: String,
        startDate: Date,
        notificationData: inout Payload,
        bundleName: String,
        anKeyIndex: Int,
        isArray: Bool,
        userInfo: [AnyHashable: Any]?,
        bestAttemptContent: UNMutableNotificationContent,
        contentHandler: ((UNNotificationContent) -> Void)?
    ) {
        MediationManager.shared.returnBid = 0
        var cpcRaw: String = "0.0"
        if !cpmValue.isEmpty {
            if isArray,
               let cpcString = getParseArrayValue(jsonData: json as? [[String : Any]] ?? [["": ""]], sourceString: cpcFinalValue) as? String,
               let cpcVal = Double(cpcString),
               let ctr = Double(ctrValue),
               ctr != 0 {
                cpcRaw = String(cpcVal / (10 * ctr))
            } else if !isArray,
                      let jsonDict = json as? [String: Any],
                      let cpcString = getParseValue(jsonData: jsonDict, sourceString: cpcFinalValue) as? String,
                      let cpcVal = Double(cpcString),
                      let ctr = Double(ctrValue),
                      ctr != 0 {
                  cpcRaw = String(cpcVal / (10 * ctr))
                if !rbValue.isEmpty {
                    let rbSTR  = MediationManager.getParseValue(jsonData: jsonDict, sourceString: rbValue)
                    MediationManager.shared.returnBid = Double(rbSTR) ?? 0
                    if rbSTR.isEmpty {
                        MediationManager.shared.returnBid = Double(rbValue.removingTilde()) ?? 0
                    }
                }
              }
        } else {
            if isArray, let jsonArray = json as? [[String: Any]] {
                cpcRaw = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue))"
                if cpcRaw.isEmpty {
                    cpcRaw = cpcFinalValue.removingTilde()
                }
                if !rbValue.isEmpty {
                    let rbSTR  = getParseArrayValue(jsonData: jsonArray, sourceString: rbValue)
                    MediationManager.shared.returnBid = Double(rbSTR) ?? 0
                    if rbSTR.isEmpty {
                        MediationManager.shared.returnBid = Double(rbValue.removingTilde()) ?? 0
                    }
                }
            } else if let jsonDict = json as? [String: Any] {
                cpcRaw = "\(getParseValue(jsonData: jsonDict, sourceString: cpcFinalValue))"
                if cpcRaw.isEmpty {
                    cpcRaw = cpcFinalValue.removingTilde()
                }
                if !rbValue.isEmpty {
                    let rbSTR  = MediationManager.getParseValue(jsonData: jsonDict, sourceString: rbValue)
                    MediationManager.shared.returnBid = Double(rbSTR) ?? 0
                    if rbSTR.isEmpty {
                        MediationManager.shared.returnBid = Double(rbValue.removingTilde()) ?? 0
                    }
                }
            } else {
                cpcRaw = "0" // fallback in case casting fails
            }
        }
        
        finalCPCValue = cpcRaw
        let finalCPCDouble = Double(finalCPCValue) ?? 0.0
        let finalCPC = Double(floor(finalCPCDouble * 10000) / 10000)
        let t = Int(Date().timeIntervalSince(startDate) * 1000)
        
        servedData = [
            AppConstant.iZ_A_KEY: anKeyIndex,
            AppConstant.iZ_B_KEY: finalCPCValue,
            AppConstant.iZ_T_KEY: t,
            AppConstant.iZ_RETURN_BIDS: MediationManager.shared.returnBid,
            AppConstant.iZ_CTR_KEY: ctrValue
        ]
        if let serveD = servedData as? [String : Any] {
            winnerServed = serveD
        }
        bidsData.append(servedData)
        
        if isArray, let jsonArray = json as? [[String: Any]] {
            processArrayNotificationData(notificationData: &notificationData, jsonArray: jsonArray)
        } else if let jsonDict = json as? [String: Any] {
            processNotificationData(notificationData: &notificationData, jsonDictionary: jsonDict, apsDictionary: apsDictionary, bundleName: bundleName)
        }
    }
    
    //MARK: Handle failed cases of tp5
    private static func handleTP5FailedResponse(startDate: Date, succ: String, ctrValue: String, anKey: [[String: Any]], fuArray: [String], userInfo: [AnyHashable: Any]?, bundleName: String, bestAttemptContent: UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)?) {
        
        let t = Int(Date().timeIntervalSince(startDate) * 1000)
        
        // Append bid data
        fuCount += 1
        bidsData.append([AppConstant.iZ_A_KEY: fuCount, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: 0.00, AppConstant.iZ_CTR_KEY: ctrValue])
        
        // Proceed to next fetch if not done
        if succ != "done" {
            if fuArray.count > fuCount {
                callFetchUrlForTp5(fuArray: fuArray, anKey: anKey, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                return
            }
        }
        
        // If all keys exhausted
        if fuCount == anKey.count {
            servedData = [AppConstant.iZ_A_KEY: fuCount, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: 0.00, AppConstant.iZ_CTR_KEY: "\(ctrValue)"]
            
            finalDataValue.setValue(t, forKey: "ta")
            finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
            finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
            finalDataValue.setValue("0", forKey: "result")
            
            // Fire fallback
            FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
        }
    }

    
    
    //MARK: TP 5 function
    @objc private static func callFetchUrlForTp5(fuArray: [String], anKey: [[String: Any]], bundleName: String, userInfo: [AnyHashable : Any]?, bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)? ){
        let startDate = Date()
        let fu = fuArray[fuCount]
        if let dict = anKey[fuCount] as? NSDictionary {
            if let firstElement = anKey[fuCount] as? [String: Any] {
                anData = [firstElement]
            }
            tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
            finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] = tempData
            if let apsDictionary = finalData[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary {
                if var notificationData = Payload(dictionary: apsDictionary){
                    if(notificationData.global?.rid != nil && notificationData.global?.created_on != nil)
                    {
                        let cpmValue = dict["cpm"] as? String ?? ""
                        let ctrValue = (dict["ctr"] as? String ?? "").removingTilde()
                        let cpcValue = dict["cpc"] as? String ?? ""
                        let rbString = dict["rb"] as? String ?? ""
                        if cpcValue != ""{
                            cpcFinalValue = cpcValue
                        }else{
                            cpcFinalValue = cpmValue
                        }
                        
                        let session: URLSession = {
                            let configuration = URLSessionConfiguration.default
                            configuration.timeoutIntervalForRequest = 2
                            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                        }()
                        
                        guard let url = MediationManager.getDecodedUrl(from: fu) else {
                            handleTP5FailedResponse(startDate: startDate, succ: succ, ctrValue: ctrValue, anKey: anKey, fuArray: fuArray, userInfo: userInfo, bundleName: bundleName, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            return
                        }
                        
                        session.dataTask(with: url) { data, response, error in
                            
                            if(error != nil)
                            {
                                handleTP5FailedResponse(startDate: startDate, succ: succ, ctrValue: ctrValue, anKey: anKey, fuArray: fuArray, userInfo: userInfo, bundleName: bundleName, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                return
                               
                            }
                            if let data = data {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data)
                                    //To Check FallBack
                                    if let jsonDictionary = json as? [String:Any] {
                                        if MediationManager.shared.shouldHandleOutbrainFallback(json: jsonDictionary) || jsonDictionary[AppConstant.AD_RESPONSE_KEY] != nil {
                                            handleTP5FailedResponse(startDate: startDate, succ: succ, ctrValue: ctrValue, anKey: anKey, fuArray: fuArray, userInfo: userInfo, bundleName: bundleName, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                            return
                                            
                                        }else{
                                            if succ != "done" {
                                                succ = "true"
                                                finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                            }
                                            if notificationData.ankey?.titleAd != nil {
                                                MediationManager.handleCPCAndServe(from: jsonDictionary, apsDictionary: apsDictionary as NSDictionary, cpcFinalValue: cpcFinalValue, ctrValue: ctrValue, rbValue: rbString, cpmValue: cpmValue, startDate: startDate, notificationData: &notificationData, bundleName: bundleName, anKeyIndex: fuCount+1, isArray: false, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                            }else {
                                                handleTP5FailedResponse(startDate: startDate, succ: succ, ctrValue: ctrValue, anKey: anKey, fuArray: fuArray, userInfo: userInfo, bundleName: bundleName, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                return
                                            }
                                            
                                        }
                                    }else{
                                        if let jsonArray = json as? [[String:Any]] {
                                            if let value = jsonArray[0][AppConstant.AD_RESPONSE_KEY] as? String{
                                                handleTP5FailedResponse(startDate: startDate, succ: succ, ctrValue: ctrValue, anKey: anKey, fuArray: fuArray, userInfo: userInfo, bundleName: bundleName, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                return
                                                
                                            }else{
                                                
                                                if succ != "done" {
                                                    succ = "true"
                                                    finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                                }
                                                if notificationData.ankey?.titleAd != nil {
                                                    MediationManager.handleCPCAndServe(from: jsonArray, apsDictionary: apsDictionary as NSDictionary, cpcFinalValue: cpcFinalValue, ctrValue: ctrValue, rbValue: rbString, cpmValue: cpmValue, startDate: startDate, notificationData: &notificationData, bundleName: bundleName, anKeyIndex: fuCount+1, isArray: true, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                }else {
                                                    handleTP5FailedResponse(startDate: startDate, succ: succ, ctrValue: ctrValue, anKey: anKey, fuArray: fuArray, userInfo: userInfo, bundleName: bundleName, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                    return
                                                }
                                                
                                            }
                                        }
                                    }
                                } catch let error {
                                    if !error.localizedDescription.isEmpty{
                                        handleTP5FailedResponse(startDate: startDate, succ: succ, ctrValue: ctrValue, anKey: anKey, fuArray: fuArray, userInfo: userInfo, bundleName: bundleName, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                        return
                                    }
                                }
                                if succ == "true"{
                                    succ = "done"
                                    //Bids & Served
                                    let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                                    finalDataValue.setValue(ta, forKey: "ta")
                                    //add CTA button here.
                                    if notificationData.category != "" && notificationData.category != nil
                                    {
                                        NotificationCategoryManager.shared.storeCategories(notificationData: notificationData, category: "")
                                        if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                                            NotificationCategoryManager.shared.addCTAButtons()
                                        }
                                    }
                                    finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                    guard finalNotificationPayload(bundleName: bundleName, userInfo: userInfo, notificationData: notificationData, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler) else {
                                        return
                                    }
                                    if notificationData.ankey?.adrv != nil{
                                        if let rvArr = notificationData.ankey?.adrv{
                                            for url in rvArr {
                                                RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: url)
                                            }
                                        }
                                    }
                                    //call impression
                                    if let aps = bestAttemptContent.userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any] {
                                        if let finalDict = aps[AppConstant.IZ_FETCH_AD_DETAILS] as? NSDictionary
                                        {
                                            RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo, url: ApiConfig.mediationImpressionUrl)
                                        }
                                    }
                                    
                                    attachBannerImageAsync(
                                        notificationData: notificationData,
                                        bundleName: bundleName,
                                        userInfo: userInfo,
                                        bestAttemptContent: bestAttemptContent,
                                        contentHandler: contentHandler
                                    )
                                    
                                    return
                                }
                            }
                        }.resume()
                        
                    }
                }
            }
        }
    }
    
    static func falbackBidsTp4(startDate: Date){
        let t = Int(Date().timeIntervalSince(startDate) * 1000)
        servedData = [AppConstant.iZ_A_KEY: 1,AppConstant.iZ_B_KEY: "0.0",AppConstant.iZ_T_KEY: t,AppConstant.iZ_RETURN_BIDS: "0.0", AppConstant.iZ_CTR_KEY: ctrValue]
        finalDataValue.setValue("0", forKey: "result")
        //        bidsData.append(servedData)
        finalDataValue.setValue(t, forKey: "ta")
        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
    }
    
    //MARK: get title, message, image etc...
    private static func processNotificationData(notificationData: inout Payload, jsonDictionary: [String: Any], apsDictionary: NSDictionary,bundleName: String) {
        
        if let title = notificationData.ankey?.titleAd {
            notificationData.ankey?.titleAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: title))"
            notificationData.alert?.title = notificationData.ankey?.titleAd
            
        }
        
        if let message = notificationData.ankey?.messageAd {
            notificationData.ankey?.messageAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: message))"
            notificationData.alert?.body = notificationData.ankey?.messageAd

        }
        
        // Parse and update landing URL
        if var landUrl = notificationData.ankey?.landingUrlAd {
            landUrl = "\(getParseValue(jsonData: jsonDictionary, sourceString: landUrl))"
            if !landUrl.isEmpty {
                notificationData.ankey?.landingUrlAd = landUrl
            }
        }
        
        // Parse and update banner image
        if notificationData.ankey?.bannerImageAd != "" {
            if let imageAd = notificationData.ankey?.bannerImageAd {
                var parsedImageAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: imageAd))"
                if !parsedImageAd.isEmpty {
                    // Replace `.webp` with `.jpeg`
                    if parsedImageAd.contains(".webp") {
                        parsedImageAd = parsedImageAd.replacingOccurrences(of: ".webp", with: ".jpeg")
                    }
                    
                    // Replace `http:` with `https:`
                    if parsedImageAd.contains("http:") {
                        parsedImageAd = parsedImageAd.replacingOccurrences(of: "http:", with: "https:")
                    }
                    
                    notificationData.ankey?.bannerImageAd = parsedImageAd
                    notificationData.alert?.attachment_url = parsedImageAd
                }
            }
        }
        
        if let action1url = notificationData.ankey?.act1link,
           notificationData.global?.act1name != nil{
            let l1url = getParseValue(jsonData: jsonDictionary, sourceString: action1url)
            if !l1url.isEmpty {
                notificationData.ankey?.act1link = l1url
            }
        }
        if let action2url = notificationData.ankey?.act2link,
           notificationData.global?.act2name != nil{
            let l2url = getParseValue(jsonData: jsonDictionary, sourceString: action2url)
            if !l2url.isEmpty {
                notificationData.ankey?.act2link = l2url
            }
        }
        
        //get the value of RC for outbrain
        if notificationData.ankey?.adrc != nil {
            var urlArr: [String] = []
            if let val = notificationData.ankey?.adrc {
                for urlStr in val {
                    urlArr.append(getParseValue(jsonData: jsonDictionary, sourceString: urlStr))
                }
            }
            notificationData.ankey?.adrc = urlArr
        }
        
        //get RV url for outbrain ads
        if notificationData.ankey?.adrv != nil {
            var rvUrlArr: [String] = []
            if let urlStrArr = notificationData.ankey?.adrv{
                for urlStr in urlStrArr{
                    rvUrlArr.append(getParseValue(jsonData: jsonDictionary, sourceString: urlStr))
                }
            }
            notificationData.ankey?.adrv = rvUrlArr
        }
    }
    
    
    
    
    @objc static func getParseValue(jsonData :[String : Any], sourceString : String) -> String
    {
        if sourceString.contains("~") {
            return sourceString.replacingOccurrences(of: "~", with: "")
        }

        // 1️⃣ Normalize: Convert bracket notation to dot notation
        var normalized = sourceString
            .replacingOccurrences(of: "[", with: ".")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "..", with: ".")

        // Remove leading/trailing dots if any
        if normalized.hasPrefix(".") { normalized.removeFirst() }
        if normalized.hasSuffix(".") { normalized.removeLast() }

        // 2️⃣ Split into path keys
        let keys = normalized.split(separator: ".").map { String($0) }

        // 3️⃣ Traverse jsonData
        var currentData: Any? = jsonData

        for (index, key) in keys.enumerated() {
            if let indexKey = Int(key), let array = currentData as? [Any], array.indices.contains(indexKey) {
                currentData = array[indexKey]
            } else if let dict = currentData as? [String: Any] {
                currentData = dict[key]
            } else {
                return ""
            }

            // 4️⃣ Return final value
            if index == keys.count - 1, let result = currentData as? String {
                return result
            }
        }

        return ""
    }
    
    
    private static func processArrayNotificationData(notificationData: inout Payload, jsonArray: [[String: Any]]) { //for adgebra notification
        // Update title and message
        if let adTitle = notificationData.ankey?.titleAd {
            notificationData.alert?.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: adTitle))"
            notificationData.ankey?.titleAd = notificationData.alert?.title
        }
        
        if let adMessage = notificationData.ankey?.messageAd {
            notificationData.alert?.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: adMessage))"
            notificationData.ankey?.messageAd = notificationData.alert?.body
        }
        
        // Update landing URL
        if var landUrl = notificationData.ankey?.landingUrlAd {
            landUrl = "\(getParseArrayValue(jsonData: jsonArray, sourceString: landUrl))"
            if !landUrl.isEmpty {
                notificationData.ankey?.landingUrlAd = landUrl
            }
            
        }
        
        // Update banner image
        if let bannerImage = notificationData.ankey?.bannerImageAd, !bannerImage.isEmpty {
            var parsedBannerImage = "\(getParseArrayValue(jsonData: jsonArray, sourceString: bannerImage))"
            if !parsedBannerImage.isEmpty {
                // Replace `.webp` with `.jpg`
                if parsedBannerImage.contains(".webp") {
                    parsedBannerImage = parsedBannerImage.replacingOccurrences(of: ".webp", with: ".jpg")
                }
                // Replace `http:` with `https:`
                if parsedBannerImage.contains("http:") {
                    parsedBannerImage = parsedBannerImage.replacingOccurrences(of: "http:", with: "https:")
                }
                notificationData.ankey?.bannerImageAd = parsedBannerImage
                notificationData.alert?.attachment_url = parsedBannerImage
            }
        }
        
        //CTA Button url
        if let action1url = notificationData.ankey?.act1link,
           notificationData.global?.act1name != nil{
            let l1url = getParseArrayValue(jsonData: jsonArray, sourceString: action1url)
            if !l1url.isEmpty {
                notificationData.ankey?.act1link = l1url
            }
        }
        if let action2url = notificationData.ankey?.act2link,
           notificationData.global?.act2name != nil{
            let l2url = getParseArrayValue(jsonData: jsonArray, sourceString: action2url)
            if !l2url.isEmpty {
                notificationData.ankey?.act2link = l2url
            }
        }
        
        //get the value of RC
        if notificationData.ankey?.adrc != nil {
            var urlArr: [String] = []
            if let val = notificationData.ankey?.adrc {
                for urlStr in val {
                    urlArr.append(getParseArrayValue(jsonData: jsonArray, sourceString: urlStr))
                }
            }
            notificationData.ankey?.adrc = urlArr
        }
        
        //get RV url
        if notificationData.ankey?.adrv != nil {
            var rvUrlArr: [String] = []
            if let urlStrArr = notificationData.ankey?.adrv{
                for urlStr in urlStrArr{
                    rvUrlArr.append(getParseArrayValue(jsonData: jsonArray, sourceString: urlStr))
                }
            }
            notificationData.ankey?.adrv = rvUrlArr
        }
    }
    
    
    
    // for json aaray
    @objc static func getParseArrayValue(jsonData: [[String: Any]], sourceString: String) -> String {
        if sourceString.contains("~") {
            return sourceString.replacingOccurrences(of: "~", with: "")
        } else if sourceString.contains(".") {
            // Split the source string by "."
            let array = sourceString.split(separator: ".")
            // Ensure the first part of the array is present and remove the brackets
            guard let firstPart = array.first else {
                return ""
            }
            let value = firstPart.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            // Convert the value to an integer
            guard let dataIndex = Int(value), dataIndex < jsonData.count else {
                return ""
            }
            let dataDict = jsonData[dataIndex]
            
            // Ensure the last part of the array is present
            guard let lastPart = array.last else {
                return ""
            }
            let res = String(lastPart)
            
            // Retrieve the result from the dictionary
            if let result = dataDict[res] as? String {
                return result
            } else {
                return ""
            }
        }
        
        return ""
    }
    
    //MARK: Create final Notification Payload
    @objc static func finalNotificationPayload(bundleName: String, userInfo: [AnyHashable: Any]?, notificationData: Payload, bestAttemptContent: UNMutableNotificationContent, contentHandler: ((UNNotificationContent) -> Void)?) -> Bool {
        var user = userInfo
        if var aps = user?[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? [String: Any] {
            aps[AppConstant.IZ_FETCH_AD_DETAILS] = finalDataValue
            if var served = finalDataValue[AppConstant.iZ_SERVEDKEY] as? [String: Any] {
                served[AppConstant.iZ_LNKEY] = notificationData.ankey?.landingUrlAd
                served[AppConstant.iZ_TITLE_KEY] = notificationData.alert?.title
                var updatedFinalDataValue = finalDataValue
                updatedFinalDataValue[AppConstant.iZ_SERVEDKEY] = served
                aps[AppConstant.IZ_FETCH_AD_DETAILS] = updatedFinalDataValue
            }
            
            if notificationData.ankey?.adrc != nil {
                aps["rc"] = notificationData.ankey?.adrc
            }
            
            if let finalAlert = notificationData.alert {
                aps[AppConstant.iZ_ALERTKEY] = finalAlert.dictionaryRepresentation() as? [String: Any]
                if let title = finalAlert.title, !title.isEmpty{
                    bestAttemptContent.title = title
                }else{
                    let rid = notificationData.global?.rid ?? ""
                    FallbackAdsManager.shared.handleFallback(bundleName: bundleName, fallCategory: "", notiRid: rid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                    return false
                }

                if let body = notificationData.ankey?.messageAd, !body.isEmpty {
                    bestAttemptContent.body = body
                }else{
                    bestAttemptContent.body = ""
                }
            }
            if notificationData.global?.act1name != nil && notificationData.ankey?.act1link != nil{
                aps["l1"] = notificationData.ankey?.act1link
            }
            if notificationData.global?.act2name != nil && notificationData.ankey?.act2link != nil{
                aps["l2"] = notificationData.ankey?.act2link
            }
            if var anArrya = aps["an"] as? [[String: Any]] {
                if let ln = notificationData.ankey?.landingUrlAd {
                    aps[AppConstant.iZ_LNKEY] = ln
                }
                aps["an"] = nil
            }
            if let finalG = notificationData.global {
                let optionalMappings: [(String, Any?)] = [
                    ("ct", finalG.created_on),
                    ("r", finalG.rid),
                    ("ri", finalG.reqInt),
                    ("id", finalG.id),
                    ("k", finalG.key),
                    ("tl", finalG.ttl),
                    ("cfg", finalG.cfg),
                    ("ia", "0"),// for always hit on browser
                    ("b1", finalG.act1name),
                    ("l1", finalG.act1link),
                    ("d1", finalG.act1Id),
                    ("b2", finalG.act2name),
                    ("l2", finalG.act2link),
                    ("d2", finalG.act2Id)
                ]
                for (key, value) in optionalMappings {
                    if let value = value {
                        aps[key] = value
                    }
                }
                aps["g"] = nil
            }
            user?[AppConstant.iZ_NOTIFCATION_KEY_NAME] = aps
        }
        if let validUser = user as? [AnyHashable: Any] {
            bestAttemptContent.userInfo = validUser
        }
        return true
    }
}

