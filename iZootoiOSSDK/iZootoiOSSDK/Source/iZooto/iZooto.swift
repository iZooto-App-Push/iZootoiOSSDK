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
    static var appDelegate = UIApplication.shared.delegate!
//    private static var myIdLnArray: [[String:Any]] = []
//    private static var myRCArray: [[String:Any]] = []
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
    
    @objc private static var finalData = [String: Any]()
    @objc private static let tempData = NSMutableDictionary()
    @objc private static var succ = "false"
    @objc private static var alertData = [String: Any]()
    @objc private static var gData = [String: Any]()
    @objc private static var anData: [[String: Any]] = []
    @objc private static var cpcFinalValue = ""
    @objc private static var cpcValue = ""
    @objc private static var cprValue = ""
    @objc private static var finalCPCValue = "0.00000"
    @objc private static var count = 0
    @objc private static var fuCount = 0
    @objc private static var finalDataValue = NSMutableDictionary()
    @objc private static var servedData = NSMutableDictionary()
    @objc private static var bidsData = [NSMutableDictionary()]
    //to store category details
    private static var categoryArray: [[String:Any]] = []
//    @objc static var groupName = Utils.getBundleName()
    
    @objc public init(application : UIApplication)
    {
        self.application = application
    }
    
    // initialise the device and register the token
    @objc public static func initialisation(izooto_id : String, application : UIApplication,iZootoInitSettings : Dictionary<String,Any>)
    {
        
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        if(izooto_id == nil || izooto_id == "")
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "iZooto app id is not found\(izooto_id)", className: "iZooto", methodName: "initialisation", rid: nil, cid: nil, userInfo: nil)
            return
        }
        
        if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
            userDefaults.set(izooto_id, forKey: "appID")
        }
        keySettingDetails = iZootoInitSettings
        RestAPI.getRequest(bundleName: bundleName, uuid: izooto_id) { (output : String?) in
            
            var finalOutPut = output?.trimmingCharacters(in: .whitespaces)
            finalOutPut = finalOutPut?.replacingOccurrences(of: "\n", with: "")

            guard let jsonString = finalOutPut?.fromBase64() else {//if wrong json format
                Utils.handleOnceException(bundleName: bundleName, exceptionName: ".dat base64 == \(output)", className: "iZooto", methodName: "initialisation", rid: nil, cid: nil, userInfo: nil)
                return
            }
            do {
                if let finalJsonData = jsonString.data(using: .utf8) {
                    let responseData: DatParsing = try JSONDecoder().decode(DatParsing.self, from: finalJsonData)
                    if responseData.pid != "" && !responseData.pid.isEmpty {
                        if let savePid = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
                            savePid.setValue(responseData.pid, forKey: AppConstant.REGISTERED_ID)
                            let pid = savePid.value(forKey: AppConstant.REGISTERED_ID)
                        }
                    }else{
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: ".dat response error \(jsonString)", className: "iZooto", methodName: "initialisation", rid: nil, cid: nil, userInfo: nil)
                        return
                    }
                    if let sharedUserDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                        if responseData.isBadge == "1" {
                            sharedUserDefaults.set(false, forKey: "badgeViaFunction")
                            sharedUserDefaults.setValue("enableBadge", forKey: "isBadgeEnabled")
                            let count = sharedUserDefaults.value(forKey: "Badge") as? NSInteger ?? 0
                            if count < 0 {
                                sharedUserDefaults.set(0, forKey: "Badge")
                            }else{
                                sharedUserDefaults.set(count, forKey: "Badge")
                            }
                            sharedUserDefaults.synchronize()
                        }else if responseData.isBadge == "2" {
                            sharedUserDefaults.set(false, forKey: "badgeViaFunction")
                            sharedUserDefaults.setValue("staticBadge", forKey: "isBadgeEnabled")
                            sharedUserDefaults.synchronize()
                        }else if responseData.isBadge == "0" {
                            sharedUserDefaults.set(false, forKey: "badgeViaFunction")
                            sharedUserDefaults.setValue("disableBadge", forKey: "isBadgeEnabled")
                            sharedUserDefaults.set(0, forKey: "Badge")
                        }
                    }
                } else {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: ".dat response error \(jsonString)", className: "iZooto", methodName: "initialisation", rid: nil, cid: nil, userInfo: nil)
                }
            } catch let error {
                Utils.handleOnceException(bundleName: bundleName, exceptionName: ".dat parsing error \(error)", className: "iZooto", methodName: "initialisation", rid: nil, cid: nil, userInfo: nil)
            }
            
        }
        if(!keySettingDetails.isEmpty)
        {
            if let webViewSetting = keySettingDetails[AppConstant.iZ_KEY_WEBVIEW] {
                sharedUserDefault?.set(webViewSetting, forKey: AppConstant.ISWEBVIEW)
            } else {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_WEBVIEW_ERROR)
                Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_WEBVIEW_ERROR, className: "iZooto", methodName: "initialisation",  rid: nil, cid: nil, userInfo: nil)
            }
            if let isProvisional = keySettingDetails[AppConstant.iZ_KEY_PROVISIONAL] as? Bool{
                if isProvisional {
                    registerForPushNotificationsProvisional()
                }
            }
            else
            {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND)
                Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND, className: "iZooto", methodName: "initialisation",  rid: nil, cid: nil, userInfo: nil)
            }
            if let autoPromptEnabled = keySettingDetails[AppConstant.iZ_KEY_AUTO_PROMPT] as? Bool{
                if autoPromptEnabled {
                    registerForPushNotifications()
                }
            }
            else {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_AUTO_PROMPT_NOT_FOUND)
                Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_AUTO_PROMPT_NOT_FOUND, className: AppConstant.IZ_TAG, methodName: AppConstant.iZ_KEY_INITIALISE,  rid: nil, cid: nil, userInfo: nil)
            }
            if #available(iOS 11.0, *) {
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
            }
        }
        else{
            registerForPushNotifications() // check for prompt
            if #available(iOS 11.0, *) {
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
            }
        }
        if let userPropertiesData = sharedUserDefault?.dictionary(forKey:AppConstant.iZ_USERPROPERTIES_KEY)
        {
            addUserProperties(data: userPropertiesData)
        }
        if let eventData = sharedUserDefault?.dictionary(forKey:AppConstant.KEY_EVENT),
           let eventName = sharedUserDefault?.string(forKey: AppConstant.KEY_EVENT_NAME){
            addEvent(eventName: eventName, data: eventData)
        }
     
    }
    @objc public static func setLogLevel(bundleName:String, isEnable: Bool){
        UserDefaults.standard.set(isEnable, forKey: AppConstant.iZ_LOG_ENABLED)
        if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName:bundleName)) {
            userDefaults.set(isEnable, forKey: AppConstant.iZ_LOG_ENABLED)
        }
    }
    // get IDFA ID
    @objc public static func getIDFAID(completion: @escaping (String) -> Void) {
        // Default IDFA value if tracking is not authorized or available

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
            var idfa = ""
            
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            // Tracking authorized, get the IDFA
                            idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                            let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
                            guard
                                let token = Utils.getUserDeviceToken(bundleName: bundleName), !token.isEmpty,
                                let pid = Utils.getUserId(bundleName: bundleName), pid != "" else {
                                return
                            }
                            // Check if the function has already been called
                            let defaults = UserDefaults.standard
                            if !defaults.bool(forKey: "registerTokenKey") {
                                RestAPI.registerToken(bundleName: bundleName, token: token, pid: pid)
                                defaults.set(true, forKey: "registerTokenKey") // Mark as registered
                            }
                            
                        case .denied, .notDetermined, .restricted:
                            // Access denied or unavailable; return an empty or default value
                            idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        @unknown default:
                            idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        }
                        // Call completion handler with the IDFA value
                        completion(idfa)
                    }
                }
            } else {
                // For iOS versions below 14, fetch the IDFA directly
                idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
                guard
                    let token = Utils.getUserDeviceToken(bundleName: bundleName), !token.isEmpty,
                    let pid = Utils.getUserId(bundleName: bundleName), pid != "" else {
                    return
                }
                // Check if the function has already been called
                let defaults = UserDefaults.standard
                if !defaults.bool(forKey: "registerTokenKey") {
                    RestAPI.registerToken(bundleName: bundleName, token: token, pid: pid)
                    defaults.set(true, forKey: "registerTokenKey") // Mark as registered
                }
                completion(idfa)
            }
        }
    }

    
    // register for pushNotification Setting
    @objc public  static  func registerForPushNotifications() {
        if #available(iOS 11.0, *) {
            UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
        }
        if #available(iOS 11.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
                debugPrint(AppConstant.PERMISSION_GRANTED ,"\(granted)")
                guard granted else { return }
                getNotificationSettings()
            }
        }
    }
    
    // provision setting
    @objc private static func registerForPushNotificationsProvisional()
    {
        if #available(iOS 12.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge,.provisional]) {
                (granted, error) in
                debugPrint(AppConstant.PERMISSION_GRANTED ,"\(granted)")
                guard granted else { return }
                getNotificationSettingsProvisional()
            }
        }
    }
    
    //  Handle notification prompt setting
    @objc  private static func getNotificationSettings() {
        if #available(iOS 11.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // Handle provisional setting
    @objc  private static func getNotificationSettingsProvisional() {
        if #available(iOS 11.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if #available(iOS 12.0, *) {
                    guard settings.authorizationStatus == .provisional else { return }
                }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /* Getting APNS Token from this methods */
    @objc public static func getToken(deviceToken : Data)
    {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        _ = UserDefaults.standard
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
        let formattedDate = format.string(from: date)
        let userDefaults1 = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName))
        let storedToken = userDefaults1?.value(forKey: AppConstant.IZ_GRPS_TKN) as? String
        if UserDefaults.getRegistered() && (token == storedToken)
        {
            let pid = Utils.getUserId(bundleName: bundleName) ?? ""
            guard let token = Utils.getUserDeviceToken(bundleName: bundleName)
            else
            {return}
            debugPrint(AppConstant.DEVICE_TOKEN,token)
            if(formattedDate != (sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_LAST_VISIT)))
            {
                RestAPI.lastVisit(bundleName: bundleName, pid: pid, token:token)
                sharedUserDefault?.set(formattedDate, forKey: AppConstant.iZ_KEY_LAST_VISIT)
            }
            if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                userDefaults.set(token, forKey: AppConstant.IZ_GRPS_TKN)
                userDefaults.set(pid, forKey: AppConstant.REGISTERED_ID)
                userDefaults.synchronize()
            }
            if(RestAPI.SDKVERSION != sharedUserDefault?.string(forKey: AppConstant.iZ_SDK_VERSION)) || (RestAPI.getAppVersion() != sharedUserDefault?.string(forKey: AppConstant.iZ_APP_VERSION))
            {
                sharedUserDefault?.set(RestAPI.SDKVERSION, forKey: AppConstant.iZ_SDK_VERSION)
                sharedUserDefault?.set(RestAPI.getAppVersion(), forKey: AppConstant.iZ_APP_VERSION)
                RestAPI.registerToken(bundleName: bundleName, token: token, pid: pid)
            }
        }
        else
        {
            let pid = Utils.getUserId(bundleName: bundleName) ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                if(pid != "" && token != "")
                {
                    RestAPI.registerToken(bundleName: bundleName, token: token, pid: pid)
                    if RestAPI.getAppVersion() != ""{
                        sharedUserDefault?.set(RestAPI.getAppVersion(), forKey: AppConstant.iZ_APP_VERSION)
                    }
                    sharedUserDefault?.set(RestAPI.SDKVERSION, forKey: AppConstant.iZ_SDK_VERSION)
                    sharedUserDefault?.set(token, forKey: SharedUserDefault.Key.token)
                    if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                        userDefaults.set(token, forKey: AppConstant.IZ_GRPS_TKN)
                        userDefaults.set(pid, forKey: AppConstant.iZ_PID)
                        userDefaults.synchronize()
                    }
                    if UserDefaults.standard.value(forKey: "syncUserData") != nil {
                        if let data = UserDefaults.standard.value(forKey: "syncUserData") as? [String: String]{
                            if let email = data["email"] {
                                RestAPI.addEmailDetails(bundleName: bundleName, token: token, pid: pid, email: email, fName: data["fName"] ?? "", lName: data["lName"] ?? "")
                            }
                        }
                    }
                }
               
            }
        }
    }
    
    // handle the badge count
    @objc public static func setBadgeCount(badgeNumber : NSInteger)
    {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        if(badgeNumber == -1)
        {

            sharedUserDefault?.setValue(badgeNumber, forKey: "BADGECOUNT")
        }
        if(badgeNumber == 1)
        {
            if let sharedUserDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                sharedUserDefaults.set(true, forKey: "badgeViaFunction")
                sharedUserDefaults.setValue(badgeNumber, forKey: "BADGECOUNT")
                sharedUserDefaults.synchronize()
            }
         
        } else if (badgeNumber == 2) {
            if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                userDefaults.set(true, forKey: "badgeViaFunction")
                userDefaults.setValue(badgeNumber, forKey: "BADGECOUNT")
                userDefaults.synchronize()
            }
        }
        else
        {
            if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
                userDefaults.set(true, forKey: "badgeViaFunction")
                userDefaults.synchronize()
            }
        }
    }
    
    @objc public static func  syncUserDetailsEmail(email:String,fName:String,lName : String)
    {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        guard email != "" else {
            print("Email should not be blank")
            return
        }
        let token = Utils.getUserDeviceToken(bundleName: bundleName)
        let pid = Utils.getUserId(bundleName: bundleName) ?? ""
        
        if(email != (sharedUserDefault?.string(forKey: "email")))
        {
            sharedUserDefault?.set(email, forKey: "email")
            
            let maxLength = 50
            var firstname = fName
            var lastName = lName
            if firstname.count > maxLength {
                firstname = String(firstname.prefix(maxLength))
            }
            if lastName.count > maxLength {
                lastName = String(lastName.prefix(maxLength))
            }
            if(email.count<100){
                if isValidEmail(email) {
                    RestAPI.addEmailDetails(bundleName: bundleName, token: token ?? "", pid: pid, email: email, fName: firstname, lName: lastName)
                } else {
                    print("In-Valid Email Address")
                }
            }
        }
        else{
            print("Email id already exits")
        }
        
    }
    static  func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^\S+@\S+\.\S+$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    //All Notification Data
    @objc public static func getNotificationFeed(isPagination: Bool,completion: @escaping (String?, Error?) -> Void){
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        if let userID = Utils.getUserId(bundleName: bundleName), let token = Utils.getUserDeviceToken(bundleName: bundleName){
            RestAPI.fetchDataFromAPI(isPagination: isPagination,iZPID: userID) { (jsonString, error) in
                if let error = error {
                    debugPrint(error)
                    completion("No more data", nil)
                } else if let jsonString = jsonString {
                    completion(jsonString, nil)
                }
            }
        }else{
            completion("Feed data is not enable, kindly contact to support team.", nil)
        }
    }
    
    // Ad's Fallback Url Call
    @available(iOS 11.0, *)
    @objc private static func fallBackAdsApi(bundleName: String, fallCategory: String ,notiRid: String, userInfo: [AnyHashable : Any]?,bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)?){
        var flbk : [String] = ["flbk", "default.json"]
        var str = RestAPI.FALLBACK_URL
        let startDate = Date()
        if let aps = userInfo?["aps"] as? NSDictionary {
            if let receivedNotification = Payload(dictionary: aps) {
                let fsd: String
                let fbu: String
                if let gArray = aps["g"] as? [String: Any] {
                    fsd = (gArray["fsd"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "flbk"
                    fbu = (gArray["fbu"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "default.json"
                } else {
                    fsd = (aps["fsd"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "flbk"
                    fbu = (aps["fbu"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "default.json"
                }
                flbk = [fsd.isEmpty ? "flbk" : fsd, fbu.isEmpty ? "default.json" : fbu]
                str = "https://\(flbk[0]).izooto.com/\(flbk[1])"
                
                let izUrlString = (str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                if let url = URL(string: izUrlString ?? "") {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data)
                                if let jsonDictionary = json as? [String:Any] {
                                    if let apsDictionary = jsonDictionary as? NSDictionary {
                                        if let notificationData = Payload(dictionary: apsDictionary) {
                                            if let title = jsonDictionary[AppConstant.iZ_T_KEY] as? String {
                                                bestAttemptContent.title = title
                                                notificationData.alert?.title = title
                                            }
                                            if let body = jsonDictionary["m"] as? String {
                                                bestAttemptContent.body = body
                                                notificationData.alert?.body = body
                                            }
                                            if let url = notificationData.url, !url.isEmpty {
                                                if let newUrl = jsonDictionary["bi"] as? String {
                                                    notificationData.url = newUrl
                                                    if newUrl.contains(".webp") {
                                                        notificationData.url = newUrl.replacingOccurrences(of: ".webp", with: ".png")
                                                    }
                                                    if newUrl.contains("http:") {
                                                        notificationData.url = newUrl.replacingOccurrences(of: "http:", with: "https:")
                                                    }
                                                }
                                            }
                                            // Final payload which we get on notification click.
                                            var user = userInfo // Copy of the original userInfo
                                            if var aps = user?["aps"] as? [String: Any] {
                                                if var served = finalDataValue["served"] as? [String: Any] {
                                                    served["ln"] = jsonDictionary["ln"]
                                                    served["ti"] = jsonDictionary["t"]
                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    finalDataValue.setValue(t, forKey: "ta")
                                                    var updatedFinalDataValue = finalDataValue
                                                    updatedFinalDataValue["served"] = served
                                                    aps["fb"] = updatedFinalDataValue
                                                }else{
                                                    var served: [String: Any] = [:]
                                                    served["ln"] = notificationData.url
                                                    served["ti"] = "\(bestAttemptContent.title)"
                                                    finalDataValue["served"] = served
                                                    aps["fb"] = finalDataValue
                                                }
                                                if var finalAlertData = aps["alert"] as? [String: Any]{
                                                    finalAlertData["title"] = bestAttemptContent.title
                                                    finalAlertData["body"] = bestAttemptContent.body
                                                    if let binarImageUrl = jsonDictionary["bi"]{
                                                        finalAlertData["attachment-url"] = binarImageUrl
                                                    }
                                                    aps["alert"] = finalAlertData
                                                }
                                                if let falbackLandingUrl = jsonDictionary["ln"] {
                                                    aps["ln"] = falbackLandingUrl
                                                    let btn1Name = receivedNotification.act1name ?? receivedNotification.global?.act1name
                                                    let btn2Name = receivedNotification.act2name ?? receivedNotification.global?.act2name
                                                    if btn1Name != nil && btn1Name != ""{
                                                        aps["l1"] = falbackLandingUrl
                                                    }
                                                    if btn2Name != nil && btn2Name != ""{
                                                        aps["l2"] = falbackLandingUrl
                                                    }
                                                }
                                                if let cfg = jsonDictionary["cfg"]{
                                                    aps["cfg"] = cfg
                                                }
                                                if let ct = jsonDictionary["ct"]{
                                                    aps["ct"] = ct
                                                }
                                                if let rid = jsonDictionary["r"]{
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
                                            
                                            if fallCategory != ""{
                                                storeCategories(notificationData: receivedNotification, category: "")
                                                let act1 = receivedNotification.act1name ?? receivedNotification.global?.act1name
                                                if act1 != "" && act1 != nil{
                                                    addCTAButtons()
                                                }
                                            }
                                            //call Mediation impression
                                            if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                                                if let finalDict = aps["fb"] as? NSDictionary
                                                {
                                                    RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo)
                                                }
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                autoreleasepool {
                                                    guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.id, rid: notificationData.rid, imgUrl: notificationData.url ?? "", userInfo: userInfo, options: nil) else {
                                                        debugPrint(AppConstant.IMAGE_ERROR)
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
                            } catch let error {
                                
                                Utils.handleOnceException(bundleName: bundleName, exceptionName: "Fallback ad Api error\(error.localizedDescription)", className: "iZooto", methodName: "fallBackAdsApi", rid: notiRid , cid: "0", userInfo: userInfo)
                            }
                        }
                        
                    }.resume()
                }
            }
        }
    }
     
    /* Handling the payload data */
    @objc private static func payLoadDataChange(payload: [String:Any],bundleName: String, isBadge: Bool, isEnabled: Bool, soundName: String, userInfo: [AnyHashable : Any]?,bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?) {
        
        if let jsonDictionary = payload as? [String:Any] {
            if let aps = jsonDictionary["aps"] as? NSDictionary{
                finalDataValue.removeAllObjects()
                if let category = aps.value(forKey: "category"){
                    tempData.setValue(category, forKey: "category")
                }
                if let alert = aps.value(forKey: AppConstant.iZ_ALERTKEY) {
                    if let data = alert as? [String : Any] {
                        alertData = data
                    }
                    tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                    tempData.setValue(1, forKey: "mutable-content")
                    tempData.setValue(0, forKey: "content_available")
                }
                if let g = aps.value(forKey: AppConstant.iZ_G_KEY), let gt = aps.value(forKey: AppConstant.iZ_G_KEY) as? NSDictionary {
                    if let gdata = gt as? [String : Any] {
                        gData = gdata
                    }
                    tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                    let groupName = "group."+bundleName+".iZooto"
                    if let userDefaults = UserDefaults(suiteName: groupName) {
                        if let pid = userDefaults.string(forKey: AppConstant.REGISTERED_ID),
                           let token = userDefaults.value(forKey: AppConstant.IZ_GRPS_TKN){
                            finalDataValue.setValue(pid, forKey: "pid")
                            finalDataValue.setValue(token, forKey: "bKey")
                        }else{
                            finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_IDKEY)) as? String, forKey: "pid")
                        }
                    }
                    finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_RKEY)) as? String, forKey: "rid")
                    finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_TPKEY)) as? String, forKey: "type")
                    finalDataValue.setValue("0", forKey: "result")
                    finalDataValue.setValue(RestAPI.SDKVERSION, forKey: "av")
                    
                    //tp = 4
                    if (gt.value(forKey: AppConstant.iZ_TPKEY)) as? String == "4" {
                        if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                            let startDate = Date()
                            bidsData.removeAll()
                            
                            if let dict = anKey[0] as? [String : Any] {
                                if let firstElement = anKey[0] as? [String: Any] {
                                    anData = [firstElement]
                                }
                                tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                finalData["aps"] = tempData
                                if let apsDictionary = finalData["aps"] as? NSDictionary {
                                    if var notificationData = Payload(dictionary: apsDictionary){
                                        if(notificationData.global?.rid != nil && notificationData.global?.created_on != nil)
                                        {
                                            // to handle badgeCount, Sound, and call impression
                                            setupBadgeSoundAndHandleImpression(bundleName: bundleName, isBadge: isBadge, bestAttemptContent: bestAttemptContent, notificationData: notificationData, userInfo: userInfo, isEnabled: isEnabled, soundName: soundName)
                                            
                                            //Relevance Score
                                            self.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                                            DispatchQueue.main.async {
                                                let fuValue = dict["fu"] as? String ?? ""
                                                cpcValue = dict["cpc"] as? String ?? ""
                                                cprValue = dict["ctr"] as? String ?? ""
                                                let cpmValue = dict["cpm"] as? String ?? ""
                                                
                                                if cpcValue != ""{
                                                    cpcFinalValue = cpcValue
                                                }else{
                                                    cpcFinalValue = cpmValue
                                                }
                                                let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                                                let session: URLSession = {
                                                    let configuration = URLSessionConfiguration.default
                                                    configuration.timeoutIntervalForRequest = 2
                                                    return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                                                }()
                                                if let url = URL(string: izUrlString ?? "") {
                                                    session.dataTask(with: url) { data, response, error in
                                                        if(error != nil)
                                                        {
                                                            self.falbackBidsTp4(startDate: startDate)
                                                            if let notificationRid = notificationData.global?.rid {
                                                                fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                                return
                                                            }
                                                            
                                                        }
                                                        if let data = data {
                                                            do {
                                                                let json = try JSONSerialization.jsonObject(with: data)
                                                                //To Check FallBack
                                                                if let jsonDictionary = json as? [String:Any] {
                                                                    if let value = jsonDictionary["msgCode"] as? String {
                                                                        debugPrint(value)
                                                                        self.falbackBidsTp4(startDate: startDate)
                                                                        if let notificationRid = notificationData.global?.rid {
                                                                            fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                                            return
                                                                        }
                                                                    }else{
                                                                        if let jsonDictionary = json as? [String: Any] {
                                                                            if cpmValue != "" {
                                                                                if let cpcString = getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue) as? String,
                                                                                   let cpcValue = Double(cpcString),
                                                                                   let cprValue = Double(cprValue) {
                                                                                    finalCPCValue = String(cpcValue / (10 * cprValue))
                                                                                } else {
                                                                                    finalCPCValue = "0.0"
                                                                                    print("Failed to calculate finalCPCValue")
                                                                                }
                                                                            } else {
                                                                                finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                            }
                                                                            let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                            let finalCPCValueDouble = Double(finalCPCValue) ?? 0.0
                                                                            let finalCPC = Double(floor(finalCPCValueDouble * 10000) / 10000)
                                                                            servedData = [AppConstant.iZ_A_KEY: 1,AppConstant.iZ_B_KEY: finalCPC,AppConstant.iZ_T_KEY: t,AppConstant.iZ_RETURN_BIDS: finalCPC]
                                                                            finalDataValue.setValue("1", forKey: "result")
//                                                                            bidsData.append(servedData)
                                                                            
                                                                            // get title
                                                                            processNotificationData(notificationData: &notificationData, jsonDictionary: jsonDictionary, apsDictionary: apsDictionary, bundleName: bundleName)
                                                                        }
                                                                    }
                                                                }else{
                                                                    if let jsonArray = json as? [[String:Any]] {
                                                                        if jsonArray[0]["msgCode"] is String{
                                                                            self.falbackBidsTp4(startDate: startDate)
                                                                            if let notiRid = notificationData.global?.rid {
                                                                                fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notiRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                                            }
                                                                            return
                                                                        }else{
                                                                            if cpmValue != "" {
                                                                                if let cpcString = getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue) as? String,
                                                                                   let cpcValue = Double(cpcString),
                                                                                   let cprValue = Double(cprValue) {
                                                                                    finalCPCValue = String(cpcValue / (10 * cprValue))
                                                                                }else {
                                                                                    finalCPCValue = "0.0"
                                                                                    print("Failed to calculate finalCPCValue")
                                                                                }
                                                                            } else {
                                                                                finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                                                            }
                                                                            let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                            let finalCPCValueDouble = Double(finalCPCValue) ?? 0.0
                                                                            let finalCPC = Double(floor(finalCPCValueDouble * 10000) / 10000)
                                                                            servedData = [AppConstant.iZ_A_KEY: 1,AppConstant.iZ_B_KEY: finalCPC,AppConstant.iZ_T_KEY: t,AppConstant.iZ_RETURN_BIDS: finalCPC]
                                                                            finalDataValue.setValue("1", forKey: "result")
//                                                                            bidsData.append(servedData)
                                                                            
                                                                            
                                                                            //title
                                                                            processArrayNotificationData(notificationData: &notificationData, jsonArray: jsonArray)
                                                                        }
                                                                    }
                                                                }
                                                                if notificationData.category != "" && notificationData.category != nil
                                                                {
                                                                    storeCategories(notificationData: notificationData, category: "")
                                                                    if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                                                                        addCTAButtons()
                                                                    }
                                                                }
                                                                //Bids & Served
                                                                
                                                                let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                finalDataValue.setValue(ta, forKey: "ta")
                                                                finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                                finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                                
                                                                finalNotificationPayload(userInfo: userInfo, notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                                                                
                                                                if notificationData.ankey?.adrv != nil{
                                                                    if let rvArr = notificationData.ankey?.adrv{
                                                                        for url in rvArr {
                                                                            RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: url)
                                                                        }
                                                                    }
                                                                }

                                                                if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                                                                    if let finalDict = aps["fb"] as? NSDictionary
                                                                    {
                                                                        RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo)
                                                                    }
                                                                }
                                                                
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                                    autoreleasepool {
                                                                        guard let string = notificationData.ankey?.bannerImageAd else { return }
                                                                        guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.global?.id, rid: notificationData.global?.rid, imgUrl:notificationData.ankey?.bannerImageAd ?? "", userInfo: userInfo , options: nil) else {
                                                                            debugPrint(AppConstant.IMAGE_ERROR)
                                                                            contentHandler?(bestAttemptContent)
                                                                            return
                                                                        }
                                                                        bestAttemptContent.attachments = [ attachment ]
                                                                    }
                                                                    contentHandler?(bestAttemptContent)
                                                                }
                                                                
                                                            } catch {
                                                                if let rID = notificationData.global?.rid {
                                                                    self.falbackBidsTp4(startDate: startDate)
                                                                    self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: rID, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                                }
                                                            }
                                                        }
                                                    }.resume()
                                                }else{
                                                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "FetchUrl error for tp 4\(izUrlString ?? "")", className: "iZooto", methodName: "payLoadDataChange", rid: gt.value(forKey: "r") as? String ?? nil , cid: gt.value(forKey: "id") as? String ?? nil, userInfo: userInfo)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //tp = 5
                    else if let value = gt.value(forKey: AppConstant.iZ_TPKEY) as? String, value == "5" {
                        if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                            finalData["aps"] = tempData
                            if let apsDictionary = finalData["aps"] as? NSDictionary {
                                if let notificationData = Payload(dictionary: apsDictionary){
                                    
                                    //Relevance Score
                                    self.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                                    
                                    // to handle badgeCount, Sound, and call impression
                                    setupBadgeSoundAndHandleImpression(bundleName: bundleName, isBadge: isBadge, bestAttemptContent: bestAttemptContent, notificationData: notificationData, userInfo: userInfo, isEnabled: isEnabled, soundName: soundName)
                                }
                            }
                            self.succ = "false"
                            bidsData.removeAll()
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
                            self.fuCount = 0
                            callFetchUrlForTp5(fuArray: fuDataArray, urlString: fuDataArray[0], anKey: anKey, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        }
                    }
                    //tp = 6
                    else {
                        if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                            let startDate = Date()
                            bidsData.removeAll()
                            var winnerData: Payload? = nil
                            var winnerCpc : Double = 0.0
                            var fuCount: Int = 0
                            var winnerServed: [String:Any] = [:]
                            let myGroup = DispatchGroup()
                            var taboolaAnKey: [String: Any]?
                            var pfIndex: Int?
                            finalCPCValue = "0.0"
                            
                            for (index,valueDict) in anKey.enumerated()   {
                                if let dict = valueDict as? [String: Any] {
                                    myGroup.enter()
                                    if let element = anKey[index] as? [String: Any] {
                                        anData = [element]
                                    }
                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                    finalData["aps"] = tempData
                                    if let apsDictionary = finalData["aps"] as? NSDictionary {
                                        if var notificationData = Payload(dictionary: apsDictionary){
                                            if(notificationData.global?.rid != nil && notificationData.global?.created_on != nil)
                                            {
                                                
                                                var cpcFinalValue = ""
                                                var cpcValue = ""
                                                var ctrValue = ""
                                                var cpmValue = ""
                                                var fpValue: Double = 0.0
                                                let fuValue = dict["fu"] as? String ?? ""
                                                cpcValue = dict["cpc"] as? String ?? ""
                                                ctrValue = dict["ctr"] as? String ?? ""
                                                cpmValue = dict["cpm"] as? String ?? ""
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
                                                let session: URLSession = {
                                                    let configuration = URLSessionConfiguration.default
//                                                    configuration.timeoutIntervalForRequest = 2
                                                    return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                                                }()
                                                if let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)){
                                                    if let url = URL(string: izUrlString) {
                                                        session.dataTask(with: url) { data, response, error in
                                                            if(error != nil)
                                                            {
                                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                                fuCount += 1
                                                            }
                                                            if let data = data {
                                                                do {
                                                                    let json = try JSONSerialization.jsonObject(with: data)
                                                                    //To Check FallBack
                                                                    if let jsonDictionary = json as? [String:Any] {
                                                                        if let value = jsonDictionary["msgCode"] as? String {
                                                                            debugPrint(value)
                                                                            let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                            bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                                        }else{
                                                                            if let jsonDictionary = json as? [String: Any] {
                                                                                if cpmValue != "" {
                                                                                    if let cpcString = getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue) as? String,
                                                                                       let cpcValue = Double(cpcString),
                                                                                       let ctrValue = Double(ctrValue) {
                                                                                        finalCPCValue = String(cpcValue / (10 * ctrValue))
                                                                                    }else {
                                                                                        finalCPCValue = "0.0"
                                                                                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "Index : \(index+1), Cpc conversion into Double failled", className: "iZooto", methodName: "payloadDataChange1", rid: notificationData.global?.rid, cid: notificationData.global?.id, userInfo: userInfo)
                                                                                    }
                                                                                } else {
                                                                                    finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                                }
                                                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                                //                                                                                let finalCPCValueDouble = Double(finalCPCValue) ?? 0.0
                                                                                var finalCPCValueDouble = 0.0
                                                                                if let tempCpc = Double(finalCPCValue){
                                                                                    finalCPCValueDouble = tempCpc
                                                                                }else{
                                                                                    finalCPCValueDouble = 0.0
                                                                                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "Index : \(index+1), Cpc conversion into Double failled : \(finalCPCValue)", className: "iZooto", methodName: "payLoadDataChange2", rid: notificationData.global?.rid, cid: notificationData.global?.id, userInfo: userInfo)
                                                                                }
                                                                                let finalCPC = Double(floor(finalCPCValueDouble * 10000) / 10000)
                                                                                servedData = [AppConstant.iZ_A_KEY: index + 1,AppConstant.iZ_B_KEY: finalCPC,AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPC]
                                                                                if let servedDataDict = servedData as? [String: Any] {
                                                                                    winnerServed = servedDataDict
                                                                                }
                                                                                bidsData.append(servedData)
                                                                                
                                                                                // get title
                                                                                processNotificationData(notificationData: &notificationData, jsonDictionary: jsonDictionary, apsDictionary: apsDictionary, bundleName: bundleName)
                                                                            }
                                                                        }
                                                                    }else{
                                                                        if let jsonArray = json as? [[String:Any]] {//Adgebra
                                                                            
                                                                            if let value = jsonArray[0]["msgCode"] as? String{
                                                                                print(value)
                                                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                                bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                                            }else{
                                                                                if cpmValue != "" {
                                                                                    if let cpcString = getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue) as? String,
                                                                                       let cpcValue = Double(cpcString),
                                                                                       let ctrValue = Double(ctrValue) {
                                                                                        finalCPCValue = String(cpcValue / (10 * ctrValue))
                                                                                    }else{
                                                                                        finalCPCValue = "0.0"
                                                                                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "Index : \(index+1), Cpc conversion into Double failled", className: "iZooto", methodName: "payloadDataChange3", rid: notificationData.global?.rid, cid: notificationData.global?.id, userInfo: userInfo)
                                                                                    }
                                                                                } else {
                                                                                    finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                                                                }
                                                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                                //let finalCPCValueDouble = Double(finalCPCValue) ?? 0.0
                                                                                var finalCPCValueDouble = 0.0
                                                                                if let tempCpc = Double(finalCPCValue){
                                                                                    finalCPCValueDouble = tempCpc
                                                                                }else{
                                                                                    finalCPCValueDouble = 0.0
                                                                                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "Index : \(index+1), Cpc conversion into Double failled : \(finalCPCValue)", className: "iZooto", methodName: "payLoadDataChange4", rid: notificationData.global?.rid, cid: notificationData.global?.id, userInfo: userInfo)
                                                                                }
                                                                                let finalCPC = Double(floor(finalCPCValueDouble * 10000) / 10000)
                                                                                servedData = [AppConstant.iZ_A_KEY: index + 1,AppConstant.iZ_B_KEY: finalCPC,AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPC]
                                                                                if let servedDataDict = servedData as? [String: Any] {
                                                                                    winnerServed = servedDataDict
                                                                                }
                                                                                bidsData.append(servedData)
                                                                                //title
                                                                                processArrayNotificationData(notificationData: &notificationData, jsonArray: jsonArray)
                                                                            }
                                                                        }
                                                                    }
                                                                    fuCount += 1
                                                                    if let doubleCpc =  Double(finalCPCValue) {
                                                                        let finalCPC = Double(floor(doubleCpc * 10000) / 10000)
                                                                        if Double(finalCPCValue) ?? 0.0 > fpValue {
                                                                            if winnerCpc < finalCPC {
                                                                                winnerCpc = finalCPC
                                                                                winnerData = notificationData
                                                                                finalDataValue.setValue(winnerServed, forKey: AppConstant.iZ_SERVEDKEY)
                                                                                finalDataValue.setValue("\(index + 1)", forKey: "result")
                                                                            }
                                                                        }
                                                                    }
                                                                } catch let error {
                                                                    debugPrint(" Error",error)
                                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                    bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                                    fuCount += 1
                                                                }
                                                            }
                                                            if fuCount == (anKey as AnyObject).count{
                                                                //Relevance Score
                                                                self.setRelevanceScore(notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                                                                
                                                                // to handle badgeCount, Sound, and call impression
                                                                setupBadgeSoundAndHandleImpression(bundleName: bundleName, isBadge: isBadge, bestAttemptContent: bestAttemptContent, notificationData: notificationData, userInfo: userInfo, isEnabled: isEnabled, soundName: soundName)
                                                                
                                                                //Bids & Served
                                                                let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                finalDataValue.setValue(ta, forKey: "ta")
                                                                
                                                                // To save final served as per cpc
                                                                finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                                //completion(finalData)
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
                                                                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "Index : \(tIndex), Cpc conversion into Double failled : \(tcpc)", className: "iZooto", methodName: "payLoadDataChange5", rid: notificationData.global?.rid, cid: notificationData.global?.id, userInfo: userInfo)
                                                                    }
                                                                    let tfpValue = Double((Tdata["fp"] as? String)?.removingTilde() ?? "") ?? 0.0
                                                                    if (tfpValue < Tcpc) && (Tcpc > winnerCpc){
                                                                        servedData = [AppConstant.iZ_A_KEY: tIndex,AppConstant.iZ_B_KEY: Tcpc, AppConstant.iZ_T_KEY: ta, AppConstant.iZ_RETURN_BIDS: Tcpc]
                                                                        finalDataValue.setValue("\(tIndex)", forKey: "result")
                                                                        bidsData.append(servedData)
                                                                        finalDataValue.setValue(ta, forKey: "ta")
                                                                        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                                        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                                        self.taboolaAds(anKey: taboolaAnKey, index: tIndex, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                                        return
                                                                    }else{
                                                                        servedData = [AppConstant.iZ_A_KEY: tIndex, AppConstant.iZ_B_KEY: Tcpc, AppConstant.iZ_T_KEY: ta, AppConstant.iZ_RETURN_BIDS: Tcpc]
                                                                        bidsData.append(servedData)
                                                                        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                                    }
                                                                }
                                                                if let winnerPayload = winnerData {
                                                                    if notificationData.category != "" && notificationData.category != nil
                                                                    {
                                                                        storeCategories(notificationData: notificationData, category: "")
                                                                        if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                                                                            addCTAButtons()
                                                                        }
                                                                    }
                                                                    finalNotificationPayload(userInfo: userInfo, notificationData: winnerPayload, bestAttemptContent: bestAttemptContent)
                                                                    if winnerPayload.ankey?.adrv != nil{
                                                                        if let rvArr = winnerPayload.ankey?.adrv{
                                                                            for url in rvArr {
                                                                                RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: url)
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                                                                        if let finalDict = aps["fb"] as? NSDictionary
                                                                        {
                                                                            RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo)
                                                                        }
                                                                    }
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                                        autoreleasepool {
                                                                            guard let string = winnerPayload.ankey?.bannerImageAd else { return }
                                                                            guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.global?.id, rid: notificationData.global?.rid, imgUrl:winnerPayload.ankey?.bannerImageAd ?? "", userInfo: userInfo , options: nil) else {
                                                                                debugPrint(AppConstant.IMAGE_ERROR)
                                                                                contentHandler?(bestAttemptContent)
                                                                                return
                                                                            }
                                                                            bestAttemptContent.attachments = [ attachment ]
                                                                        }
                                                                        contentHandler?(bestAttemptContent)
                                                                    }
                                                                }else{
                                                                    if let rID = notificationData.global?.rid {
                                                                        self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: rID, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                                        return
                                                                    }
                                                                }
                                                                
                                                            }
                                                        }.resume()
                                                    }else{
                                                        
                                                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "error in tp 6 = \(izUrlString)", className: "iZooto", methodName: "payLoadDataChange",rid: gt.value(forKey: "r") as? String ?? nil , cid: gt.value(forKey: "id") as? String ?? nil, userInfo: userInfo)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    myGroup.leave()
                                }
                            }
                            myGroup.notify(queue: .main) {
//                                debugPrint("Task done")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static func falbackBidsTp4(startDate: Date){
        let t = Int(Date().timeIntervalSince(startDate) * 1000)
        servedData = [AppConstant.iZ_A_KEY: 1,AppConstant.iZ_B_KEY: "0.0",AppConstant.iZ_T_KEY: t,AppConstant.iZ_RETURN_BIDS: "0.0"]
        finalDataValue.setValue("0", forKey: "result")
//        bidsData.append(servedData)
        finalDataValue.setValue(t, forKey: "ta")
        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
    }
    
    private static func processArrayNotificationData(notificationData: inout Payload, jsonArray: [[String: Any]]) { //for adgebra notification
        // Update title and message
        if let adTitle = notificationData.ankey?.titleAd,
           let adMessage = notificationData.ankey?.messageAd {
            notificationData.alert?.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: adTitle))"
            notificationData.alert?.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: adMessage))"
            notificationData.ankey?.titleAd = notificationData.alert?.title
            notificationData.ankey?.messageAd = notificationData.alert?.body
        }
        
        // Update landing URL
        if var landUrl = notificationData.ankey?.landingUrlAd {
            landUrl = "\(getParseArrayValue(jsonData: jsonArray, sourceString: landUrl))"
            notificationData.ankey?.landingUrlAd = landUrl
        }
        
        // Update banner image
        if let bannerImage = notificationData.ankey?.bannerImageAd, !bannerImage.isEmpty {
            var parsedBannerImage = "\(getParseArrayValue(jsonData: jsonArray, sourceString: bannerImage))"
            
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
        
        //CTA Button url
        if let action1url = notificationData.ankey?.act1link,
           notificationData.global?.act1name != nil{
            notificationData.ankey?.act1link = getParseArrayValue(jsonData: jsonArray, sourceString: action1url)
        }
        if let action2url = notificationData.ankey?.act2link,
           notificationData.global?.act2name != nil{
            notificationData.ankey?.act2link = getParseArrayValue(jsonData: jsonArray, sourceString: action2url)
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

    
    private static func processNotificationData(notificationData: inout Payload, jsonDictionary: [String: Any], apsDictionary: NSDictionary,bundleName: String) {
        
        if let title = notificationData.ankey?.titleAd,
           let message = notificationData.ankey?.messageAd {
            notificationData.ankey?.titleAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: title))"
            notificationData.ankey?.messageAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: message))"
            notificationData.alert?.title = notificationData.ankey?.titleAd
            notificationData.alert?.body = notificationData.ankey?.messageAd
        }
        
        // Parse and update landing URL
        if var landUrl = notificationData.ankey?.landingUrlAd {
            landUrl = "\(getParseValue(jsonData: jsonDictionary, sourceString: landUrl))"
            notificationData.ankey?.landingUrlAd = landUrl
        }
        
        // Parse and update banner image
        if notificationData.ankey?.bannerImageAd != "" {
            if let imageAd = notificationData.ankey?.bannerImageAd {
                var parsedImageAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: imageAd))"
                
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
        
        if let action1url = notificationData.ankey?.act1link,
           notificationData.global?.act1name != nil{
            notificationData.ankey?.act1link = getParseValue(jsonData: jsonDictionary, sourceString: action1url)
        }
        if let action2url = notificationData.ankey?.act2link,
           notificationData.global?.act2name != nil{
            notificationData.ankey?.act2link = getParseValue(jsonData: jsonDictionary, sourceString: action2url)
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

    
    private static func taboolaAds(anKey: [String:Any]?, index: Int, bundleName: String, userInfo: [AnyHashable : Any]?, bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)?){
        if let anData = anKey, let fuUrl = anData["fu"]{
            let startDate = Date()
            tempData.setValue([anData], forKey: AppConstant.iZ_ANKEY)
            finalData["aps"] = tempData
            finalDataValue.setValue([], forKey: AppConstant.iZ_SERVEDKEY)
            if let apsDictionary = finalData["aps"] as? NSDictionary {
                if var notificationData = Payload(dictionary: apsDictionary){
                    if(notificationData.global?.rid != nil && notificationData.global?.created_on != nil)
                    {
                        let session: URLSession = {
                            let configuration = URLSessionConfiguration.default
                            configuration.timeoutIntervalForRequest = 2
                            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                        }()
                        if let url = URL(string: fuUrl as? String ?? "") {
                            session.dataTask(with: url) { data, response, error in
                                if(error != nil)
                                {
                                    finalDataValue.setValue("0", forKey: "result")
                                    self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    return
                                }
                                if let data = data {
                                    do {
                                        let json = try JSONSerialization.jsonObject(with: data)
                                        //To Check FallBack
                                        if let jsonDictionary = json as? [String:Any] {
                                            if let value = jsonDictionary["msgCode"] as? String {
                                                debugPrint(value)
                                                finalDataValue.setValue("\(index)", forKey: "result")
                                                if let rID = notificationData.global?.rid {
                                                    self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: rID, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                }
                                            }else{
                                                if let jsonDictionary = json as? [String:Any] {
                                                    // get title
                                                    processNotificationData(notificationData: &notificationData, jsonDictionary: jsonDictionary, apsDictionary: apsDictionary, bundleName: bundleName)
                                                }
                                            }
                                        } else {
                                            if let jsonArray = json as? [[String:Any]] {//if adgebra has pf = 1.
                                                if let value = jsonArray[0]["msgCode"] as? String{
                                                    print(value)
                                                    finalDataValue.setValue("\(index)", forKey: "result")
                                                    if let notiRid = notificationData.global?.rid {
                                                        fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notiRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                    }
                                                    return
                                                }else{
                                                    //title
                                                    processArrayNotificationData(notificationData: &notificationData, jsonArray: jsonArray)
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
                                            storeCategories(notificationData: notificationData, category: "")
                                            if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                                                addCTAButtons()
                                            }
                                        }
                                        finalNotificationPayload(userInfo: userInfo, notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                                        //call impression
                                        if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                                            if let finalDict = aps["fb"] as? NSDictionary
                                            {
                                                RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo)
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
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            autoreleasepool {
                                                guard let string = notificationData.ankey?.bannerImageAd else { return }
                                                guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.global?.id, rid: notificationData.global?.rid, imgUrl:notificationData.ankey?.bannerImageAd ?? "", userInfo: userInfo , options: nil) else {
                                                    debugPrint(AppConstant.IMAGE_ERROR)
                                                    contentHandler?(bestAttemptContent)
                                                    return
                                                }
                                                bestAttemptContent.attachments = [ attachment ]
                                            }
                                            contentHandler?(bestAttemptContent)
                                        }
                                    } catch let error {
                                        finalDataValue.setValue("0", forKey: "result")
                                        if let rID = notificationData.global?.rid {
                                            self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: rID, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                        }
                                    }
                                }
                            }.resume()
                        }
                    }else{
                        finalDataValue.setValue("0", forKey: "result")
                        self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationData.global?.rid ?? "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "Other Payload", className: "iZooto", methodName: "taboolaAds", rid: notificationData.global?.rid , cid: notificationData.global?.id, userInfo: userInfo)
                    }
                }
            }
        }else{
            finalDataValue.setValue("0", forKey: "result")
            self.fallBackAdsApi(bundleName: bundleName, fallCategory: "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
        }
    }
    
    @objc private static func callFetchUrlForTp5(fuArray: [String], urlString: String, anKey: NSArray, bundleName: String, userInfo: [AnyHashable : Any]?, bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)? ){
        let startDate = Date()
        let fu = fuArray[fuCount]
        if let dict = anKey[fuCount] as? NSDictionary {
            if let firstElement = anKey[fuCount] as? [String: Any] {
                anData = [firstElement]
            }
            tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
            finalData["aps"] = tempData
            if let apsDictionary = finalData["aps"] as? NSDictionary {
                if var notificationData = Payload(dictionary: apsDictionary){
                    if(notificationData.global?.rid != nil && notificationData.global?.created_on != nil)
                    {
                        let cpmValue = dict["cpm"] as? String ?? ""
                        let ctrValue = dict["ctr"] as? String ?? ""
                        let cpcValue = dict["cpc"] as? String ?? ""
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
                        
                        if let url = URL(string: fu) {
                            session.dataTask(with: url) { data, response, error in
                                
                                if(error != nil)
                                {
                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00])
                                    if succ != "done"{
                                        fuCount += 1
                                        if fuArray.count > fuCount {
                                            callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                        }
                                    }
                                    if fuCount == anKey.count{
                                        servedData = [AppConstant.iZ_A_KEY: fuCount, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                                        finalDataValue.setValue(t, forKey: "ta")
                                        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                        //completion(finalData)
                                        if let notificationRid = notificationData.global?.rid {
                                            fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                            return
                                        }
                                    }
                                }
                                if let data = data {
                                    do {
                                        let json = try JSONSerialization.jsonObject(with: data)
                                        //To Check FallBack
                                        if let jsonDictionary = json as? [String:Any] {
                                            if let value = jsonDictionary["msgCode"] as? String {
                                                debugPrint("msgCode :",value)
                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS:0.00])
                                                if fuCount == anKey.count{
                                                    servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                                                    if let element = anKey[fuCount - 1] as? [String : Any] {
                                                        anData = [element]
                                                    }
                                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                    finalData["aps"] = tempData
                                                    //completion(finalData)
                                                    if let notificationRid = notificationData.global?.rid {
                                                        fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                        return
                                                    }
                                                }else{
                                                    if succ != "done"{
                                                        fuCount += 1
                                                        if fuArray.count > fuCount {
                                                            callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                        }
                                                    }
                                                }
                                            }else{
                                                if let jsonDictionary = json as? [String:Any] {
                                                    if cpmValue != "" {
                                                        let cpcString = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                        if let cpc = Double(cpcString),
                                                           let ctrValue = Double(ctrValue) {
                                                            finalCPCValue = String(cpc / (10 * ctrValue))
                                                        }else{
                                                            finalCPCValue = "0.0"
                                                        }
                                                    } else {
                                                        finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                    }
                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    let finalCPCValueDouble = Double(finalCPCValue) ?? 0.0
                                                    let finalCPCDouble = floor(finalCPCValueDouble * 10000) / 10000
                                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1,AppConstant.iZ_B_KEY: finalCPCDouble, AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCDouble])
                                                    if let anKeyDict = anKey[fuCount] as? [String: Any] {
                                                        anData = [anKeyDict]
                                                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                        finalData["aps"] = tempData
                                                    }
                                                    if succ != "done" {
                                                        succ = "true"
                                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1,AppConstant.iZ_B_KEY: finalCPCDouble,AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCDouble]
                                                        finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                                    }
                                                    
                                                    // get title
                                                    processNotificationData(notificationData: &notificationData, jsonDictionary: jsonDictionary, apsDictionary: apsDictionary, bundleName: bundleName)
                                                }
                                            }
                                        }else{
                                            if let jsonArray = json as? [[String:Any]] {
                                                if let value = jsonArray[0]["msgCode"] as? String{
                                                    print("msgCode : ",value)
                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00])
                                                    if fuCount == anKey.count{
                                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                                                        if let anKeyDict = anKey[fuCount] as? [String: Any] {
                                                            anData = [anKeyDict]
                                                        }
                                                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                        finalData["aps"] = tempData
                                                        //completion(finalData)
                                                        if let notificationRid = notificationData.global?.rid {
                                                            fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                            return
                                                        }
                                                    }else {
                                                        if succ != "done"{
                                                            fuCount += 1
                                                            if fuArray.count > fuCount {
                                                                callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                            }
                                                        }
                                                    }
                                                }else{
                                                    if cpmValue != "" {
                                                        let cpcString = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                                        if let cpc = Double(cpcString),
                                                           let ctrValue = Double(ctrValue) {
                                                            finalCPCValue = String(cpc / (10 * ctrValue))
                                                        }else{
                                                            finalCPCValue = "0.0"
                                                        }
                                                    } else {
                                                        finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                                    }
                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    let finalCPCValueDouble = Double(finalCPCValue) ?? 0.0
                                                    let finalCPCDouble = floor(finalCPCValueDouble * 10000) / 10000
                                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: finalCPCDouble, AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCDouble])
                                                    if let anKeyDict = anKey[fuCount] as? [String: Any] {
                                                        anData = [anKeyDict]
                                                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                        finalData["aps"] = tempData
                                                    }
                                                    if succ != "done" {
                                                        succ = "true"
                                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: finalCPCDouble, AppConstant.iZ_T_KEY: t, AppConstant.iZ_RETURN_BIDS: finalCPCDouble]
                                                        finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                                    }
                                                    
                                                    //title
                                                    processArrayNotificationData(notificationData: &notificationData, jsonArray: jsonArray)
                                                }
                                            }
                                        }
                                    } catch let error {
                                        if !error.localizedDescription.isEmpty{
                                            let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                            bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00])
                                            if succ != "done"{
                                                fuCount += 1
                                                if fuArray.count > fuCount {
                                                    callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                }
                                            }
                                            if fuCount == anKey.count{
                                                //completion(finalData)
                                                if let notificationRid = notificationData.global?.rid {
                                                    fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: notificationRid, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                    return
                                                }
                                            }
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
                                            storeCategories(notificationData: notificationData, category: "")
                                            if let act1 = notificationData.global?.act1name, !act1.isEmpty {
                                                addCTAButtons()
                                            }
                                        }
                                        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                        finalNotificationPayload(userInfo: userInfo, notificationData: notificationData, bestAttemptContent: bestAttemptContent)
                                        if notificationData.ankey?.adrv != nil{
                                            if let rvArr = notificationData.ankey?.adrv{
                                                for url in rvArr {
                                                    RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: url)
                                                }
                                            }
                                        }
                                        //call impression
                                        if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                                            if let finalDict = aps["fb"] as? NSDictionary
                                            {
                                                RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo)
                                            }
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            autoreleasepool {
                                                guard let string = notificationData.ankey?.bannerImageAd else { return }
                                                guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.global?.id, rid: notificationData.global?.rid, imgUrl:notificationData.ankey?.bannerImageAd ?? "", userInfo: userInfo , options: nil) else {
                                                    debugPrint(AppConstant.IMAGE_ERROR)
                                                    contentHandler?(bestAttemptContent)
                                                    return
                                                }
                                                bestAttemptContent.attachments = [ attachment ]
                                            }
                                            
                                            
                                            contentHandler?(bestAttemptContent)
                                        }
                                        return
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
        }
    }
    
    // Handle the payload and show the notification
    @available(iOS 11.0, *)
    @objc public static func didReceiveNotificationExtensionRequest(bundleName : String,soundName :String,isBadge : Bool,
                                                                    request : UNNotificationRequest, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
    {
        let groupName = "group."+bundleName+".iZooto"
        let userInfo = request.content.userInfo
        let isEnabled = false
        if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
            let appId = userDefaults.value(forKey: "appID") as? String ?? ""
            if appId.isEmpty {
                let errorMessage = "Bundle name mismatch: Please ensure the bundle name in the NotificationService class matches the main app's bundle identifier. A mismatch can affect push notifications, badge count, delivery and impressions."
                debugPrint(errorMessage)
                Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(errorMessage) , your bundle name is :\(bundleName)", className: "iZooto", methodName: "didReceiveNotification", rid: nil, cid: nil, userInfo: userInfo)
            }
        }
        if let jsonDictionary = userInfo as? [String:Any] {
            if let aps = jsonDictionary["aps"] as? NSDictionary{
                if aps.value(forKey: AppConstant.iZ_ANKEY) != nil {
                    if let userInfoData = userInfo as? [String: Any] {
                        self.payLoadDataChange(payload: userInfoData, bundleName: bundleName, isBadge: isBadge, isEnabled: isEnabled, soundName: soundName, userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                    }
                }else{
                    //to get all aps data & pass it to commonfu function
                    if let totalData = userInfo["aps"] as? NSDictionary {
                        if let apsDictionary = userInfo["aps"] as? NSDictionary {
                            if var notificationData = Payload(dictionary: apsDictionary){
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
                                    //fetcher
                                    let startDate = Date()
                                    bidsData.removeAll()
                                    finalDataValue.removeAllObjects()
                                    servedData.removeAllObjects()
                                    if let userDefaults = UserDefaults(suiteName: groupName) {
                                        if let pid = userDefaults.string(forKey: AppConstant.REGISTERED_ID),
                                           let token = userDefaults.value(forKey: AppConstant.IZ_GRPS_TKN){
                                            finalDataValue.setValue(pid, forKey: "pid")
                                            finalDataValue.setValue(token, forKey: "bKey")
                                        }
                                    }
                                    
                                    let served: [String: Any] = ["a": 0, "b": 0, "t":-1]
                                    let bids: [String] = []
                                    finalDataValue.setValue(bids, forKey: "bids")
                                    finalDataValue.setValue(notificationData.rid, forKey: "rid")
                                    finalDataValue.setValue(RestAPI.SDKVERSION, forKey: "av")
                                    finalDataValue.setValue(served, forKey: "served")
                                    
                                    let izUrlString = (notificationData.fetchurl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                                    let session: URLSession = {
                                        let configuration = URLSessionConfiguration.default
                                        configuration.timeoutIntervalForRequest = 2
                                        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                                    }()
                                    if let url = URL(string: izUrlString ?? "") {
                                        session.dataTask(with: url) { data, response, error in
                                            if(error != nil)
                                            {
                                                fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                return
                                            }
                                            if let httpResponse = response as? HTTPURLResponse {
                                                if httpResponse.statusCode != 200 {
                                                    fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                    return
                                                }
                                            }
                                            if let data = data {
                                                do {
                                                    let json = try JSONSerialization.jsonObject(with: data)
                                                    //To Check FallBack
                                                    if let jsonDictionary = json as? [String:Any] {
                                                        if let value = jsonDictionary["msgCode"] as? String {
                                                            print("msgCode Found ",value)
                                                            fallBackAdsApi(bundleName: bundleName,fallCategory: notificationData.category ?? "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                            return
                                                        }else{
                                                            if let jsonDictionary = json as? [String:Any] {
                                                                
                                                                if let title = notificationData.alert?.title, let bodyData = notificationData.alert?.body {
                                                                    notificationData.alert?.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: title))"
                                                                    notificationData.alert?.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: bodyData))"
                                                                }
                                                                if let url = notificationData.url, !url.isEmpty {
                                                                    notificationData.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: url))"
                                                                }
                                                                if let url = notificationData.alert?.attachment_url, !url.isEmpty {
                                                                    
                                                                    notificationData.alert?.attachment_url = "\(getParseValue(jsonData: jsonDictionary, sourceString: url))"
                                                                    if let webUrl = notificationData.alert?.attachment_url, webUrl.contains(".webp") {
                                                                        notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpeg")
                                                                    }
                                                                    if let httpUrl = notificationData.alert?.attachment_url, httpUrl.contains("http:"){
                                                                        notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: "http:", with: "https:")
                                                                    }
                                                                }
                                                                if let action1url = notificationData.act1link,
                                                                   notificationData.act1name != nil{
                                                                    notificationData.act1link = getParseValue(jsonData: jsonDictionary, sourceString: action1url)
                                                                }
                                                                if let action2url = notificationData.act2link,
                                                                   notificationData.act2link != nil{
                                                                    notificationData.act2link = getParseValue(jsonData: jsonDictionary, sourceString: action2url)
                                                                }

                                                                //get the value of RV for outbrain
                                                                if notificationData.furv != nil{
                                                                    if let rv = notificationData.furv{
                                                                        for url in rv{
                                                                            let finalUrl = getParseValue(jsonData: jsonDictionary, sourceString: url)
                                                                            RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: finalUrl)
                                                                        }
                                                                    }
                                                                }
                                                                //get the value of RC for outbrain
                                                                if notificationData.furc != nil {
                                                                    var urlArr: [String] = []
                                                                    if let val = notificationData.furc {
                                                                        for urlStr in val {
                                                                            urlArr.append(getParseValue(jsonData: jsonDictionary, sourceString: urlStr))
                                                                        }
                                                                    }
                                                                    notificationData.furc = urlArr
                                                                }
                                                            }
                                                        }
                                                    }else{
                                                        if let jsonArray = json as? [[String:Any]] {
                                                            if jsonArray[0]["msgCode"] is String {
                                                                fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                                return
                                                            }else{
                                                                
                                                                if let title = notificationData.alert?.title, let bodyData = notificationData.alert?.body {
                                                                    notificationData.alert?.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: title))"
                                                                    notificationData.alert?.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: bodyData))"
                                                                }
                                                                if let url = notificationData.url, !url.isEmpty {
                                                                    notificationData.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: url))"
                                                                }
                                                                if let urlStr = notificationData.alert?.attachment_url , !urlStr.isEmpty {
                                                                    notificationData.alert?.attachment_url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: urlStr))"
                                                                    if let urlStr = notificationData.alert?.attachment_url , urlStr.contains(".webp") {
                                                                        notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpg")
                                                                    }
                                                                }
                                                                if let action1url = notificationData.act1link,
                                                                   notificationData.act1name != nil{
                                                                    notificationData.act1link = getParseArrayValue(jsonData: jsonArray, sourceString: action1url)
                                                                }
                                                                if let action2url = notificationData.act2link,
                                                                   notificationData.act2link != nil{
                                                                    notificationData.act2link = getParseArrayValue(jsonData: jsonArray, sourceString: action2url)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    if notificationData.category != "" && notificationData.category != nil
                                                    {
                                                        storeCategories(notificationData: notificationData, category: "")
                                                        if notificationData.act1name != "" && notificationData.act1name != nil{
                                                            addCTAButtons()
                                                        }
                                                    }
                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    finalDataValue.setValue(t, forKey: "ta")
                                                    //final Payload.
                                                    var user = userInfo
                                                    if var aps = user["aps"] as? [String: Any] {
                                                        if let finalAlert = notificationData.alert {
                                                            aps["alert"] = finalAlert.dictionaryRepresentation() as? [String: Any]
                                                            if let title = finalAlert.title,  let body = finalAlert.body{
                                                                bestAttemptContent.title = title
                                                                bestAttemptContent.body = body
                                                            }
                                                            aps["ln"] = notificationData.url
                                                        }
                                                        aps["fb"] = finalDataValue
                                                        if var served = finalDataValue["served"] as? [String: Any]{
                                                            served["ln"] = notificationData.url
                                                            served["ti"] = bestAttemptContent.title
                                                            let updatedFinalDataValue = finalDataValue
                                                            updatedFinalDataValue["served"] = served
                                                            aps["fb"] = updatedFinalDataValue
                                                        }
                                                        //act1Link
                                                        if notificationData.act1name != nil && notificationData.act1link != nil{
                                                            aps["l1"] = notificationData.act1link
                                                        }
                                                        if notificationData.act2name != nil && notificationData.act2link != nil{
                                                            aps["l2"] = notificationData.act2link
                                                        }
                                                        //get the value of RC for outbrain
                                                        if notificationData.furc != nil {
                                                            aps["rc"] = notificationData.furc
                                                        }
                                                        user["aps"] = aps
                                                    }
                                                    if let validUser = user as? [String: Any] {
                                                        bestAttemptContent.userInfo = validUser
                                                    }
                                                    
                                                    if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                                                        if let finalDict = aps["fb"] as? NSDictionary
                                                        {
                                                            RestAPI.callAdMediationImpressionApi(finalDict: finalDict, bundleName: bundleName, userInfo: userInfo)
                                                        }
                                                    }
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                        autoreleasepool {
                                                            guard let string = notificationData.alert?.attachment_url else {return}
                                                            guard let attachment = UNNotificationAttachment.saveImageToDisk(bundleName: bundleName, cid: notificationData.id, rid: notificationData.rid, imgUrl: notificationData.alert?.attachment_url ?? "", userInfo: userInfo, options: nil) else {
                                                                debugPrint(AppConstant.IMAGE_ERROR)
                                                                contentHandler?(bestAttemptContent)
                                                                return
                                                            }
                                                            bestAttemptContent.attachments = [ attachment ]
                                                        }
                                                        contentHandler?(bestAttemptContent)
                                                    }
                                                } catch {
                                                    self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: "", userInfo: userInfo, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                                    return
                                                }
                                            }
                                        }.resume()
                                    }else{
                                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "Fetcher url is not in correct format\(String(describing: izUrlString))", className: "iZooto", methodName: "didReceiveNoti",rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
                                    }
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
                                            storeCategories(notificationData: notificationData, category: "")
                                            if notificationData.act1name != "" && notificationData.act1name != nil {
                                                addCTAButtons()
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
    }
    
    // To handle badgeCount, Sound and call impression
    @objc public static func setupBadgeSoundAndHandleImpression( bundleName: String, isBadge: Bool, bestAttemptContent :UNMutableNotificationContent, notificationData: Payload, userInfo: [AnyHashable : Any]? , isEnabled: Bool, soundName:String) {
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
    
    @objc static func finalNotificationPayload(userInfo: [AnyHashable: Any]?, notificationData: Payload, bestAttemptContent: UNMutableNotificationContent) {
        var user = userInfo
        if var aps = user?["aps"] as? [String: Any] {
            aps["fb"] = finalDataValue
            if var served = finalDataValue["served"] as? [String: Any] {
                served["ln"] = notificationData.ankey?.landingUrlAd
                served["ti"] = notificationData.alert?.title
                var updatedFinalDataValue = finalDataValue
                updatedFinalDataValue["served"] = served
                aps["fb"] = updatedFinalDataValue
            }
            
            if notificationData.ankey?.adrc != nil {
                aps["rc"] = notificationData.ankey?.adrc
            }
            
            if let finalAlert = notificationData.alert {
                aps["alert"] = finalAlert.dictionaryRepresentation() as? [String: Any]
                if let title = finalAlert.title,  let body = finalAlert.body{
                    bestAttemptContent.title = title
                    bestAttemptContent.body = body
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
                    aps["ln"] = ln
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
            user?["aps"] = aps
        }
        if let validUser = user as? [AnyHashable: Any] {
            bestAttemptContent.userInfo = validUser
        }
    }
    
    //To store category Id & CTA Buttons
    @objc private static func storeCategories(notificationData: Payload, category : String){
        categoryArray.removeAll()
        
        var categoryId = ""
        var button1Name = ""
        var button2Name = ""
        
        if category != ""{
            categoryId = category
            button1Name = "Sponsered"
            
        }else{
            if notificationData.global?.act1name != nil && notificationData.global?.act1name != ""{
                categoryId = notificationData.category ?? ""
                button1Name = notificationData.global?.act1name ?? ""
                button2Name = notificationData.global?.act2name ?? ""
            }else{
                if notificationData.act1name != "" && notificationData.act1name != nil  {
                    categoryId = notificationData.category ?? ""
                    button1Name = notificationData.act1name ?? ""
                    button2Name = notificationData.act2name ?? ""
                }
            }
        }
        
        let catDict  = [AppConstant.iZ_catId: categoryId , AppConstant.iZ_b1Name:  button1Name, AppConstant.iZ_b2Name: button2Name]
        categoryArray.append(catDict)
        
        var tempArray: [[String : Any]] = []
        if UserDefaults.standard.value(forKey: AppConstant.iZ_CategoryArray) != nil {
            if let tempAry = UserDefaults.standard.value(forKey: AppConstant.iZ_CategoryArray) as? [[String : Any]] {
                tempArray = tempAry
            }
        }
        let CategoryMaxCount = 100
        tempArray.append(contentsOf: categoryArray)
        if tempArray.count >= CategoryMaxCount{
            tempArray.removeFirst()
        }
        UserDefaults.standard.setValue(tempArray, forKey: AppConstant.iZ_CategoryArray)
        UserDefaults.standard.synchronize()
    }
    
    //To register Dynamic category nd Actionable buttons on notifications...
    @objc private static func addCTAButtons(){
        
        var notificationCategories: Set<UNNotificationCategory> = []
        let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
        var catArray = [Any]()
        if UserDefaults.standard.array(forKey: AppConstant.iZ_CategoryArray)?.count != 0{
            if let catArr = UserDefaults.standard.array(forKey: AppConstant.iZ_CategoryArray){
                catArray = catArr
            }
        }
        
        if !catArray.isEmpty{
            for item in catArray{
                let dict = item as? NSDictionary
                let categoryId = dict?.value(forKey: AppConstant.iZ_catId) as? String
                var name1 = dict?.value(forKey: AppConstant.iZ_b1Name) as? String ?? ""
                let name1Id = AppConstant.FIRST_BUTTON
                var name2 = dict?.value(forKey: AppConstant.iZ_b2Name) as? String ?? ""
                let name2Id = AppConstant.SECOND_BUTTON
                
                if name1 != "" && name2 != ""{
                    if name1.contains("~"){
                        name1 = name1.replacingOccurrences(of: "~", with: "")
                    }
                    if(name2.contains("~"))
                    {
                        name2 = name2.replacingOccurrences(of: "~", with: "")
                    }
                    if name1.count > 17{
                        let mySubstring = name1.prefix(17)
                        name1 = "\(mySubstring)..."
                    }
                    if name2.count > 17{
                        let mySubstring = name2.prefix(17)
                        name2 = "\(mySubstring)..."
                    }
                    
                    let firstAction = UNNotificationAction( identifier: name1Id, title: " \(name1)", options: .foreground)
                    
                    let secondAtion = UNNotificationAction( identifier: name2Id, title: " \(name2)", options: .foreground)
                    
                    let category = UNNotificationCategory( identifier: categoryId ?? "", actions: [firstAction, secondAtion], intentIdentifiers: [], options: [])
                    
                    notificationCategories.insert(category)
                    
                }else{
                    if name1 != ""{
                        if(name1.contains("~"))
                        {
                            name1 = name1.replacingOccurrences(of: "~", with: "")
                        }
                        let firstAction = UNNotificationAction( identifier: name1Id, title: " \(name1)", options: .foreground)
                        let category = UNNotificationCategory( identifier: categoryId ?? "", actions: [firstAction], intentIdentifiers: [], options: [])
                        notificationCategories.insert(category)
                    }
                }
            }
        }
        
        if #available(iOS 12.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) {(granted, error) in
                if !granted {
                    print("Notification access denied.")
                }
                center.setNotificationCategories(notificationCategories)
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
                    alert.addAction(UIAlertAction(title: "Take me there", style: .default, handler: { (action: UIAlertAction!) in
                        
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
        if(sourceString.contains("~"))
        {
//            print("Soursce String : \(sourceString)")
            return sourceString.replacingOccurrences(of: "~", with: "")
        }
        else
        {
            if(sourceString.contains("."))
            {
                let array = sourceString.split(separator: ".")
                let count = array.count
                if count == 2 {
                    if array.first != nil {
                        if let content = jsonData["\(array[0])"] as? [[String:Any]] {
                            for responseData in content {
                                if let responseDict = responseData["\(array[1])"] as? String {
                                    return responseDict
                                }
                            }
                        }
                    }
                }
                if count == 3
                {
                    if array.first != nil {
                        let value = String(array[1])
                        _ =  value.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with:"")
                        if let content = jsonData["\(array[0])"] as? [[String:Any]] {
                            for responseData in content {
                                if let responseDict = responseData["\(array[2])"] as? String {
                                    return responseDict
                                }
                            }
                        }
                        else
                        {
                            if let content = jsonData["\(array[0])"] as? [String:Any] {
                                if let value = content["\(array[1])"] as? [String: Any],
                                   let fvalue = value["\(array[2])"] as? String {
                                    return fvalue
                                }
                            }
                        }
                    }
                }
                if (count == 4){
                    
                    let array = sourceString.split(separator: ".")
                    if let response = jsonData["\(array[0])"] as? [String: Any],
                       let documents = response["\(array[1])"] as? [String: Any],
                       let field = documents["doc"] as? [[String: Any]], !field.isEmpty {
                        
                        if let name = field[0]["\(array[3])"] as? String {
                            return name
                        } else if let nameArray = field[0]["\(array[3])"] as? [String], !nameArray.isEmpty {
                            return nameArray[0]
                        } else {
                            return sourceString
                        }
                    } else {
                        return sourceString
                    }
                }
                if (count == 5){
                    if sourceString.contains("list"){
                        let array = sourceString.split(separator: ".")
                        if let response = jsonData["\(array[0])"] as? [[String: Any]], !response.isEmpty,
                           let documents = response.first,
                           let field = documents["\(array[2])"] as? [[String: Any]], !field.isEmpty,
                           let responseField = field[0]["\(array[4])"] as? String {
                            return responseField
                        } else {
                            return sourceString
                        }
                    }
                    else{
                        
                        let array = sourceString.split(separator: ".")
                        if let response = jsonData["\(array[0])"] as? [String: Any],
                           let documents = response["\(array[1])"] as? [String: Any],
                           let field = documents["doc"] as? [[String: Any]], !field.isEmpty,
                           let responseData = field[0]["\(array[3])"] as? [String: Any],
                           let responseField = responseData["\(array[4])"] as? String {
                            return responseField
                        } else {
                            return sourceString
                        }
                    }
                }
                if (count == 6)
                {
                    debugPrint(sourceString)
                }
            }
            else
            {
                return sourceString
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
    
    // Handle the Notification behaviour
    @objc  public static func handleForeGroundNotification(notification : UNNotification,displayNotification : String,completionHandler : @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        
        let appstate = UIApplication.shared.applicationState
        if (appstate == .active && displayNotification == AppConstant.iZ_KEY_IN_APP_ALERT)
        {
            
            let userInfo = notification.request.content.userInfo
            guard let apsDict = userInfo["aps"] as? NSDictionary else {
                return
            }
            let notificationData = Payload(dictionary: apsDict)
            let alert = UIAlertController(title: notificationData?.alert?.title, message:notificationData?.alert?.body, preferredStyle: UIAlertController.Style.alert)
            if (notificationData?.act1name != nil && notificationData?.act1name != ""){
                alert.addAction(UIAlertAction(title: notificationData?.act1name, style: .default, handler: { (action: UIAlertAction!) in
                }))
            }
            if (notificationData?.act2name != nil && notificationData?.act2name != "")
            {
                alert.addAction(UIAlertAction(title: notificationData?.act2name, style: .default, handler: { (action: UIAlertAction!) in
                    
                    let izUrlStr = notificationData?.act2link?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    if let url = URL(string:izUrlStr ?? "") {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url)
                        }
                    }
                }))
            }
            alert.addAction(UIAlertAction(title: AppConstant.iZ_KEY_ALERT_DISMISS, style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        else
        {
            let userInfo = notification.request.content.userInfo
            if let jsonDictionary = userInfo as? [String:Any] {
                if let aps = jsonDictionary["aps"] as? NSDictionary{
                    if aps.value(forKey: AppConstant.iZ_ANKEY) != nil {
                        guard let userInfoData = userInfo["aps"] as? NSDictionary else {
                            return
                        }
                        let notificationData = Payload(dictionary: userInfoData)
                        if notificationData?.ankey != nil {
                            if(notificationData?.ankey?.fetchUrlAd != "" && notificationData?.ankey?.fetchUrlAd != nil)
                            {
                                if(notificationData?.global?.rid != nil && notificationData?.global?.created_on != nil)
                                {
                                    completionHandler([.badge, .alert, .sound])
                                }
                                else
                                {
                                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "iZooto Payload is not exits\(userInfo)", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "handleForeGroundNotification",rid: notificationData?.global?.rid,cid : notificationData?.global?.id, userInfo: userInfo)
                                }
                            }
                        }
                    }
                    else{
                        guard let aps = userInfo["aps"] as? NSDictionary else {
                            // handle the case where userInfo["aps"] is not a NSDictionary
                            print("Failed to retrieve aps dictionary from userInfo")
                            return
                        }
                        let notificationData = Payload(dictionary: aps)
                        if(notificationData?.fetchurl != "" && notificationData?.fetchurl != nil)
                        {
                            guard let rid = notificationData?.rid, let firstIndex = rid.prefix(1).first else {
                                print("notificationData, rid, or the first character is nil or empty")
                                return
                            }
                            if firstIndex != "6" && firstIndex != "7" {
                                if let unwrappedNotificationData = notificationData {
                                    notificationReceivedDelegate?.onNotificationReceived(payload: unwrappedNotificationData)
                                }
                            }
                            completionHandler([.badge, .alert, .sound])
                        }
                        else
                        {
                            if(notificationData?.rid != nil && notificationData?.created_on != nil)
                            {
                                completionHandler([.badge, .alert, .sound])
                                
                                guard let rid = notificationData?.rid, let firstIndex = rid.prefix(1).first else {
                                    
                                    print("notificationData, rid, or the first character is nil or empty")
                                    return
                                }
                                if firstIndex != "6" && firstIndex != "7" {
                                    if let unwrappedNotificationData = notificationData {
                                        notificationReceivedDelegate?.onNotificationReceived(payload: unwrappedNotificationData)
                                    }
                                }
                            }
                            else
                            {
                                completionHandler([.badge, .alert, .sound])
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Handle the clicks the notification from Banner,Button
    @objc public static func notificationHandler(response : UNNotificationResponse)
    {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)) {
            let badgeC = userDefaults.integer(forKey:"Badge")
            let isBadge = userDefaults.bool(forKey: "isBadge")
            if isBadge{
                if userDefaults.integer(forKey: "BADGECOUNT") == 2 {
                    self.badgeCount = 0
                    userDefaults.set(0, forKey:"Badge")
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }else{
                    self.badgeCount = badgeC
                    userDefaults.set(badgeC - 1, forKey:"Badge")
                }
            }else{
                self.badgeCount = 0
                userDefaults.set(0, forKey:"Badge")
            }
            badgeNumber =  userDefaults.integer(forKey: "Badge")
            if(badgeNumber <= 0)
            {
                UIApplication.shared.applicationIconBadgeNumber = -1 // clear the badge count // notification is not removed
                userDefaults.set(0, forKey:"Badge")
            }else{
                UIApplication.shared.applicationIconBadgeNumber = self.badgeCount - 1 //set badge default value
            }
            userDefaults.synchronize()
        }
        
        let userInfo = response.notification.request.content.userInfo
        let indexx = 0
        if let jsonDictionary = userInfo as? [String:Any] {
            if let aps = jsonDictionary["aps"] as? NSDictionary{
                if let finalBids = aps["fb"] as? NSDictionary {// Handle the ads mediation & fetcher
                    guard let notificationData = Payload(dictionary: aps) else {
                        return
                    }
                        if notificationData.created_on != nil && notificationData.rid != nil {
                            var adUrl: String = ""
                            if response.actionIdentifier == AppConstant.FIRST_BUTTON{
                                type = "1"
                                if let link1 = notificationData.act1link{
                                    adUrl = link1
                                    if adUrl.contains("~"){
                                        adUrl = adUrl.replacingOccurrences(of: "~", with: "")
                                    }
                                }
                            }else if response.actionIdentifier == AppConstant.SECOND_BUTTON{
                                type = "2"
                                if let link2 = notificationData.act2link{
                                    adUrl = link2
                                    if adUrl.contains("~"){
                                        adUrl = adUrl.replacingOccurrences(of: "~", with: "")
                                    }
                                }
                            }else{
                                type = "0"
                                if let url = notificationData.url{
                                    adUrl = url
                                }
                            }
                            
                            clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo)
                            RestAPI.callAdMediationClickApi(bundleName: bundleName, finalDict: finalBids, userInfo: userInfo)
                            if notificationData.furc != nil {
                                if let urlArr = notificationData.furc{
                                    for url in urlArr {
                                        RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: url)
                                    }
                                }
                            }
                            
                            if adUrl != "" {
                                if let unencodedURLString = adUrl.removingPercentEncoding {
                                    if let encodedURLString = unencodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                                        adUrl = encodedURLString
                                    }
                                } else {
                                    if let url = adUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                                        adUrl = url
                                    }
                                }
                                if let url = URL(string: adUrl) {
                                    DispatchQueue.main.async {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }else{
                                Utils.handleOnceException(bundleName: bundleName, exceptionName: "Mediation LandingUrl is blank", className: "iZooto", methodName: "notificationHandler",rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
                            }
                        }else{
                            print("other payload data")
                        }
                }else{
                    guard let aps = userInfo["aps"] as? NSDictionary else {
                        // handle the case where userInfo["aps"] is not a NSDictionary
                        print("Failed to retrieve aps dictionary from userInfo")
                        return
                    }
                    
                    guard let notificationData = Payload(dictionary: aps) else {
                        return
                    }
                    
                    if notificationData.rid != nil && notificationData.created_on != nil{
                        let firstIndex = notificationData.rid?.prefix(1).first
                        if firstIndex != "6" && firstIndex != "7" {
                            notificationReceivedDelegate?.onNotificationReceived(payload: notificationData)
                        }
                        
                        if notificationData.category != nil && notificationData.category != ""
                        {
                            if response.actionIdentifier == AppConstant.FIRST_BUTTON{
                                
                                type = "1"
                                clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo)
                                
                                if notificationData.ap != "" && notificationData.ap != nil
                                {
                                    handleClicks(response: response, actionType: type)
                                }
                                else
                                {
                                    if notificationData.act1link != nil && notificationData.act1link != ""
                                    {
                                        if let inApp = notificationData.inApp, inApp.contains("1"), !inApp.isEmpty, let act1link = notificationData.act1link, !act1link.isEmpty {
                                            // Your code here
                                            if let checkWebview = sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW),
                                               let act1link = notificationData.act1link {
                                                
                                                if checkWebview {
                                                    landingURLDelegate?.onHandleLandingURL(url: act1link)
                                                } else {
                                                    ViewController.seriveURL = act1link
                                                    if let keyWindow = UIApplication.shared.keyWindow {
                                                        keyWindow.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                    }
                                                }
                                            }
                                        }
                                        else if let inApp = notificationData.inApp, inApp.contains("0"), !inApp.isEmpty, let act1link = notificationData.act1link, !act1link.isEmpty
                                        {
                                            handleBroserNotification(url: act1link)
                                        }
                                    }
                                }
                            }
                            else if response.actionIdentifier == AppConstant.SECOND_BUTTON{
                                type = "2"
                                clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo)
                                
                                if notificationData.ap != "" && notificationData.ap != nil
                                {
                                    handleClicks(response: response, actionType: type)
                                }
                                else
                                {
                                    if notificationData.act2link != nil && notificationData.act2link != ""
                                    {
                                        if let inApp = notificationData.inApp, inApp.contains("1"), !inApp.isEmpty,
                                           let act2link = notificationData.act2link, !act2link.isEmpty {
                                            
                                            if let checkWebview = sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW) {
                                                if checkWebview {
                                                    landingURLDelegate?.onHandleLandingURL(url: act2link)
                                                } else {
                                                    ViewController.seriveURL = act2link
                                                    if let keyWindow = UIApplication.shared.keyWindow {
                                                        keyWindow.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                    }
                                                }
                                            }
                                        }
                                        else if let inApp = notificationData.inApp, inApp.contains("0"), !inApp.isEmpty,
                                                let act2link = notificationData.act2link, !act2link.isEmpty
                                        {
                                            handleBroserNotification(url: act2link)
                                        }
                                    }
                                }
                            }else{
                                type = "0"
                                clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo)
                                if notificationData.ap != "" && notificationData.ap != nil
                                {
                                    handleClicks(response: response, actionType: type)
                                }
                                else{
                                    if let inApp = notificationData.inApp, inApp.contains("1"), !inApp.isEmpty,
                                       let url = notificationData.url, !url.isEmpty {
                                        if let checkWebview = sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW) {
                                            if checkWebview {
                                                landingURLDelegate?.onHandleLandingURL(url: url)
                                            } else {
                                                ViewController.seriveURL = url
                                                if let keyWindow = UIApplication.shared.keyWindow {
                                                    keyWindow.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                }
                                            }
                                        }
                                    }
                                    else if let inApp = notificationData.inApp, inApp.contains("0"), !inApp.isEmpty,
                                            let url = notificationData.url, !url.isEmpty{
                                        if let url = URL(string: url) {
                                            DispatchQueue.main.async {
                                                UIApplication.shared.open(url)
                                            }
                                        }
//                                            handleBroserNotification(url: url)
                                    }
                                }
                            }
                        }else{
                            type = "0"
                            clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: type, userInfo: userInfo)
                            if notificationData.ap != "" && notificationData.ap != nil
                            {
                                handleClicks(response: response, actionType: type)
                            }
                            else{
                                if let inApp = notificationData.inApp, inApp.contains("1"), !inApp.isEmpty,
                                   let url = notificationData.url,!url.isEmpty
                                {
                                    if let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW)){
                                        if checkWebview
                                        {
                                            if let url = notificationData.url{
                                                landingURLDelegate?.onHandleLandingURL(url: url)
                                            }
                                        }
                                        else
                                        {
                                            ViewController.seriveURL = notificationData.url
                                            UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                        }
                                    }
                                }
                                else if let inApp = notificationData.inApp, inApp.contains("0"), !inApp.isEmpty,
                                        let url = notificationData.url,!url.isEmpty
                                {
                                    handleBroserNotification(url: url)
                                }
                            }
                        }
                    }
                    else
                    {
                        print("other payload data")
                    }
                }
            }
        }
    }
    
    private  static func handleImpresseionCfgValue(cfgNumber: Int , notificationData : Payload,bundleName : String, isSilentPush: Bool, userInfo: [AnyHashable : Any]?)
    {
        var pid = ""
        var token = ""
        if let userDefault = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
            pid = userDefault.value(forKey: AppConstant.iZ_PID) as? String ?? ""
            token = userDefault.value(forKey: AppConstant.IZ_GRPS_TKN) as? String ?? ""
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
            url = RestAPI.LASTNOTIFICATIONVIEWURL
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
                    print("Failed to convert cfg to Int.")
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
                    url = RestAPI.LASTNOTIFICATIONCLICKURL
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
            if let apsDict = userInfo["aps"] as? NSDictionary {
                let notifcationData = Payload(dictionary: apsDict)
                
                if let inApp = notifcationData?.inApp, inApp.contains("1"), !inApp.isEmpty {
                    ViewController.seriveURL = notifcationData?.url
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
            if let apsDictionary = userInfo["aps"] as? NSDictionary {
                let notifcationData = Payload(dictionary: apsDictionary)
                if let inAppValue = notifcationData?.inApp, inAppValue.contains("0"), !inAppValue.isEmpty {
                    handleBroserNotification(url: launchURL)
                }
            } else {
                print("Failed to create Payload from userInfo.")
            }
        }
        
        // handle the addtional data
        @objc public static func handleClicks(response : UNNotificationResponse , actionType : String)
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
        
        @objc public static func getQueryStringParameter(url: String, param: String) -> String? {
            guard let url = URLComponents(string: url) else { return nil }
            return url.queryItems?.first(where: { $0.name == param })?.value
        }
        
        // Add Event Functionality
    @objc public static func addEvent(eventName: String, data: Dictionary<String, Any>) {
            guard !eventName.isEmpty else { return }
            
            let returnData = Utils.dataValidate(data: data)
            do {
                if let theJSONData = try? JSONSerialization.data(withJSONObject: returnData, options: .fragmentsAllowed),
                   let validateData = String(data: theJSONData, encoding: .utf8) {
                    let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
                    if let token = Utils.getUserDeviceToken(bundleName: bundleName), !token.isEmpty {
                        RestAPI.callEvents(bundleName: bundleName, eventName: Utils.eventValidate(eventName: eventName), data: validateData as NSString, pid: Utils.getUserId(bundleName: bundleName) ?? "", token: token)
                    } else {
                        sharedUserDefault?.set(data, forKey: AppConstant.KEY_EVENT)
                        sharedUserDefault?.set(eventName, forKey: AppConstant.KEY_EVENT_NAME)
                    }
                }
            }catch let error {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        // Add User Properties
        @objc public static func addUserProperties( data : Dictionary<String,Any>)
        {
            let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
            let returnData =  Utils.dataValidate(data: data)
            for (key, value) in returnData {
                guard let stringValue = value as? String, !stringValue.isEmpty else {
                    print(AppConstant.iZ_USERPROPERTIES_VALUE)
                    return
                }
                guard !key.isEmpty else {
                    print(AppConstant.iZ_USERPROPERTIES_VALUE)
                    return
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if (!returnData.isEmpty)
                {
                    guard let theJSONData = try?  JSONSerialization.data(withJSONObject: returnData,options: .fragmentsAllowed) else{
                        return
                    }
                    if let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue),
                       let token = Utils.getUserDeviceToken(bundleName: bundleName){
                        if (!token.isEmpty)
                        {
                            RestAPI.callUserProperties(bundleName: bundleName, data: validationData as NSString, pid: Utils.getUserId(bundleName: bundleName) ?? "", token: token)
                        }
                        else
                        {
                            sharedUserDefault?.set(data, forKey:AppConstant.iZ_USERPROPERTIES_KEY)
                        }
                    }
                }
                else
                {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "No data found in userProperties dictionary \(data)", className: AppConstant.IZ_TAG, methodName: AppConstant.iZ_USERPROPERTIES_KEY,rid: nil, cid: nil, userInfo: nil)
                    
                }
            }
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
                    getNotificationSettings()
                }
            }
        }
        @objc private static func handleBroserNotification(url : String)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let izUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
                    if let izUrl = URL(string: izUrlString) {
                        UIApplication.shared.open(izUrl)
                    }
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
        if let apsDictionary = userInfo["aps"] as? NSDictionary,
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
            print("Invalid URL string: \(imgUrl)")
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

