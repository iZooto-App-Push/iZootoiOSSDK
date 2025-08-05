//
//  iZooto.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.


import Foundation
import UserNotifications

import UIKit
import Darwin
import AdSupport
import AVFoundation
import CommonCrypto
import WebKit
import AppTrackingTransparency
import AdSupport


let sharedUserDefault = UserDefaults(suiteName: SharedUserDefault.suitName)
@objc
public class iZooto : NSObject
{
    static var appDelegate = UIApplication.shared.delegate
    private let application : UIApplication
    private static var type = "0"
    private static let checkData = 1 as Int
    private static var isAnalytics = false as Bool
    private static var isNativeWebview = false as Bool
    private static var isWebView = false as Bool
    private static var badgeNumber = 0 as NSInteger
    private static var badgeCount = 0 as NSInteger
    private static var storyBoardData = UIStoryboard.self
    private static var identifireNameData = String.self
    private static var controllerData = UIViewController.self
    @objc public static var landingURLDelegate : iZootoLandingURLDelegate?
    private static var keySettingDetails = Dictionary<String,Any>()
    @objc public static var notificationReceivedDelegate : iZootoNotificationReceiveDelegate?
    @objc public static var notificationOpenDelegate : iZootoNotificationOpenDelegate?
    
    private static var categoryArray: [[String:Any]] = []
    
    @objc public init(application : UIApplication)
    {
        self.application = application
    }
    // initialise the device and register the token
    @objc public static func initialisation(izooto_id : String, application : UIApplication,iZootoInitSettings : Dictionary<String,Any>)
    {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        AppStorage.shared.configureAppGroup(Utils.getGroupName(bundleName: bundleName) ?? "")
        if(izooto_id == nil || izooto_id == "")
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "iZooto app id is not found\(izooto_id)", className: "iZooto", methodName: "initialisation", rid: nil, cid: nil, userInfo: nil)
            return
        }
        AppStorage.shared.set(izooto_id, forKey: "appID")
        
        guard let url = URL(string: ApiConfig.datUrl + "\(izooto_id).dat") else {
            debugPrint("Invalid URL \(ApiConfig.datUrl + "\(izooto_id).dat")")
            return
        }

        let request = APIRequest(
            url: url,
            method: .GET,
            contentType: .json // For GET, content type doesn’t matter much, but set it for consistency
        )
        NetworkManager.shared.sendRequest(request) { result in
            switch result {
            case .success(let data):
                // Convert data to string
                let rawString = String(data: data, encoding: .utf8) ?? ""

                // Clean and format the string
                let cleanedString = rawString
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\n", with: "")

                // Decode from Base64
                guard let decodedJSON = cleanedString.fromBase64() else {
                    debugPrint(AppConstant.IZ_INITIALISATION_LOG)
                    return
                }

                do {
                    guard let jsonData = decodedJSON.data(using: .utf8) else {
                        debugPrint(AppConstant.IZ_INITIALISATION_LOG)
                        return
                    }

                    let responseData = try JSONDecoder().decode(DatParsing.self, from: jsonData)

                    if let groupName = Utils.getGroupName(bundleName: bundleName) {
                        AppStorage.shared.configureAppGroup(groupName)
                        AppStorage.shared.set(responseData.pid, forKey: AppConstant.REGISTERED_ID)
                    }

                    if let groupName = Utils.getGroupName(bundleName: bundleName) {
                        AppStorage.shared.configureAppGroup(groupName)
                        BadgeManager.shared.handleBadgeStatus(responseData.isBadge, bundleName: bundleName)
                    }
                    DispatchQueue.main.async {
                        SettingsManager.shared.handleKeySettingDetails(bundleName: bundleName, keySettingDetails: iZootoInitSettings, appDelegate: UIApplication.shared.delegate)
                    }
                } catch {
                    debugPrint(AppConstant.IZ_INITIALISATION_LOG)
                }
            case .failure(let error):
                debugPrint(AppConstant.IZ_INITIALISATION_LOG)
            }
        }
        if let userPropertiesData = AppStorage.shared.getAnyValue(forKey:AppConstant.iZ_USERPROPERTIES_KEY) as? [String:Any]
        {
            UserPropertyManager.shared.addUserProperties(data: userPropertiesData)
        }
        if let eventData = AppStorage.shared.getAnyValue(forKey:AppConstant.KEY_EVENT) as? Dictionary<String, Any>,
           let eventName = AppStorage.shared.getString(forKey: AppConstant.KEY_EVENT_NAME){
            addEvent(eventName: eventName, data: eventData)
        }
        if UserDefaults.standard.value(forKey: AppConstant.iZ_CLICK_OFFLINE_DATA) != nil{
            RestAPI.offlineClickTrackCall(bundleName: bundleName)
        }
        if UserDefaults.standard.value(forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA) != nil{
            RestAPI.mediationOfflineClickTrackCall(bundleName: bundleName)
        }
    }
    
    
    @objc public static func setLogLevel(bundleName:String, isEnable: Bool){
        UserDefaults.standard.set(isEnable, forKey: AppConstant.iZ_LOG_ENABLED)
        if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName:bundleName)) {
            userDefaults.set(isEnable, forKey: AppConstant.iZ_LOG_ENABLED)
        }
    }
    
    /* Getting APNS Token from this methods */
    @objc public static func getToken(deviceToken : Data)
    {
        DeviceTokenHandler.shared.handleDeviceToken(deviceToken)
    }
    
    // badgeNumber 0: Default , increase by 1 and decreas by 1
    // badgeNumber 1: always show 1 and on first click show 0 and again show 1 in notification received.
    // badgeNumber 2: increase by 1 and on first click show 0 and cleare all notification from notification center. also clear all notification on App Launch.
    @objc public static func setBadgeCount(badgeNumber: NSInteger) {
        
        // Retrieve the app's bundle identifier
        let bundleName = Bundle.main.object(forInfoDictionaryKey: AppConstant.BUNDLE_IDENTIFIER) as? String ?? ""
        
        // If badgeNumber is -1, only update sharedUserDefault without using App Group
        if badgeNumber == -1 {
            sharedUserDefault?.setValue(badgeNumber, forKey: "BADGECOUNT")
        }
        
        // If badgeNumber is 1, store the value and a flag into app group shared UserDefaults
        if badgeNumber == 1 {
            if let sharedUserDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                sharedUserDefaults.set(true, forKey: "badgeViaFunction")          // Mark that the badge was set via function
                sharedUserDefaults.setValue(badgeNumber, forKey: "BADGECOUNT")    // Store the badge count
                sharedUserDefaults.synchronize()
            }
        }
        // If badgeNumber is 2, same behavior as above with separate condition
        else if badgeNumber == 2 {
            if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                userDefaults.set(true, forKey: "badgeViaFunction")
                userDefaults.setValue(badgeNumber, forKey: "BADGECOUNT")
                userDefaults.set(0, forKey:"Badge")
                BadgeManager.shared.updateBadge(to: 0)
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                userDefaults.synchronize()
            }
        }
        // For all other badgeNumber values (except -1), only set the flag without storing count
        else {
            if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                userDefaults.set(true, forKey: "badgeViaFunction")
                userDefaults.synchronize()
            }
        }
    }

    
    /// Syncs the user's email, first name, and last name with the backend if the email is new.
    /// It also stores the email locally and ensures input validation.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - fName: The user's first name.
    ///   - lName: The user's last name.
    @objc public static func syncUserDetailsEmail(email: String, fName: String, lName: String) {
        EmailManager.syncEmail(email: email, fName: fName, lName: lName)
        
    }
    
    /// Fetches the notification feed, optionally supporting pagination.
    ///
    /// - Parameter isPagination: A boolean value indicating whether pagination should be used to fetch the next set of data.
    /// - Parameter completion: A closure that returns either a JSON string (on success) or an error message (on failure).
    @objc public static func getNotificationFeed(isPagination: Bool, completion: @escaping (String?, Error?) -> Void) {
        // Retrieve the bundle name (App identifier) to access related user data
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        
        // Ensure both user ID and device token are available before making the API call
        if let userID = Utils.getUserId(bundleName: bundleName), let token = Utils.getUserDeviceToken(bundleName: bundleName) {
            // Call API to fetch the notification feed, passing the pagination flag and user ID
            RestAPI.fetchDataFromAPI(isPagination: isPagination, iZPID: userID) { (jsonString, error) in
                // Handle error scenario (API call failed)
                if let error = error {
                    // Log error and return a message indicating no more data is available
                    debugPrint(error)
                    completion("No more data", nil)
                } else if let jsonString = jsonString {
                    // On successful response, return the fetched JSON string via completion handler
                    completion(jsonString, nil)
                }
            }
        } else {
            // If user ID or device token is not available, return an error message via completion handler
            completion("Feed data is not enabled, kindly contact the support team.", nil)
        }
    }

   
    // Handle the payload and show the notification
    @available(iOS 11.0, *)
    @objc public static func didReceiveNotificationExtensionRequest(bundleName : String,soundName :String,isBadge : Bool, request : UNNotificationRequest, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
    {
        var bundleName = bundleName
        let userInfo = request.content.userInfo
        let isEnabled = false
        if let jsonDictionary = userInfo as? [String:Any] {
            if let aps = jsonDictionary[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary{
                if let bn = aps.value(forKey: "bn") as? String {
                    bundleName = bn
                }
                let groupName = "group."+bundleName+".iZooto"
                if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
                    let appId = userDefaults.value(forKey: "appID") as? String ?? ""
                    if appId.isEmpty {
                        let errorMessage = "Bundle name mismatch: Please ensure the bundle name in the NotificationService class matches the main app's bundle identifier. A mismatch can affect push notifications, badge count, delivery and impressions."
                        debugPrint(errorMessage)
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(errorMessage) , your bundle name is :\(bundleName)", className: "iZooto", methodName: "didReceiveNotification", rid: nil, cid: nil, userInfo: userInfo)
                    }
                }
                if aps.value(forKey: AppConstant.iZ_ANKEY) != nil {
                    if let userInfoData = userInfo as? [String: Any] {
                        MediationManager.shared.payLoadDataChange(payload: userInfoData, bundleName: bundleName, isBadge: isBadge, isEnabled: isEnabled, soundName: soundName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                    }
                }else{
                    //to get all aps data & pass it to commonfu function
                    if let apsDictionary = userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary {
                        if let notificationData = Payload(dictionary: apsDictionary){
                            guard notificationData.rid != nil && notificationData.created_on != nil else {
                                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                                Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(AppConstant.iZ_KEY_OTHER_PAYLOD) \(userInfo)", className: "iZooto", methodName: "didReceive",rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
                                return
                                
                            }
                            
                            // to handle badgeCount, Sound, and call impression
                            setupBadgeSoundAndHandleImpression(bundleName: bundleName, isBadge: isBadge, bestAttemptContent: bestAttemptContent, notificationData: notificationData, userInfo: userInfo, isEnabled: isEnabled, soundName: soundName)
                            
                            //Relevance Score
                            self.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                            if notificationData.fetchurl != nil && notificationData.fetchurl != ""
                            {
                                
                                FetcherAds.shared.handleFetcherNotification(notificationData: notificationData, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            }
                            else{
                                if notificationData != nil
                                {
                                    let firstIndex = notificationData.rid?.prefix(1).first
                                    if firstIndex != "6" && firstIndex != "7" {
                                        notificationReceivedDelegate?.onNotificationReceived(payload: notificationData)
                                    }
                                    
                                    if notificationData.category != "" && notificationData.category != nil
                                    {
                                        //to store categories
                                        NotificationCategoryManager.shared.storeCategories(notificationData: notificationData, category: "")
                                        if notificationData.act1name != "" && notificationData.act1name != nil {
                                            NotificationCategoryManager.shared.addCTAButtons()
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        autoreleasepool {
                                            guard (notificationData.alert?.attachment_url) != nil else { return }
                                            guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.id, rid: notificationData.rid, imgUrl: notificationData.alert?.attachment_url ?? "", userInfo: userInfo, options: nil) else {
                                                if isEnabled == true{
                                                    debugPrint(AppConstant.IMAGE_ERROR)
                                                }
                                                contentHandler?(bestAttemptContent)
                                                return
                                            }
                                            bestAttemptContent.attachments = [ attachment ]
                                        }
                                        contentHandler?(bestAttemptContent)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // To handle badgeCount, Sound and call impression
    @objc static func setupBadgeSoundAndHandleImpression( bundleName: String, isBadge: Bool, bestAttemptContent :UNMutableNotificationContent, notificationData: Payload, userInfo: [AnyHashable : Any]? , isEnabled: Bool, soundName:String) {
        // custom notification sound
        if (soundName != "")
        {
            bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(string: soundName) as String)
        }
        else
        {
            bestAttemptContent.sound = .default()
        }
        if(bundleName != "") {
            
            var number:Int? = nil
            var rid: String? = nil
            var cid: String? = nil
            if notificationData.ankey != nil {
                if let cfg = notificationData.global?.cfg{
                    number = Int(cfg)
                }
                rid = notificationData.global?.rid
                cid = notificationData.global?.id
            }else{
                if let cfg = notificationData.cfg{
                    number = Int(cfg)
                }
                rid = notificationData.rid
                cid = notificationData.id
            }
            
            let groupName = "group."+bundleName+".iZooto"
            if let userDefaults = UserDefaults(suiteName: groupName) {
                userDefaults.set(isBadge, forKey: "isBadge")
                if isBadge {
                    let isFunction = userDefaults.value(forKey: "badgeViaFunction") as? Bool ?? true
                    if isFunction {
                        if let sharedUserDefaults = UserDefaults(suiteName:groupName) {
                            let badgeCount = sharedUserDefaults.integer(forKey: "BADGECOUNT")
                            if badgeCount == 1 {
                                bestAttemptContent.badge = 1
                            }
                            else{
                                let badgeCount = userDefaults.integer(forKey: "Badge")
                                bestAttemptContent.badge = (max(badgeNumber, badgeCount + 1)) as NSNumber
                                userDefaults.set(bestAttemptContent.badge, forKey: "Badge")
                                
                            }
                        }else{
                            
                            let badgeCount = userDefaults.integer(forKey: "Badge")
                            bestAttemptContent.badge = (max(badgeNumber, badgeCount + 1)) as NSNumber
                            userDefaults.set(bestAttemptContent.badge, forKey: "Badge")
                        }
                    }else{
                        if let userDefault = UserDefaults(suiteName: groupName) {
                            let badgeStatus = userDefault.value(forKey: "isBadgeEnabled") as? String
                            if badgeStatus == "staticBadge" {
                                bestAttemptContent.badge = 1
                                userDefault.set(1, forKey: "Badge")
                            }else if badgeStatus == "enableBadge"{
                                let badgeCount = userDefaults.integer(forKey: "Badge")
                                bestAttemptContent.badge = (max(badgeNumber, badgeCount + 1)) as NSNumber
                                userDefault.set(bestAttemptContent.badge, forKey: "Badge")
                            }else if badgeStatus == "disableBadge"{
                                bestAttemptContent.badge = -1
                            }
                        }
                        else{
                            let badgeCount = userDefaults.integer(forKey: "Badge")
                            bestAttemptContent.badge = (max(badgeNumber, badgeCount + 1)) as NSNumber
                            userDefaults.set(bestAttemptContent.badge, forKey: "Badge")
                            
                        }
                    }
                } else {
                    bestAttemptContent.badge = -1
                }
                if (number != nil)
                {
                    handleImpresseionCfgValue(cfgNumber: number ?? 0, notificationData: notificationData, bundleName: bundleName, isSilentPush: false, userInfo: userInfo)
                }
                userDefaults.synchronize()
            }
            else
            {
                if isEnabled == true{
                    debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_APP_GROUP_ERROR_)
                }
                Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_APP_GROUP_ERROR_, className: "iZooto", methodName: "setupBadgeSoundAndHandleImpression", rid: rid, cid: cid, userInfo: userInfo)
            }
        }
    }
    
    //To set relevance score in above iOS 15
    @objc static func setRelevanceScore(notificationData: Payload, bestAttemptContent: UNMutableNotificationContent){
        if #available(iOS 15.0, *) {
            bestAttemptContent.relevanceScore = notificationData.relevance_score ?? 0
            if(notificationData.interrutipn_level == 1 )
            {
                bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.passive
            }
            if(notificationData.interrutipn_level == 2)
            {
                bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.timeSensitive
            }
            if(notificationData.interrutipn_level == 3)
            {
                bestAttemptContent.interruptionLevel  = UNNotificationInterruptionLevel.critical
            }
        }
    }
   
    // for json aaray
    @objc private static func getParseArrayValue(jsonData: [[String: Any]], sourceString: String) -> String {
        if sourceString.contains("~") {
            return sourceString.replacingOccurrences(of: "~", with: "")
        } else if sourceString.contains(".") {
            // Split the source string by "."
            let array = sourceString.split(separator: ".")
            // Ensure the first part of the array is present and remove the brackets
            guard let firstPart = array.first else {
                return sourceString
            }
            let value = firstPart.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
            // Convert the value to an integer
            guard let dataIndex = Int(value), dataIndex < jsonData.count else {
                return sourceString
            }
            let dataDict = jsonData[dataIndex]
            
            // Ensure the last part of the array is present
            guard let lastPart = array.last else {
                return sourceString
            }
            let res = String(lastPart)
            
            // Retrieve the result from the dictionary
            if let result = dataDict[res] as? String {
                return result
            } else {
                return sourceString
            }
        }
        
        return sourceString
    }

    //To check notification enabled
    @objc public static func navigateToSettings()
    {
        UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
            switch setttings.authorizationStatus{
            case .authorized:
                debugPrint("Already Notifcation enabled")
            case .denied:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Please enable notifications for \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "APP Name")", message: "To receive these updates,you must first allow to receive \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "APP Name") notification from settings", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: " Not Now", style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Take me there", style: .default, handler: { (action: UIAlertAction) in
                        
                        DispatchQueue.main.async {
                            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    debugPrint("Settings opened: \(success)") // debugPrints true
                                })
                            }
                        }
                    }))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            case .notDetermined:
                debugPrint("")
            case .provisional:
                debugPrint("something vital went wrong here")
            case .ephemeral:
                debugPrint("something vital went wrong here")
            }
        }
    }
    
    
    // Hybrid Plugin Version
    @objc public static func setPluginVersion(pluginVersion : String){
        if pluginVersion != ""{
            sharedUserDefault?.set(pluginVersion, forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE)
        }else{
            sharedUserDefault?.set("", forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE)
        }
    }
    
    // for jsonObject
    @objc private static func getParseValue(jsonData :[String : Any], sourceString : String) -> String
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
                return sourceString
            }

            // 4️⃣ Return final value
            if index == keys.count - 1, let result = currentData as? String {
                return result
            }
        }
        return sourceString
    }
    
    
    // Parsing the jsonObject
    @objc private static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                debugPrint(error.localizedDescription)
//                Utils.handleOnceException(exceptionName: error.localizedDescription, className: "iZooto", methodName: "convertToDictionary", rid: nil, cid: nil, userInfo: nil)
            }
        }
        return nil
    }
    
    
    @objc public static func handleForeGroundNotification(notification: UNNotification, displayNotification: String, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        let appState = UIApplication.shared.applicationState
        let userInfo = notification.request.content.userInfo
        
        guard let apsDict = userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary else {
            print("APS dictionary missing in userInfo")
            return
        }
        
        let payload = Payload(dictionary: apsDict)
        
        // Show custom in-app alert
        if appState == .active && displayNotification == AppConstant.iZ_KEY_IN_APP_ALERT {
            ForegrounNotificationHelper.showCustomAlertIfNeeded(payload: payload)
            return
        }
        
        // Process background or standard notifications
        guard let jsonDict = userInfo as? [String: Any], let aps = jsonDict[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary else {
            print("Malformed notification payload.")
            return
        }
        
        if let ankey = aps.value(forKey: AppConstant.iZ_ANKEY) {
            guard let data = Payload(dictionary: apsDict) else {
                print("Payload parsing failed")
                return
            }
            
            if let fetchUrlAd = data.ankey?.fetchUrlAd, !fetchUrlAd.isEmpty,
               let rid = data.global?.rid,
               let createdOn = data.global?.created_on {
                completionHandler([.badge, .alert, .sound])
            } else {
                Utils.handleOnceException(
                    bundleName: bundleName,
                    exceptionName: "iZooto Payload is missing or invalid: \(userInfo)",
                    className: AppConstant.iZ_REST_API_CLASS_NAME,
                    methodName: "handleForeGroundNotification",
                    rid: data.global?.rid,
                    cid: data.global?.id,
                    userInfo: userInfo
                )
            }
            return
        }
        
        // Handle regular notification with fetchurl or rid
        guard let fetchUrl = payload?.fetchurl, !fetchUrl.isEmpty else {
            if let rid = payload?.rid, let createdOn = payload?.created_on {
                completionHandler([.badge, .alert, .sound])
                if !["6", "7"].contains(String(rid.prefix(1))) {
                    if let payloadData = payload {
                        notificationReceivedDelegate?.onNotificationReceived(payload: payloadData)
                    }
                }
            } else {
                completionHandler([.badge, .alert, .sound])
            }
            return
        }
        
        // FetchURL exists case
        guard let rid = payload?.rid, let firstChar = rid.first else {
            print("Invalid rid in payload")
            return
        }
        
        if !["6", "7"].contains(String(firstChar)) {
            if let payloadData = payload {
                notificationReceivedDelegate?.onNotificationReceived(payload: payloadData)
            }
        }
        
        completionHandler([.badge, .alert, .sound])
    }
    
    //MARK: Handle the clicks the notification from Banner,Button
    @objc public static func notificationHandler(response : UNNotificationResponse) {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: AppConstant.BUNDLE_IDENTIFIER) as? String ?? ""
        
        BadgeManager.shared.handleBadgeCount(bundleName: bundleName)
        
        guard let userInfo = response.notification.request.content.userInfo as? [String: Any],
              let aps = userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary,
              let notificationData = Payload(dictionary: aps) else {
            print("Invalid notification payload")
            return
        }
        
        if let finalBids = aps[AppConstant.IZ_FETCH_AD_DETAILS] as? [String: Any] {
            NotificationHandlerHelper.shared.handleMediation(notificationData: notificationData, userInfo: userInfo, response: response, finalBids: finalBids, bundleName: bundleName)
        } else {
            NotificationHandlerHelper.shared.handleStandard(notificationData: notificationData, userInfo: userInfo, response: response, bundleName: bundleName)
        }
    }
    
    private  static func handleImpresseionCfgValue(cfgNumber: Int , notificationData : Payload,bundleName : String, isSilentPush: Bool, userInfo: [AnyHashable : Any]?)
    {
        AppStorage.shared.configureAppGroup(Utils.getGroupName(bundleName: bundleName) ?? "")
        guard let pid = AppStorage.shared.getString(forKey: AppConstant.REGISTERED_ID),
              let token = AppStorage.shared.getString(forKey: AppConstant.IZ_DEVICE_TOKEN) else{
            return
        }
        
        let binaryString = String(cfgNumber, radix: 2)
        let firstDigit = Double(binaryString)?.getDigit(digit: 1.0) ?? 0
        let thirdDigit = Double(binaryString)?.getDigit(digit: 3.0) ?? 0
        let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
        let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
        let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
        let seventhDigit = Double(binaryString)?.getDigit(digit: 7.0) ?? 0
        let ninthDigit = Double(binaryString)?.getDigit(digit: 9.0) ?? 0
        let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
        guard let convertBinaryToDecimal = Int(domainURL, radix: 2) else {
            return
        }
        // all time when notification recevied via cfg
        if(firstDigit == 1)
        {
            RestAPI.callImpression(notificationData: notificationData,pid: pid,token: token, bundleName: bundleName, isSilentPush: isSilentPush, userInfo: userInfo)
        }
        let formattedDate = Date().getFormattedDate()
        let lastViewInDay = sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW)
        let lastDay = sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW_WEEKLY)
        let lastWeekDay = sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)
        let url: String
        if convertBinaryToDecimal != 0 {
            url = "https://lim\(convertBinaryToDecimal).izooto.com/lim\(convertBinaryToDecimal)"
        } else {
            url = ApiConfig.lastNotificationViewUrl
        }
        if thirdDigit == 1 {// Weekly lastView
            if lastDay == nil || lastWeekDay == nil || (formattedDate != lastDay && Date().dayOfWeek() == lastWeekDay) {
                sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW_WEEKLY)
                sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)
                RestAPI.lastImpression(notificationData: notificationData, pid: pid, token: token, url: url, bundleName: bundleName, userInfo: userInfo)
            }
        }else if(seventhDigit == 1){// Daily or Weekly lastView
            if(ninthDigit == 1) {//Daily
                if(formattedDate != lastViewInDay) {
                    sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW)
                    RestAPI.lastImpression(notificationData: notificationData,pid:pid,token: token,url: url, bundleName: bundleName, userInfo: userInfo)
                }
            }
            if(ninthDigit == 0){// weekly
                if lastDay == nil || lastWeekDay == nil || (formattedDate != lastDay && Date().dayOfWeek() == lastWeekDay) {
                    sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW_WEEKLY)
                    sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)
                    RestAPI.lastImpression(notificationData: notificationData, pid: pid, token: token, url: url, bundleName: bundleName, userInfo: userInfo)
                }
            }
        }
    }
    @objc static func clickTrack(bundleName: String, notificationData : Payload,actionType : String, userInfo: [AnyHashable: Any]?)
        {
            
            let pid = Utils.getUserId(bundleName: bundleName) ?? ""
            let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
            guard notificationData.cfg != nil else {
                Utils.handleOnceException(bundleName: bundleName, exceptionName: "Both cfg values are nil.", className: "iZooto", methodName: "ClickTrack",rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
                return
            }
            if(notificationData.cfg != nil){
                guard let number = Int(notificationData.cfg ?? "0") else {
                    return
                }
                let binaryString = String(number, radix: 2)
                let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                let thirdDigit = Double(binaryString)?.getDigit(digit: 3.0) ?? 0
                let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                guard let convertBinaryToDecimal = Int(domainURL, radix: 2) else { return }
                if(secondDigit == 1)
                {
                    RestAPI.clickTrack(bundleName: bundleName, notificationData: notificationData, type: actionType,pid: pid,token:token, userInfo: userInfo ?? nil)
                }
                let formattedDate = Date().getFormattedDate()
                let lastClickInDay = sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK)
                let lastDay = sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKLY)
                let lastWeekday = sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)
                let url: String
                if convertBinaryToDecimal != 0 {
                    url = "https://lci\(convertBinaryToDecimal).izooto.com/lci\(convertBinaryToDecimal)"
                }else{
                    url = ApiConfig.lastNotificationClickUrl
                }
                if thirdDigit == 1 {//handle weekly lastClick.
                    if lastDay == nil || lastWeekday == nil || (lastDay != formattedDate && lastWeekday == Date().dayOfWeek()){
                        sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK_WEEKLY)
                        sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)
                        RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid: pid, token: token, url: url, userInfo: userInfo)
                    }
                }else if eighthDigit == 1 {// Daily && Weekly lastClick
                    if(tenthDigit == 1){
                        if(formattedDate != lastClickInDay) {// Daily lastClick
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK)
                            RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid:pid,token: token,url: url, userInfo: userInfo ?? nil )
                        }
                    } else if(tenthDigit == 0) {// Weekly lastClick
                        if lastDay == nil || lastWeekday == nil || (formattedDate != lastDay && Date().dayOfWeek() == lastWeekday){
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK_WEEKLY)
                            sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)
                            RestAPI.lastClick(bundleName: bundleName, notificationData: notificationData, pid:pid,token: token,url: url, userInfo: userInfo ?? nil )
                        }
                    }
                }
            } else {
                Utils.handleOnceException(bundleName: bundleName, exceptionName: "No CFG Key defined \(userInfo)", className: "iZooto", methodName: "ClickTrack", rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
            }
        }
        
        
        
        // Handle the InApp/Webview// and landing url listener
        @objc static func onHandleInAPP(response : UNNotificationResponse , actionType : String,launchURL : String)
        {
            let userInfo = response.notification.request.content.userInfo
            if let apsDict = userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary {
                let notifcationData = Payload(dictionary: apsDict)
                
                if let inApp = notifcationData?.inApp, inApp.contains("1"), !inApp.isEmpty {
                    ViewController.serviceURL = notifcationData?.url
                    if let keyWindow = UIApplication.shared.keyWindow, let rootViewController = keyWindow.rootViewController {
                        rootViewController.present(ViewController(), animated: true, completion: nil)
                    }
                } else {
                    onHandleLandingURL(response: response, actionType: actionType, launchURL: launchURL)
                }
            } else {
                onHandleLandingURL(response: response, actionType: actionType, launchURL: launchURL)
            }
        }
    
        // handle the borwser
        @objc  static func onHandleLandingURL(response : UNNotificationResponse , actionType : String,launchURL : String)
        {
            let userInfo = response.notification.request.content.userInfo
            if let apsDictionary = userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary {
                let notifcationData = Payload(dictionary: apsDictionary)
                if let inAppValue = notifcationData?.inApp, inAppValue.contains("0"), !inAppValue.isEmpty {
                    handleBroserNotification(url: launchURL)
                }
            } else {
                print("Failed to create Payload from userInfo.")
            }
        }
        
        // handle the addtional data
        @objc static func handleClicks(response : UNNotificationResponse , actionType : String)
        {
            let userInfo = response.notification.request.content.userInfo
            if let notificationDictionary = userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary {
                let notificationData = Payload(dictionary: notificationDictionary)
                var data = Dictionary<String,Any>()
                data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_ID] = notificationData?.act1id ?? ""
                data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_TITLE] = notificationData?.act1name ?? ""
                data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_URL] = notificationData?.act1link ?? ""
                data[AppConstant.iZ_KEY_DEEPL_LINK_ADDITIONAL_DATA] = notificationData?.ap ?? ""
                data[AppConstant.iZ_KEY_DEEP_LINK_LANDING_URL] = notificationData?.url ?? ""
                data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_ID] = notificationData?.act2id ?? ""
                data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_TITLE] = notificationData?.act2name ?? ""
                data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_URL] = notificationData?.act2link ?? ""
                data[AppConstant.iZ_KEY_DEEPL_LINK_ACTION_TYPE] = actionType
                notificationOpenDelegate?.onNotificationOpen(action: data)
            } else {
                print("Failed to create Payload from userInfo.")
            }
            
        }
        
        @objc static func getQueryStringParameter(url: String, param: String) -> String? {
            guard let url = URLComponents(string: url) else { return nil }
            return url.queryItems?.first(where: { $0.name == param })?.value
        }
        
        // Add Event Functionality
    @objc public static func addEvent(eventName: String, data: Dictionary<String, Any>) {
        guard !eventName.isEmpty else { return }
        let returnData = Utils.dataValidate(data: data)
        if let theJSONData = try? JSONSerialization.data(withJSONObject: returnData, options: .fragmentsAllowed),
           let validateData = String(data: theJSONData, encoding: .utf8) {
            let bundleName = Bundle.main.object(forInfoDictionaryKey: AppConstant.BUNDLE_IDENTIFIER) as? String ?? ""
            if let token = AppStorage.shared.getString(forKey: AppConstant.IZ_DEVICE_TOKEN), !token.isEmpty,
               let pid = AppStorage.shared.getString(forKey: AppConstant.REGISTERED_ID) {
                RestAPI.callEvents(bundleName: bundleName, eventName: Utils.eventValidate(eventName: eventName), data: validateData as NSString, pid: pid, token: token)
            } else {
                AppStorage.shared.setAnyValue(data, forKey: AppConstant.KEY_EVENT)
                AppStorage.shared.set(eventName, forKey: AppConstant.KEY_EVENT_NAME)
            }
        }
    }
        
    // Add User Properties
    @objc public static func addUserProperties( data : Dictionary<String,Any>)
    {
        UserPropertyManager.shared.addUserProperties(data: data)
    }
    
    // promptForPushNotifications
    @objc public  static  func promptForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
        }
        if #available(iOS 10.0, *) {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
                print(AppConstant.PERMISSION_GRANTED ,"\(granted)")
                guard granted else { return }
                //                    getNotificationSettings()
                SettingsManager.shared.getNotificationSettings()
            }
        }
    }
    
    //MARK: handle browser if ia = 0
    @objc static func handleBroserNotification(url : String)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            var urlString = url
            if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
                urlString = "https://" + url
            }
            
            if let isUrl =  MediationManager.getDecodedUrl(from: urlString) {
                UIApplication.shared.open(isUrl)
            }
        }
    }
    
    /*
     - setNotificationEnable
     - isSubscribe -> true - Notification received and regsiter a devcie token
     ->isSubscribe -> false - Device token unregistered
     iOS SDK- Exposed a new method for handle the notification subscribe/unsubscribe
     */
    
    @objc public static func setSubscription(isSubscribe : Bool)
    {
        if(isSubscribe)
        {
            UIApplication.shared.registerForRemoteNotifications()
        }
        else
        {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    // handle silent push notification on tracking
    @objc public static func handleSilentPushNotification( userInfo: [AnyHashable: Any]){
        
        // Check if it's a silent push
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        if let apsDictionary = userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary,
           apsDictionary["content-available"] as? Int == 1 {
            if let notificationData = Payload(dictionary: apsDictionary){
                var number : Int?
                var cfgValue = ""
                if (notificationData.global?.cfg != nil)
                {
                    if let cfg = notificationData.global?.cfg {
                        cfgValue = cfg
                        number = Int(cfg)
                    }
                    
                } else if (notificationData.cfg != nil) {
                    if let cfg = notificationData.cfg {
                        cfgValue = cfg
                        number = Int(cfg)
                    }
                }
                if let intNum = number {
                    handleImpresseionCfgValue(cfgNumber: intNum, notificationData: notificationData, bundleName: Bundle.main.bundleIdentifier ?? "", isSilentPush: true, userInfo: userInfo)
                }else {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "CFG value :\(cfgValue) .", className: "iZooto", methodName: "handleSilentPushNotification", rid: notificationData.rid , cid: notificationData.id, userInfo: userInfo)
                }
            }
        } else {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "Failed to convert payload in NSDistionary DATA: \(userInfo)", className: "iZooto", methodName: "handleSilentPushNotification", rid: nil, cid: nil, userInfo: userInfo)
        }
    }
    
}

// Handle banner imange uploading and deleting
@available(iOS 11.0, *)
@available(iOSApplicationExtension 11.0, *)
extension UNNotificationAttachment {
    
    static func saveImageToDisk(bundleName: String, cid: String?, rid: String?, imgUrl: String, userInfo: [AnyHashable: Any]?, options: [NSObject: AnyObject]?) -> UNNotificationAttachment? {
        
        // Step 1: Convert `mediaUrl` to a `URL` object.
        guard let url = URL(string: imgUrl) else {
            return nil
        }
        
        do {
            // Step 2: Download the media data from the given URL.
            let mediaData = try Data(contentsOf: url) as NSData
            
            // Step 3: Create a unique temporary folder.
            let fileManager = FileManager.default
            let folderName = ProcessInfo.processInfo.globallyUniqueString
            guard let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true) else {
                        print("Failed to create folder URL")
                        return nil
                    }
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            
            // Step 4: Dynamically determine the file extension based on URL.
            let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension  // Default to "jpg" if no extension.
            
            // Check if the file is an image or video.
            let isVideo = fileExtension.lowercased() == "mp4" || fileExtension.lowercased() == "mov"
            
            // Step 5: Generate a unique file name based on type.
            let uniqueIdentifier = UUID().uuidString + "." + fileExtension
            
            // Step 6: Create the file URL inside the temporary folder.
            let fileURL = folderURL.appendingPathComponent(uniqueIdentifier)
            
            // Step 7: Write the media data (image or video) to the file.
            try mediaData.write(to: fileURL, options: [])
            
            // Step 8: Create a `UNNotificationAttachment` object using the saved file.
            let attachment = try UNNotificationAttachment(identifier: uniqueIdentifier, url: fileURL, options: options)
            
            // Step 9: Return the created attachment.
            return attachment
            
        } catch let error {
            // Handle any errors that occur during file creation or data writing.
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "mediaUrl : \(imgUrl) ErrorMessage : \(error.localizedDescription)", className: AppConstant.IZ_TAG, methodName: "saveImageToDisk", rid: rid, cid: cid, userInfo: userInfo)
        }
        
        return nil
    }
    
}

@objc public protocol iZootoLandingURLDelegate : NSObjectProtocol
{
    func onHandleLandingURL(url : String)
}
@objc public protocol iZootoNotificationReceiveDelegate : NSObjectProtocol
{
    func onNotificationReceived(payload : Payload)
}
@objc public protocol iZootoNotificationOpenDelegate : NSObjectProtocol
{
    func onNotificationOpen(action : Dictionary<String,Any>)
}

// handle the Encyption /Decrption functionality
extension String {
    /// Encode a String to Base64
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Decode a String from Base64. Returns nil if unsuccessful.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func removingTilde() -> String {
        return self.contains("~") ? self.replacingOccurrences(of: "~", with: "") : self
    }
}
extension Double {
    func getDigit(digit: Double) -> Int{
        let power = Int(pow(10, (digit-1)))
        return (Int(self) / power) % 10
    }
}
extension Date {
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
        return formatter.string(from: self)
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

