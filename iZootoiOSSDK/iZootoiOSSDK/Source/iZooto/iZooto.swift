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
    private static var mizooto_id = Int()
    private static var rid : String!
    private static var cid : String!
    private static var myIdLnArray: [[String:Any]] = []
    private static var myRCArray: [[String:Any]] = []
    private static var tokenData : String!
    private let application : UIApplication
    @available(iOS 11.0, *)
    private static var firstAction : UNNotificationAction!
    @available(iOS 11.0, *)
    private static var secondAction : UNNotificationAction!
    @available(iOS 11.0, *)
    private static var category : UNNotificationCategory!
    private static var type : String!
    //  public static var iZootoActionDelegate : iZootoNotificationActionDelegate?
    private static var actionType : String!
    private static var updateURL : String!
    private static let checkData = 1 as Int
    static var appId : String!
    static var launchOptions : NSDictionary!
    // private static var badgeCount = 0
    private static var isAnalytics = false as Bool
    private static var isNativeWebview = false as Bool
    private static var izooto_uuid : String!
    private static var isWebView = false as Bool
    private static var landingURL : String!
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
    @objc private static var iZPid = 0
    @objc private static var iZTkn = ""
    @objc private static var finalDataValue = NSMutableDictionary()
    @objc private static var servedData = NSMutableDictionary()
    @objc private static var bidsData = [NSMutableDictionary()]
    //to store category details
    private static var categoryArray: [[String:Any]] = []
    
    @objc public init(application : UIApplication)
    {
        self.application = application
    }
    
    // initialise the device and register the token
    @objc public static func initialisation(izooto_id : String, application : UIApplication,iZootoInitSettings : Dictionary<String,Any>)
    {
        let defaults = UserDefaults.standard
        izooto_uuid = izooto_id
        keySettingDetails = iZootoInitSettings
        RestAPI.getRequest(uuid: izooto_uuid) { (output) in
            
            let jsonString = output.fromBase64()
            let data = jsonString!.data(using: .utf8)!
            let json = try? JSONSerialization.jsonObject(with: data)
            if let dictionary = json as? [String: Any] {
                sharedUserDefault?.set(dictionary[AppConstant.REGISTERED_ID]!, forKey: SharedUserDefault.Key.registerID)
                mizooto_id = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!
            }
            else{
                debugPrint(AppConstant.IZ_TAG,AppConstant.APP_ID_ERROR)
                if defaults.value(forKey: "initialisationId") == nil{
                    defaults.setValue("true", forKey: "initialisationId")
                    RestAPI.sendExceptionToServer(exceptionName: ".dat response error \(json ?? "")", className: "iZooto", methodName: "initialisation", pid: 0, token: "0", rid: "0", cid: "0")
                }
            }
        }
        
        if(!keySettingDetails.isEmpty)
        {
            let nativeWebviewKey = keySettingDetails[AppConstant.iZ_KEY_WEBVIEW] != nil
            if nativeWebviewKey{
                sharedUserDefault?.set(keySettingDetails[AppConstant.iZ_KEY_WEBVIEW]!, forKey:AppConstant.ISWEBVIEW)
            } else {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_WEBVIEW_ERROR)
                if defaults.value(forKey: "initialisationWeb") == nil{
                    defaults.setValue("true", forKey: "initialisationWeb")
                    RestAPI.sendExceptionToServer(exceptionName: AppConstant.iZ_KEY_WEBVIEW_ERROR, className: "iZooto", methodName: "initialisation", pid: mizooto_id, token: "0", rid: "0", cid: "0")
                }
            }
            let provisionalKey = keySettingDetails[AppConstant.iZ_KEY_PROVISIONAL] != nil
            if(provisionalKey)
            {
                if(keySettingDetails[AppConstant.iZ_KEY_PROVISIONAL]!) as! Bool
                {
                    registerForPushNotificationsProvisional() // check for provisional
                }
                else{
                    registerForPushNotifications() // check for prompt
                }
            }
            else
            {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND)
                if defaults.value(forKey: "initialisationPro") == nil{
                    defaults.setValue("true", forKey: "initialisationPro")
                    RestAPI.sendExceptionToServer(exceptionName: AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND, className: "iZooto", methodName: "initialisation", pid: mizooto_id, token: "0", rid: "0", cid: "0")
                }
            }
            let autoPromptkey = keySettingDetails[AppConstant.iZ_KEY_AUTO_PROMPT] != nil
            if autoPromptkey{
                
                if(keySettingDetails[AppConstant.iZ_KEY_AUTO_PROMPT]!) as! Bool
                {
                    if(keySettingDetails[AppConstant.iZ_KEY_PROVISIONAL]!) as! Bool
                    {
                        registerForPushNotificationsProvisional() // check for provisional
                    }
                    else{
                        registerForPushNotifications() // check for prompt
                    }// check for prompt
                }
            }
            else {
                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_AUTO_PROMPT_NOT_FOUND)
                if defaults.value(forKey: "initialisation") == nil{
                    defaults.setValue("true", forKey: "initialisation")
                    RestAPI.sendExceptionToServer(exceptionName: AppConstant.iZ_KEY_AUTO_PROMPT_NOT_FOUND, className: AppConstant.IZ_TAG, methodName: AppConstant.iZ_KEY_INITIALISE, pid: mizooto_id, token: "\(izooto_uuid ?? "")", rid: "0", cid: "0")
                }
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
        let userPropertiesData = sharedUserDefault?.dictionary(forKey:AppConstant.iZ_USERPROPERTIES_KEY)
        if(userPropertiesData != nil)
        {
            addUserProperties(data: userPropertiesData!)
        }
        let eventData = sharedUserDefault?.dictionary(forKey:AppConstant.KEY_EVENT)
        let eventName = sharedUserDefault?.string(forKey: AppConstant.KEY_EVENT_NAME)
        if(eventData != nil && eventName != nil)
        {
            addEvent(eventName: eventName!, data: eventData!)
        }
    }
    
    @objc public static func setLogLevel(isEnable: Bool){
        UserDefaults.standard.set(isEnable, forKey: AppConstant.iZ_LOG_ENABLED)
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
            userDefaults.set(isEnable, forKey: AppConstant.iZ_LOG_ENABLED)
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
    
    // Capture the token from APNS
     @objc public static func getToken(deviceToken : Data)
     {
         let tokenParts = deviceToken.map { data -> String in
             return String(format: "%02.2hhx", data)
         }
         let token = tokenParts.joined()
         let defaults = UserDefaults.standard
         let date = Date()
         let format = DateFormatter()
         format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
         let formattedDate = format.string(from: date)
         if UserDefaults.getRegistered()
         {
             guard let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
             else
             {return}
             debugPrint(AppConstant.DEVICE_TOKEN," \(token)")
             if(formattedDate != (sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_LAST_VISIT)))
             {
                 RestAPI.lastVisit(userid: mizooto_id, token:token)
                 sharedUserDefault?.set(formattedDate, forKey: AppConstant.iZ_KEY_LAST_VISIT)
             }
             if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
                 userDefaults.set(token, forKey: "DEVICETOKEN")
                 userDefaults.set(mizooto_id, forKey: AppConstant.REGISTERED_ID)
                 userDefaults.synchronize()
             }
             if(RestAPI.SDKVERSION != sharedUserDefault?.string(forKey: AppConstant.iZ_SDK_VERSION)) || (Utils.getAppVersion() != sharedUserDefault?.string(forKey: AppConstant.iZ_APP_VERSION))
             {
                 sharedUserDefault?.set(RestAPI.SDKVERSION, forKey: AppConstant.iZ_SDK_VERSION)
                 sharedUserDefault?.set(Utils.getAppVersion(), forKey: AppConstant.iZ_APP_VERSION)
                 RestAPI.registerToken(token: token, izootoid: mizooto_id)
             }
         }
         else
         {
             sleep(2)
             if(mizooto_id != 0 && token != "")
             {
                 RestAPI.registerToken(token: token, izootoid: mizooto_id)
                 if Utils.getAppVersion() != ""{
                     sharedUserDefault?.set(Utils.getAppVersion(), forKey: AppConstant.iZ_APP_VERSION)
                 }
                 sharedUserDefault?.set(RestAPI.SDKVERSION, forKey: AppConstant.iZ_SDK_VERSION)
                 sharedUserDefault?.set(token, forKey: SharedUserDefault.Key.token)
                 if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
                     userDefaults.set(token, forKey: "DEVICETOKEN")
                     userDefaults.set(mizooto_id, forKey: "PID")
                     userDefaults.synchronize()
                 }
             }
             else
             {
                 if defaults.value(forKey: "getTokennn") == nil{
                     defaults.setValue("true", forKey: "getTokennn")
                     RestAPI.sendExceptionToServer(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.IZ_TAG, methodName: "GetToken", pid: mizooto_id , token: token, rid: "", cid: "")
                 }
             }
         }
     }
    
    // handle the badge count
    @objc public static func setBadgeCount(badgeNumber : NSInteger)
    {
        if(badgeNumber == -1)
        {
            sharedUserDefault?.setValue(badgeNumber, forKey: "BADGECOUNT")
        }
        if(badgeNumber == 1)
        {
            sharedUserDefault?.setValue(badgeNumber, forKey: "BADGECOUNT")
        }
        else
        {
            if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
                userDefaults.set(0, forKey: "Badge")
                userDefaults.synchronize()
            }
        }
    }
    
    // getAdvertisement ID
    @objc public static func getAdvertisementID(adid : NSString)
    {
        let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))
        let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? ""
        if (adid != "" && token != "" && userID != 0 )
        {
            let dicData = sharedUserDefault?.bool(forKey:AppConstant.iZ_KEY_ADVERTISEMENT_ID)
            if(dicData == false)
            {
                RestAPI.registerToken(token: token, izootoid: userID!, adid: adid)
            }
        }
        else{
            sharedUserDefault?.set(adid, forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID_)
        }
    }
    
    // Ad's Fallback Url Call
    @available(iOS 11.0, *)
    @objc private static func fallBackAdsApi(bundleName: String, fallCategory: String, notiRid: String, bestAttemptContent :UNMutableNotificationContent, contentHandler:((UNNotificationContent) -> Void)?){
        
        let str = RestAPI.FALLBACK_URL
        let izUrlString = (str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        if let url = URL(string: izUrlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        if let jsonDictionary = json as? [String:Any] {
                            let notificationData = Payload(dictionary: (jsonDictionary) as NSDictionary)
                            bestAttemptContent.title = jsonDictionary[AppConstant.iZ_T_KEY] as! String
                            bestAttemptContent.body = jsonDictionary["m"] as! String
                            if notificationData?.url! != "" {
                                
                                let groupName = "group."+bundleName+".iZooto"
                                if let userDefaults = UserDefaults(suiteName: groupName) {
                                    userDefaults.set(notificationData?.url!, forKey: "fallBackLandingUrl")
                                    userDefaults.set(bestAttemptContent.title, forKey: "fallBackTitle")
                                }
                                
                                notificationData?.url = jsonDictionary["bi"] as? String
                                if (notificationData?.url!.contains(".webp"))!
                                {
                                    notificationData?.url! = (notificationData?.url?.replacingOccurrences(of: ".webp", with: ".jpeg"))!
                                }
                                if (notificationData?.url!.contains("http:"))!
                                {
                                    notificationData?.url! = (notificationData?.url?.replacingOccurrences(of: "http:", with: "https:"))!
                                }
                            }
                            if fallCategory != ""{
                                storeCategories(notificationData: notificationData!, category: fallCategory)
                                if notificationData!.act1name != "" && notificationData!.act1name != nil{
                                    debugPrint("Ankey button called")
                                    addCTAButtons()
                                }
                            }
                            
                            //call impression
                            self.ad_mediationImpressionCall(notiRid: notiRid, adTitle: bestAttemptContent.title, adLn: (notificationData?.url!)!, bundleName: bundleName)
                            
                            sleep(1)
                            autoreleasepool {
                                if let urlString = (notificationData?.url!),
                                   let fileUrl = URL(string: urlString ) {
                                    
                                    guard let imageData = NSData(contentsOf: fileUrl) else {
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    let string = notificationData?.url!
                                    let url: URL? = URL(string: string!)
                                    let urlExtension: String? = url?.pathExtension
                                    guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                        debugPrint(AppConstant.IMAGE_ERROR)
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    bestAttemptContent.attachments = [ attachment ]
                                }
                            }
                        }
                        contentHandler!(bestAttemptContent)
                        
                    } catch let error {
                        debugPrint("Error",error)
                        let defaults = UserDefaults.standard
                        if defaults.value(forKey: "fallBackAdsApi") == nil{
                            defaults.setValue("true", forKey: "fallBackAdsApi")
                            RestAPI.sendExceptionToServer(exceptionName: "Fallback ad Api = \(error.localizedDescription)", className: "iZooto", methodName: "fallBackAdsApi", pid: self.iZPid, token: self.iZTkn, rid: notiRid , cid: "0")
                        }
                    }
                }
                
            }.resume()
        }
    }
    
    
    @objc private static func payLoadDataChange(payload: [String:Any],bundleName: String, completion: @escaping ([String:Any]) -> Void) {
        
        if let jsonDictionary = payload as? [String:Any] {
            if let aps = jsonDictionary["aps"] as? NSDictionary{
                if let category = aps.value(forKey: "category"){
                    tempData.setValue(category, forKey: "category")
                }
                
                if let alert = aps.value(forKey: AppConstant.iZ_ALERTKEY) {
                    alertData = alert as! [String : Any]
                    tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                    tempData.setValue(1, forKey: "mutable-content")
                    tempData.setValue(0, forKey: "content_available")
                }
                if let g = aps.value(forKey: AppConstant.iZ_G_KEY), let gt = aps.value(forKey: AppConstant.iZ_G_KEY) as? NSDictionary {
                    debugPrint(g)
                    gData = gt as! [String : Any]
                    tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                    
                    let groupName = "group."+bundleName+".iZooto"
                    if let userDefaults = UserDefaults(suiteName: groupName) {
                        if let pid = userDefaults.string(forKey: "PID"){
                            finalDataValue.setValue(pid, forKey: "pid")
                        }else{
                            finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_IDKEY))! as! String, forKey: "pid")
                        }
                    }
                    
                    finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_RKEY))! as! String, forKey: "rid")
                    finalDataValue.setValue((gt.value(forKey: AppConstant.iZ_TPKEY))! as! String, forKey: "type")
                    finalDataValue.setValue("0", forKey: "result")
                    finalDataValue.setValue(RestAPI.SDKVERSION, forKey: "av")
                    
                    //tp = 4
                    if (gt.value(forKey: AppConstant.iZ_TPKEY))! as! String == "4" {
                        if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                            let startDate = Date()
                            bidsData.removeAll()
                            
                            if let dict = anKey[0] as? [String : Any] {
                                
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
                                    
                                    let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                                    
                                    let session: URLSession = {
                                        let configuration = URLSessionConfiguration.default
                                        configuration.timeoutIntervalForRequest = 2
                                        return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                                    }()
                                    
                                    if let url = URL(string: izUrlString) {
                                        session.dataTask(with: url) { data, response, error in
                                            if(error != nil)
                                            {
                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00] as NSMutableDictionary
                                                bidsData.append(servedData)
                                                
                                                anData = [anKey[0] as! [String : Any]]
                                                tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                finalData["aps"] = tempData
                                                //Bids & Served
                                                finalDataValue.setValue(t, forKey: "ta")
                                                finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                
                                                storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                
                                                completion(finalData)
                                            }
                                            if let data = data {
                                                do {
                                                    
                                                    let json = try JSONSerialization.jsonObject(with: data)
                                                    
                                                    //To Check FallBack
                                                    if let jsonDictionary = json as? [String:Any] {
                                                        if let value = jsonDictionary["msgCode"] as? String {
                                                            debugPrint(value)
                                                            let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                            bidsData.append([AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                        }else{
                                                            if let jsonDictionary = json as? [String:Any] {
                                                                if cpmValue != ""{
                                                                    let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                    
                                                                    finalCPCValue = String(Double(cpc)!/(10  * Double(cprValue)!))
                                                                }else{
                                                                    finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                }
                                                                
                                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS:Double(finalCPCValue)!]
                                                                finalDataValue.setValue("1", forKey: "result")
                                                                bidsData.append(servedData)
                                                            }
                                                        }
                                                    }else{
                                                        if let jsonArray = json as? [[String:Any]] {
                                                            if jsonArray[0]["msgCode"] is String{
                                                                anData = [anKey[0] as! [String : Any]]
                                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                bidsData.append([AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                            }else{
                                                                
                                                                if cpmValue != ""{
                                                                    let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                    
                                                                    finalCPCValue = String(Double(cpc)!/(10  * Double(cprValue)!))
                                                                }else{
                                                                    finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                                                }
                                                                
                                                                finalDataValue.setValue("1", forKey: "result")
                                                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:Double(finalCPCValue)!]
                                                                bidsData.append(servedData)
                                                            }
                                                        }
                                                    }
                                                    anData = [anKey[0] as! [String : Any]]
                                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                    finalData["aps"] = tempData
                                                    //Bids & Served
                                                    
                                                    let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    finalDataValue.setValue(ta, forKey: "ta")
                                                    finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                    
                                                    storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                    
                                                    completion(finalData)
                                                    
                                                } catch {
                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    servedData = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00] as NSMutableDictionary
                                                    bidsData.append(servedData)
                                                    
                                                    anData = [anKey[0] as! [String : Any]]
                                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                    finalData["aps"] = tempData
                                                    //Bids & Served
                                                    finalDataValue.setValue(t, forKey: "ta")
                                                    finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                                                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                    
                                                    storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                    
                                                    completion(finalData)
                                                }
                                            }
                                        }.resume()
                                    }else{
                                        debugPrint("Not Found")
                                        let defaults = UserDefaults.standard
                                        if defaults.value(forKey: "payLoadDataChangetp4") == nil{
                                            defaults.setValue("true", forKey: "payLoadDataChangetp4")
                                            RestAPI.sendExceptionToServer(exceptionName: "FetchUrl error for tp 4 = \(izUrlString)", className: "iZooto", methodName: "fallBackAdsApi", pid: self.iZPid, token: self.iZTkn, rid: gt.value(forKey: "r") as! String , cid: "0")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //tp = 5
                    else if (gt.value(forKey: AppConstant.iZ_TPKEY))! as! String == "5" {
                        if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                            self.succ = "false"
                            bidsData.removeAll()
                            var fuDataArray = [String]()
                            for (index,valueDict) in anKey.enumerated()   {
                                
                                if let dict = valueDict as? [String: Any] {
                                    debugPrint("", index)
                                    
                                    let fuValue = dict["fu"] as? String ?? ""
                                    //hit fu
                                    let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                                    fuDataArray.append(izUrlString)
                                }
                            }
                            self.fuCount = 0
                            callFetchUrlForTp5(fuArray: fuDataArray, urlString: fuDataArray[0], anKey: anKey, bundleName: bundleName, completion: completion)
                        }
                    }
                    
                    //tp = 6
                    else {
                        
                        if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                            
                            let startDate = Date()
                            bidsData.removeAll()
                            
                            var finalArray: [[String:Any]] = []
                            var servedArray: [[String:Any]] = []
                            let myGroup = DispatchGroup()
                            
                            for (index,valueDict) in anKey.enumerated()   {
                                if var dict = valueDict as? [String: Any] {
                                    
                                    myGroup.enter()
                                    
                                    //hit fu
                                    DispatchQueue.main.async {
                                        
                                        var cpcFinalValue = ""
                                        var cpcValue = ""
                                        var ctrValue = ""
                                        var cpmValue = ""
                                        let fuValue = dict["fu"] as? String ?? ""
                                        cpcValue = dict["cpc"] as? String ?? ""
                                        ctrValue = dict["ctr"] as? String ?? ""
                                        cpmValue = dict["cpm"] as? String ?? ""
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
                                        
                                        let izUrlString = (fuValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                                        
                                        if let url = URL(string: izUrlString) {
                                            session.dataTask(with: url) { data, response, error in
                                                if(error != nil)
                                                {
                                                    anData = [anKey[index] as! [String : Any]]
                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                    //debugPrint("TOP ERROR")
                                                    dict.updateValue(("0.00"), forKey: "cpcc")
                                                    finalArray.append(dict)
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
                                                                if let jsonDictionary = json as? [String:Any] {
                                                                    
                                                                    if cpmValue != ""{
                                                                        let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                        
                                                                        finalCPCValue = String(Double(cpc)!/(10  * Double(ctrValue)!))
                                                                    }else{
                                                                        finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                    }
                                                                    
                                                                    finalDataValue.setValue("\(index + 1)", forKey: "result")
                                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                    servedData = [AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS:Double(finalCPCValue)!]
                                                                    servedArray.append(servedData as! [String : Any])
                                                                    bidsData.append(servedData)
                                                                }
                                                            }
                                                        }else{
                                                            if let jsonArray = json as? [[String:Any]] {
                                                                
                                                                if jsonArray[0]["msgCode"] is String{
                                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                    bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                                }else{
                                                                    
                                                                    if cpmValue != ""{
                                                                        let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                                                        
                                                                        finalCPCValue = String(Double(cpc)!/(10  * Double(ctrValue)!))
                                                                        //   print("CPC",finalCPCValue )
                                                                    }else{
                                                                        finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                                                    }
                                                                    
                                                                    finalDataValue.setValue("\(index + 1)", forKey: "result")
                                                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                                    servedData = [AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:Double(finalCPCValue)!]
                                                                    servedArray.append(servedData as! [String : Any])
                                                                    bidsData.append(servedData)
                                                                }
                                                            }
                                                        }
                                                        dict.updateValue((finalCPCValue), forKey: "cpcc")
                                                        finalArray.append(dict)
                                                    } catch let error {
                                                        debugPrint(" Error",error)
                                                        let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                                        bidsData.append([AppConstant.iZ_A_KEY: index + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t,AppConstant.iZ_RETURN_BIDS:0.00])
                                                        dict.updateValue(("0.00"), forKey: "cpcc")
                                                        finalArray.append(dict)
                                                    }
                                                }
                                                if finalArray.count == (anKey as AnyObject).count{
                                                    
                                                    let sortedArray = finalArray.sorted { $0["cpcc"] as! String > $1["cpcc"] as! String}
                                                    
                                                    let cpccSortedDict = sortedArray.first! as? NSDictionary
                                                    
                                                    anData = [sortedArray.first!] as! [[String: Any]]
                                                    
                                                    tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                                    tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                                                    
                                                    tempData.setValue(1, forKey: "mutable-content")
                                                    tempData.setValue(0, forKey: "content_available")
                                                    
                                                    finalData["aps"] = tempData
                                                    
                                                    //Bids & Served
                                                    let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                                                    finalDataValue.setValue(ta, forKey: "ta")
                                                    
                                                    // To save final served as per cpc
                                                    if servedArray.count != 0{
                                                        for data in servedArray{
                                                            let dict = data as NSDictionary
                                                            let cpc = dict.value(forKey: AppConstant.iZ_B_KEY) as? Double
                                                            let fCpc = cpc!.string
                                                            let fCPCC = cpccSortedDict!.value(forKey: "cpcc") as? String
                                                            let finalcpc = fCPCC!.toDouble()
                                                            let fff = finalcpc?.string
                                                            let result = dict.value(forKey: AppConstant.iZ_A_KEY) as? Int
                                                            if fCpc == fff{
                                                                finalDataValue.setValue(dict, forKey: AppConstant.iZ_SERVEDKEY)
                                                                finalDataValue.setValue(result, forKey: "result")
                                                            }
                                                        }
                                                    }else{
                                                        let dict = [AppConstant.iZ_A_KEY: 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY: 435,AppConstant.iZ_RETURN_BIDS:0.00]
                                                        // bidsData.append(dict as NSDictionary)
                                                        finalDataValue.setValue(dict, forKey: AppConstant.iZ_SERVEDKEY)
                                                        finalDataValue.setValue("0", forKey: "result")
                                                    }
                                                    
                                                    finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                                                    //debugPrint("Type66", finalDataValue)
                                                    storeBids(bundleName: bundleName, finalData: finalDataValue)
                                                    completion(finalData)
                                                }
                                            }.resume()
                                        }else{
                                            debugPrint("Not Found")
                                            let defaults = UserDefaults.standard
                                            if defaults.value(forKey: "payLoadDataChangetp5") == nil{
                                                defaults.setValue("true", forKey: "payLoadDataChangetp5")
                                                RestAPI.sendExceptionToServer(exceptionName: "fetchUrl error in tp 5 = \(izUrlString)", className: "iZooto", methodName: "fallBackAdsApi", pid: self.iZPid, token: self.iZTkn, rid: gt.value(forKey: "r") as! String , cid: "0")
                                            }
                                        }
                                    }
                                    myGroup.leave()
                                }
                            }
                            myGroup.notify(queue: .main) {
                                debugPrint("")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private static func callFetchUrlForTp5(fuArray: [String], urlString: String, anKey: NSArray, bundleName: String, completion: @escaping ([String : Any]) -> Void){
        
        let startDate = Date()
        let fu = fuArray[fuCount]
        let dict = anKey[fuCount] as? NSDictionary
        let cpmValue = dict!["cpm"] as? String ?? ""
        let ctrValue = dict!["ctr"] as? String ?? ""
        let cpcValue = dict!["cpc"] as? String ?? ""
        
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
                            callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, completion: completion)
                        }
                    }
                    
                    if fuCount == anKey.count{
                        anData = [anKey[fuCount - 1] as! [String : Any]]
                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                        finalData["aps"] = tempData
                        
                        servedData = [AppConstant.iZ_A_KEY: fuCount, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                        finalDataValue.setValue(t, forKey: "ta")
                        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                        storeBids(bundleName: bundleName, finalData: finalDataValue)
                        completion(finalData)
                    }
                }
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        //To Check FallBack
                        if let jsonDictionary = json as? [String:Any] {
                            if let value = jsonDictionary["msgCode"] as? String {
                                debugPrint(value)
                                let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS:0.00])
                                
                                if fuCount == anKey.count{
                                    servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                                    anData = [anKey[fuCount - 1] as! [String : Any]]
                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                    finalData["aps"] = tempData
                                    
                                    completion(finalData)
                                }
                            }else{
                                if let jsonDictionary = json as? [String:Any] {
                                    
                                    if cpmValue != ""{
                                        let cpc =  "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                        
                                        finalCPCValue = String(Double(cpc)!/(10  * Double(ctrValue)!))
                                    }else{
                                        finalCPCValue = "\(getParseValue(jsonData: jsonDictionary, sourceString: cpcFinalValue ))"
                                    }
                                    
                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: Double(finalCPCValue)!])
                                    
                                    anData = [anKey[fuCount] as! [String : Any]]
                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                    finalData["aps"] = tempData
                                    
                                    if succ != "done"{
                                        succ = "true"
                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: Double(finalCPCValue)!]
                                        finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                    }
                                }
                            }
                        }else{
                            if let jsonArray = json as? [[String:Any]] {
                                if jsonArray[0]["msgCode"] is String{
                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00])
                                    
                                    if fuCount == anKey.count{
                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: 0.00, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: 0.00]
                                        anData = [anKey[fuCount - 1] as! [String : Any]]
                                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                        finalData["aps"] = tempData
                                        completion(finalData)
                                    }
                                }else{
                                    if cpmValue != ""{
                                        let cpc =  "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                        
                                        finalCPCValue = String(Double(cpc)!/(10  * Double(ctrValue)!))
                                    }else{
                                        finalCPCValue = "\(getParseArrayValue(jsonData: jsonArray, sourceString: cpcFinalValue ))"
                                    }
                                    let t = Int(Date().timeIntervalSince(startDate) * 1000)
                                    bidsData.append([AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS:Double(finalCPCValue)!])
                                    
                                    anData = [anKey[fuCount] as! [String : Any]]
                                    tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                    finalData["aps"] = tempData
                                    if succ != "done"{
                                        succ = "true"
                                        servedData = [AppConstant.iZ_A_KEY: fuCount + 1, AppConstant.iZ_B_KEY: Double(finalCPCValue)!, AppConstant.iZ_T_KEY:t, AppConstant.iZ_RETURN_BIDS: Double(finalCPCValue)!]
                                        finalDataValue.setValue("\(fuCount + 1)", forKey: "result")
                                    }
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
                                    callFetchUrlForTp5(fuArray: fuArray, urlString: fuArray[fuCount],anKey: anKey, bundleName: bundleName, completion: completion)
                                }
                            }
                            if fuCount == anKey.count{
                                anData = [anKey[fuCount - 1] as! [String : Any]]
                                tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                                finalData["aps"] = tempData
                                
                                completion(finalData)
                                
                            }
                        }
                    }
                    
                    if succ == "true"{
                        succ = "done"
                        //Bids & Served
                        let ta = Int(Date().timeIntervalSince(startDate) * 1000)
                        finalDataValue.setValue(ta, forKey: "ta")
                        finalDataValue.setValue(servedData, forKey: AppConstant.iZ_SERVEDKEY)
                        finalDataValue.setValue(bidsData, forKey: AppConstant.iZ_BIDSKEY)
                        debugPrint("Type 5", finalDataValue)
                        
                        storeBids(bundleName: bundleName, finalData: finalDataValue)
                        
                        completion(finalData)
                        return
                    }
                }
            }.resume()
            
        }
    }
    
    
    // Handle the payload and show the notification
    @available(iOS 11.0, *)
    @objc public static func didReceiveNotificationExtensionRequest(bundleName : String,soundName :String,
                                                                    request : UNNotificationRequest, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
    {
        let defaults = UserDefaults.standard
        let userInfo = request.content.userInfo
        var isEnabled = false
        if let jsonDictionary = userInfo as? [String:Any] {
            if let aps = jsonDictionary["aps"] as? NSDictionary{
                
                if aps.value(forKey: AppConstant.iZ_ANKEY) != nil {
                    
                    self.payLoadDataChange(payload: ((userInfo as? [String: Any])!), bundleName: bundleName) { data in
                        let totalData = data["aps"] as? NSDictionary
                        let notificationData = Payload(dictionary: (data["aps"] as? NSDictionary)!)
                        
                        if notificationData?.ankey != nil {
                            
                            if(notificationData?.global?.inApp != nil)
                            {
                                badgeNumber = (sharedUserDefault?.integer(forKey: "BADGECOUNT"))!
                                
                                // custom notification sound
                                if (soundName != "")
                                {
                                    bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(string: soundName) as String)
                                }
                                else
                                {
                                    bestAttemptContent.sound = .default()
                                }
                                
                                if(bundleName != "")
                                {
                                    let groupName = "group."+bundleName+".iZooto"
                                    
                                    if let userDefaults = UserDefaults(suiteName: groupName) {
                                        
                                        badgeCount = userDefaults.integer(forKey:"Badge")
                                        if badgeCount > 0 {
                                            if(badgeNumber > 0)
                                            {
                                                bestAttemptContent.badge = 1 as NSNumber
                                            }
                                            else
                                            {
                                                userDefaults.set(badgeCount + 1, forKey: "Badge")
                                                bestAttemptContent.badge = badgeCount + 1 as NSNumber
                                            }
                                        } else {
                                            userDefaults.set(1, forKey: "Badge")
                                            bestAttemptContent.badge = 1
                                        }
                                        
                                        isEnabled = userDefaults.bool(forKey: AppConstant.iZ_LOG_ENABLED)
                                        self.iZTkn = userDefaults.string(forKey: "DEVICETOKEN") ?? ""
                                        self.iZPid = userDefaults.integer(forKey: "PID")
                                        //To call izooto Impression API
                                        if (notificationData?.global?.cfg != nil)
                                        {
                                            let str = String((notificationData?.global?.cfg)!)
                                            let binaryString = (str.data(using: .utf8, allowLossyConversion: false)?.reduce("") { (a, b) -> String in a + String(b, radix: 2) })
                                            let lastChar = binaryString?.last!
                                            let str1 = String((lastChar)!)
                                            let impr = Int(str1)
                                            if(impr == 1)
                                            {
                                                RestAPI.callImpression(notificationData: notificationData!,userid: self.iZPid,token:"\(self.iZTkn)", userInfo: userInfo)
                                            }
                                        }
                                        userDefaults.synchronize()
                                    }
                                    else
                                    {
                                        if isEnabled == true{
                                            debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_APP_GROUP_ERROR_)
                                        }
                                        if defaults.value(forKey: "didreceiveGroup") == nil{
                                            defaults.setValue("true", forKey: "didreceiveGroup")
                                            RestAPI.sendExceptionToServer(exceptionName: AppConstant.iZ_APP_GROUP_ERROR_, className: "iZooto", methodName: "didReceive", pid: self.iZPid, token: self.iZTkn, rid: notificationData?.global?.rid ?? "0", cid: notificationData?.global?.id ?? "0")
                                        }
                                    }
                                }
                                //Relevance Score
                                self.setRelevanceScore(notificationData: notificationData!, bestAttemptContent: bestAttemptContent)
                                
                                if notificationData?.ankey?.fetchUrlAd != nil && notificationData?.ankey?.fetchUrlAd != ""
                                {
                                    self.commonFuUrlFetcher(bestAttemptContent: bestAttemptContent, bundleName: bundleName, notificationData: notificationData!,totalData: totalData!, contentHandler: contentHandler)
                                }
                            }
                            else
                            {
                                //  if isEnabled == true{
                                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                                //  }
                                if defaults.value(forKey: "didreceiveOther") == nil{
                                    defaults.setValue("true", forKey: "didreceiveOther")
                                    RestAPI.sendExceptionToServer(exceptionName: "\(AppConstant.iZ_KEY_OTHER_PAYLOD) \(userInfo)", className: "iZooto", methodName: "didReceive", pid: self.iZPid, token: self.iZTkn, rid: "", cid: "")
                                }
                            }
                        }
                    }
                }else{
                    //to get all aps data & pass it to commonfu function
                    let totalData = userInfo["aps"] as? NSDictionary
                    
                    let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                    
                    if(notificationData?.inApp != nil)
                    {
                        badgeNumber = (sharedUserDefault?.integer(forKey: "BADGECOUNT"))!
                        
                        // custom notification sound
                        if (soundName != "")
                        {
                            bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(string: soundName) as String)
                        }
                        else
                        {
                            bestAttemptContent.sound = .default()
                        }
                        
                        if(bundleName != "")
                        {
                            let groupName = "group."+bundleName+".iZooto"
                            
                            if let userDefaults = UserDefaults(suiteName: groupName) {
                                
                                badgeCount = userDefaults.integer(forKey:"Badge")
                                if badgeCount > 0 {
                                    if(badgeNumber > 0)
                                    {
                                        bestAttemptContent.badge = 1 as NSNumber
                                    }
                                    else
                                    {
                                        userDefaults.set(badgeCount + 1, forKey: "Badge")
                                        bestAttemptContent.badge = badgeCount + 1 as NSNumber
                                    }
                                } else {
                                    userDefaults.set(1, forKey: "Badge")
                                    bestAttemptContent.badge = 1
                                }
                                
                                isEnabled = userDefaults.bool(forKey: AppConstant.iZ_LOG_ENABLED)
                                self.iZTkn = userDefaults.string(forKey: "DEVICETOKEN") ?? ""
                                self.iZPid = userDefaults.integer(forKey: "PID")
                                
                                if (notificationData?.cfg != nil)
                                {
                                    let str = String((notificationData?.cfg)!)
                                    let binaryString = (str.data(using: .utf8, allowLossyConversion: false)?.reduce("") { (a, b) -> String in a + String(b, radix: 2) })
                                    let lastChar = binaryString?.last!
                                    let str1 = String((lastChar)!)
                                    let impr = Int(str1)
                                    if(impr == 1)
                                    {
                                        RestAPI.callImpression(notificationData: notificationData!,userid: self.iZPid,token:"\(self.iZTkn)", userInfo: userInfo)
                                    }
                                }
                                userDefaults.synchronize()
                            }
                            else
                            {
                                if isEnabled == true{
                                    debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_APP_GROUP_ERROR_)
                                }
                                if defaults.value(forKey: "didreceiveGroup") == nil{
                                    defaults.setValue("true", forKey: "didreceiveGroup")
                                    RestAPI.sendExceptionToServer(exceptionName: AppConstant.iZ_APP_GROUP_ERROR_, className: "iZooto", methodName: "didReceive", pid: self.iZPid, token: self.iZTkn, rid: notificationData?.rid ?? "", cid: notificationData?.id ?? "")
                                }
                            }
                        }
                        //Relevance Score
                        self.setRelevanceScore(notificationData: notificationData!, bestAttemptContent: bestAttemptContent)
                        
                        if notificationData?.fetchurl != nil && notificationData?.fetchurl != ""
                        {
                            self.commonFuUrlFetcher(bestAttemptContent: bestAttemptContent, bundleName: bundleName, notificationData: notificationData!, totalData: totalData!, contentHandler: contentHandler)
                        }
                        else{
                            if notificationData != nil
                            {
                                notificationReceivedDelegate?.onNotificationReceived(payload: notificationData!)
                                
                                if notificationData!.category != "" && notificationData!.category != nil
                                {
                                    //to store categories
                                    storeCategories(notificationData: notificationData!, category: "")
                                    
                                    if notificationData?.act1name != "" && notificationData?.act1name != nil {
                                        addCTAButtons()
                                    }
                                    
                                }
                                
                                sleep(1)
                                autoreleasepool {
                                    if let urlString = (notificationData?.alert?.attachment_url),
                                       let fileUrl = URL(string: urlString ) {
                                        guard let imageData = NSData(contentsOf: fileUrl) else {
                                            contentHandler!(bestAttemptContent)
                                            return
                                        }
                                        let string = notificationData?.alert?.attachment_url
                                        let url: URL? = URL(string: string!)
                                        let urlExtension: String? = url?.pathExtension
                                        
                                        guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                            if isEnabled == true{
                                                debugPrint(AppConstant.IMAGE_ERROR)
                                            }
                                            contentHandler!(bestAttemptContent)
                                            return
                                        }
                                        bestAttemptContent.attachments = [ attachment ]
                                    }
                                }
                                contentHandler!(bestAttemptContent)
                            }
                        }
                    }
                    else
                    {
                        // if isEnabled == true{
                        debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                        // }
                        if defaults.value(forKey: "didreceiveOther") == nil{
                            defaults.setValue("true", forKey: "didreceiveOther")
                            RestAPI.sendExceptionToServer(exceptionName: "\(AppConstant.iZ_KEY_OTHER_PAYLOD) \(userInfo)", className: "iZooto", methodName: "didReceive", pid: self.iZPid, token: self.iZTkn, rid: "", cid: "")
                        }
                    }
                }
            }
        }
    }
    
    //To set relevance score in above iOS 15
    @objc private static func setRelevanceScore(notificationData: Payload, bestAttemptContent: UNMutableNotificationContent){
        if #available(iOS 15.0, *) {
            bestAttemptContent.relevanceScore = notificationData.relevence_score ?? 0
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
    
    
    //Common method for fu fetcher
    @objc private static func commonFuUrlFetcher(bestAttemptContent :UNMutableNotificationContent,bundleName: String,notificationData : Payload,totalData: NSDictionary,contentHandler:((UNNotificationContent) -> Void)?){
        
        let defaults = UserDefaults.standard
        
        if notificationData.ankey != nil {
            var adId = ""
            var adLn = ""
            var adTitle = ""
            
            let izUrlString = (notificationData.ankey?.fetchUrlAd!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
            
            let session: URLSession = {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 2
                return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
            }()
            
            if let url = URL(string: izUrlString) {
                session.dataTask(with: url) { data, response, error in
                    if(error != nil)
                    {
                        fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: (notificationData.global?.rid)!, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        return
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data)
                            
                            //To Check FallBack
                            if let jsonDictionary = json as? [String:Any] {
                                if let value = jsonDictionary["msgCode"] as? String {
                                    debugPrint(value)
                                    fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: (notificationData.global?.rid)!, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    return
                                }else{
                                    if let jsonDictionary = json as? [String:Any] {
                                        bestAttemptContent.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.ankey?.titleAd)!))"
                                        bestAttemptContent.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.ankey?.messageAd)!))"
                                        if var landUrl = (notificationData.ankey?.landingUrlAd)  {
                                            landUrl = "\(getParseValue(jsonData: jsonDictionary, sourceString: landUrl))"
                                            adLn = landUrl
                                            if let adIds = notificationData.ankey?.idAd{
                                                adId = adIds
                                            }
                                            adTitle = bestAttemptContent.title
                                            
                                            myIdLnArray.removeAll()
                                            let dict  = [AppConstant.iZ_IDKEY: adId, AppConstant.iZ_LNKEY: adLn, AppConstant.iZ_TITLE_KEY: adTitle]
                                            myIdLnArray.append(dict)
                                        }
                                        if notificationData.ankey?.bannerImageAd != "" {
                                            
                                            notificationData.ankey?.bannerImageAd = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.ankey?.bannerImageAd)!))"
                                            if ((notificationData.ankey?.bannerImageAd!.contains(".webp")) != nil)
                                            {
                                                notificationData.ankey?.bannerImageAd = notificationData.ankey?.bannerImageAd?.replacingOccurrences(of: ".webp", with: ".jpeg")
                                                
                                            }
                                            if ((notificationData.ankey?.bannerImageAd!.contains("http:")) != nil)
                                            {
                                                notificationData.ankey?.bannerImageAd = notificationData.ankey?.bannerImageAd?.replacingOccurrences(of: "http:", with: "https:")
                                            }
                                        }
                                        //Check & hit RC for adMediation
                                        if notificationData.ankey?.adrc != nil{
                                            adMediationRCDataStore(totalData: totalData, jsonDictionary: jsonDictionary, bundleName: bundleName, aDId : (notificationData.ankey?.idAd)! )
                                        }
                                        
                                        //Check & hit the RV for adMediation
                                        if ((notificationData.ankey?.adrv != nil)){
                                            adMediationRVApiCall(totalData: totalData, jsonDictionary: jsonDictionary)
                                        }
                                    }
                                }
                            }else{
                                
                                if let jsonArray = json as? [[String:Any]] {
                                    if jsonArray[0]["msgCode"] is String {
                                        fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: (notificationData.global?.rid)!, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                        return
                                    }else{
                                        bestAttemptContent.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.ankey?.titleAd)!))"
                                        bestAttemptContent.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.ankey?.messageAd)!))"
                                        
                                        if var landUrl = (notificationData.ankey?.landingUrlAd)  {
                                            landUrl = "\(getParseArrayValue(jsonData: jsonArray, sourceString: landUrl))"
                                            adLn = landUrl
                                            if let adIds = notificationData.ankey?.idAd{
                                                adId = adIds
                                            }
                                            adTitle = bestAttemptContent.title
                                            myIdLnArray.removeAll()
                                            let dict  = [AppConstant.iZ_IDKEY: adId, AppConstant.iZ_LNKEY: adLn, AppConstant.iZ_TITLE_KEY: adTitle]
                                            myIdLnArray.append(dict)
                                        }
                                        if notificationData.ankey?.bannerImageAd != "" {
                                            notificationData.ankey?.bannerImageAd = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.ankey?.bannerImageAd)!))"
                                            if ((notificationData.ankey?.bannerImageAd!.contains(".webp")) != nil)
                                            {
                                                notificationData.ankey?.bannerImageAd = notificationData.ankey?.bannerImageAd?.replacingOccurrences(of: ".webp", with: ".jpg")
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if notificationData.category != "" && notificationData.category != nil
                            {
                                storeCategories(notificationData: notificationData, category: "")
                                
                                if notificationData.global!.act1name != "" && notificationData.global!.act1name != nil{
                                    addCTAButtons()
                                }
                            }
                            
                            sleep(1)
                            autoreleasepool {
                                if let urlString = (notificationData.ankey?.bannerImageAd),
                                   let fileUrl = URL(string: urlString ) {
                                    
                                    guard let imageData = NSData(contentsOf: fileUrl) else {
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    let string = notificationData.ankey?.bannerImageAd
                                    let url: URL? = URL(string: string!)
                                    let urlExtension: String? = url?.pathExtension
                                    guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                        debugPrint(AppConstant.IMAGE_ERROR)
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    bestAttemptContent.attachments = [ attachment ]
                                }
                            }
                            storeNotiUrl_ln(bundleName: bundleName)
                            //call impression
                            self.ad_mediationImpressionCall(notiRid: (notificationData.global?.rid)!, adTitle: adTitle, adLn: adLn, bundleName: bundleName)
                            
                            // Need to review
                            if bestAttemptContent.title == notificationData.ankey?.titleAd{
                                self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "",notiRid: (notificationData.global?.rid)!, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            }else{
                                contentHandler!(bestAttemptContent)
                            }
                        } catch {
                            self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "",notiRid: (notificationData.global?.rid)!, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        }
                    }
                    
                }.resume()
            }else{
                debugPrint("Not Found")
                if defaults.value(forKey: "commonfetchUrl") == nil{
                    defaults.setValue("true", forKey: "commonfetchUrl")
                    RestAPI.sendExceptionToServer(exceptionName: "Mediation fetch url is not in correct format = \(izUrlString)", className: "iZooto", methodName: "commonFetchUrl", pid: self.iZPid, token: self.iZTkn, rid: notificationData.global?.rid ?? "" , cid: notificationData.global?.id ?? "")
                }
            }
            
        }else{
            let izUrlString = (notificationData.fetchurl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
            
            
            let session: URLSession = {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 2
                return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
            }()
            
            if let url = URL(string: izUrlString) {
                session.dataTask(with: url) { data, response, error in
                    if(error != nil)
                    {
                        fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        return
                    }
                    if response == nil{
                        debugPrint("RESPONSE ======+++++++++++++++")
                    }
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data)
                            
                            //To Check FallBack
                            if let jsonDictionary = json as? [String:Any] {
                                if let value = jsonDictionary["msgCode"] as? String {
                                    fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                    return
                                }else{
                                    if let jsonDictionary = json as? [String:Any] {
                                        bestAttemptContent.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.alert?.title)!))"
                                        bestAttemptContent.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.alert?.body)!))"
                                        if notificationData.url != "" {
                                            notificationData.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.url)!))"
                                        }
                                        if notificationData.alert?.attachment_url != "" {
                                            
                                            notificationData.alert?.attachment_url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData.alert?.attachment_url)!))"
                                            if ((notificationData.alert?.attachment_url!.contains(".webp")) != nil)
                                            {
                                                notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpeg")
                                                
                                            }
                                            if ((notificationData.alert?.attachment_url!.contains("http:")) != nil)
                                            {
                                                notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: "http:", with: "https:")
                                                
                                            }
                                        }
                                        if notificationData.furv != nil {
                                            adMediationRVApiCall(totalData: totalData, jsonDictionary: jsonDictionary)
                                        }
                                    }
                                }
                            }else{
                                
                                if let jsonArray = json as? [[String:Any]] {
                                    if jsonArray[0]["msgCode"] is String {
                                        fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                                        return
                                    }else{
                                        bestAttemptContent.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.alert?.title)!))"
                                        bestAttemptContent.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.alert?.body)!))"
                                        if notificationData.url != "" {
                                            notificationData.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.url)!))"
                                            // print("URL TO TEST LANDING", notificationData.url)
                                        }
                                        if notificationData.alert?.attachment_url != "" {
                                            notificationData.alert?.attachment_url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData.alert?.attachment_url)!))"
                                            if ((notificationData.alert?.attachment_url!.contains(".webp")) != nil)
                                            {
                                                notificationData.alert?.attachment_url = notificationData.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpg")
                                            }
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
                            
                            sleep(1)
                            autoreleasepool {
                                if let urlString = (notificationData.alert?.attachment_url),
                                   let fileUrl = URL(string: urlString ) {
                                    
                                    guard let imageData = NSData(contentsOf: fileUrl) else {
                                        //  if (UserDefaults.standard.bool(forKey: "Subscribe")) == true{
                                        contentHandler!(bestAttemptContent)
                                        //  }
                                        return
                                    }
                                    let string = notificationData.alert?.attachment_url
                                    let url: URL? = URL(string: string!)
                                    let urlExtension: String? = url?.pathExtension
                                    guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                        debugPrint(AppConstant.IMAGE_ERROR)
                                        contentHandler!(bestAttemptContent)
                                        return
                                    }
                                    bestAttemptContent.attachments = [ attachment ]
                                }
                            }
                            if bestAttemptContent.title == notificationData.ankey?.titleAd{
                                self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "", notiRid: "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                            }else{
                                contentHandler!(bestAttemptContent)
                            }
                            
                        } catch {
                            self.fallBackAdsApi(bundleName: bundleName, fallCategory: notificationData.category ?? "",notiRid: "", bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                        }
                    }
                }.resume()
            }else{
                debugPrint("Not Found")
                if defaults.value(forKey: "commonfetchUrl") == nil{
                    defaults.setValue("true", forKey: "commonfetchUrl")
                    RestAPI.sendExceptionToServer(exceptionName: "Fetcher url is not in correct format = \(izUrlString)", className: "iZooto", methodName: "commonfetchUrl", pid: self.iZPid, token: self.iZTkn, rid: notificationData.rid ?? "", cid: notificationData.id ?? "")
                }
            }
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
                button1Name = notificationData.global!.act1name ?? ""
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
            tempArray = UserDefaults.standard.value(forKey: AppConstant.iZ_CategoryArray) as! [[String : Any]]
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
        
        if UserDefaults.standard.array(forKey: AppConstant.iZ_CategoryArray)!.count != 0{
            catArray  = UserDefaults.standard.array(forKey: AppConstant.iZ_CategoryArray)!
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
                    
                    let category = UNNotificationCategory( identifier: categoryId!, actions: [firstAction, secondAtion], intentIdentifiers: [], options: [])
                    
                    notificationCategories.insert(category)
                    
                }else{
                    if name1 != ""{
                        if(name1.contains("~"))
                        {
                            name1 = name1.replacingOccurrences(of: "~", with: "")
                        }
                        let firstAction = UNNotificationAction( identifier: name1Id, title: " \(name1)", options: .foreground)
                        let category = UNNotificationCategory( identifier: categoryId!, actions: [firstAction], intentIdentifiers: [], options: [])
                        notificationCategories.insert(category)
                    }
                }
            }
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(granted, error) in
            if !granted {
                print("Notification access denied.")
            }
            center.setNotificationCategories(notificationCategories)
        }
    }
    
    //To call Mediation-impression
    @objc private static func ad_mediationImpressionCall(notiRid: String, adTitle: String, adLn: String, bundleName: String){
        let groupName = "group."+bundleName+".iZooto"
        if let userDefaults = UserDefaults(suiteName: groupName){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as? [[String : Any]]{
                let tempIdArray = ids
                for data in ids {
                    if let dataDict = data as? NSDictionary {
                        if (dataDict.value(forKey: "rid") as! String) == notiRid {
                            let finalData = dataDict.mutableCopy() as? NSDictionary
                            let served = finalData!.value(forKey: "served") as? NSDictionary
                            let finalServed = served!.mutableCopy() as? NSDictionary
                            finalServed?.setValue(adTitle, forKey: "ti")
                            finalServed!.setValue(adLn, forKey: "ln")
                            finalData!.setValue(finalServed, forKey: "served")
                            RestAPI.callAdMediationImpressionApi(finalDict: finalData!)
                            userDefaults.setValue(tempIdArray, forKey: AppConstant.iZ_BIDS_SERVED_ARRAY)
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
    }
    
    //for rid & bids call mediation click
    @objc private static func ad_mediationClickCall(notiRid: String, adTitle: String, adLn: String){
        
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as? [[String : Any]]{
                var tempIdArray = ids
                for (index,data) in ids.enumerated() {
                    if let dataDict = data as? NSDictionary {
                        if (dataDict.value(forKey: "rid") as! String) == notiRid {
                            let finalData = dataDict.mutableCopy() as? NSDictionary
                            let served = finalData!.value(forKey: "served") as? NSDictionary
                            let finalServed = served!.mutableCopy() as? NSDictionary
                            finalServed?.setValue(adTitle, forKey: "ti")
                            finalServed!.setValue(adLn, forKey: "ln")
                            finalData!.setValue(finalServed, forKey: "served")
                            RestAPI.callAdMediationClickApi(finalDict: finalData!)
                            if index <= tempIdArray.count - 1{
                                tempIdArray.remove(at: index)
                            }
                            userDefaults.setValue(tempIdArray, forKey: AppConstant.iZ_BIDS_SERVED_ARRAY)
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
    }
    
    
    //to hit & remove the landing Url On click Noti
    @objc private static func ad_mediationLandingUrlOnClick(anKey: NSArray) -> String{
        var idArray: [[String:Any]] = []
        var landing = ""
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_LN_ID_ARRAY) as? [[String : Any]]{
                idArray = ids
            }
            //for Ln & Id
            for dataaa in anKey {
                if let dict = dataaa as? NSDictionary {
                    let id = dict.value(forKey: AppConstant.iZ_IDKEY) as? String
                    let filterValue = idArray.filter {$0[AppConstant.iZ_IDKEY] as? String == id}
                    
                    if !filterValue.isEmpty{
                        if let value1 = filterValue[0] as? NSDictionary {
                            landing = value1.value(forKey: AppConstant.iZ_LNKEY) as! String
                            if let index = idArray.firstIndex(where: {$0[AppConstant.iZ_LNKEY] as? String  == landing }) {
                                idArray.remove(at: index)
                            }
                            userDefaults.setValue(idArray, forKey: AppConstant.iZ_LN_ID_ARRAY)
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
        if landing == ""{
            landing = RestAPI.fallBackLandingUrl
        }
        return landing
    }
    
    //to hit the Title On click Noti
    @objc private static func ad_mediationTitleOnClick(anKey: NSArray) -> String{
        var idArray: [[String:Any]] = []
        var title = ""
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_LN_ID_ARRAY) as? [[String : Any]]{
                idArray = ids
            }
            //for Ln & Id
            for dataaa in anKey {
                if let dict = dataaa as? NSDictionary {
                    let id = dict.value(forKey: AppConstant.iZ_IDKEY) as? String
                    let filterValue = idArray.filter {$0[AppConstant.iZ_IDKEY] as? String == id}
                    
                    if !filterValue.isEmpty{
                        if let value1 = filterValue[0] as? NSDictionary {
                            title = value1.value(forKey: AppConstant.iZ_TITLE_KEY) as! String
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
        if title == ""{
            title = RestAPI.fallBackTitle
        }
        return title
    }
    
    //Store fallBack ln & id
    @objc private static func storeNotiUrl_ln(bundleName: String){
        let groupName = "group."+bundleName+".iZooto"
        if let userDefaults = UserDefaults(suiteName: groupName) {
            var tempArray: [[String : Any]] = []
            if userDefaults.value(forKey: AppConstant.iZ_LN_ID_ARRAY) != nil {
                tempArray = userDefaults.value(forKey: AppConstant.iZ_LN_ID_ARRAY) as! [[String : Any]]
            }
            tempArray.append(contentsOf: myIdLnArray)
            userDefaults.setValue(tempArray, forKey: AppConstant.iZ_LN_ID_ARRAY)
            userDefaults.synchronize()
        }
    }
    
    @objc private static func storeBids(bundleName: String, finalData: NSMutableDictionary){
        let groupName = "group."+bundleName+".iZooto"
        if let userDefaults = UserDefaults(suiteName: groupName) {
            var tempArray: [[String : Any]] = []
            if userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) != nil {
                tempArray = userDefaults.value(forKey: AppConstant.iZ_BIDS_SERVED_ARRAY) as! [[String : Any]]
            }
            tempArray.append(finalData as! [String : Any])
            userDefaults.setValue(tempArray, forKey: AppConstant.iZ_BIDS_SERVED_ARRAY)
            userDefaults.synchronize()
        }
    }
    
    //hit RV with notificatiuon display on devices
    @objc private static func adMediationRVApiCall(totalData: NSDictionary,jsonDictionary: [String:Any] ){
        
        var tempArray = [String]()
        if let annKey = totalData.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
            
            if  let rvValue = annKey.value(forKey: "rv") as? NSArray {
                let finalValue = rvValue[0] as! NSArray
                for value in finalValue{
                    let finalRV = "\(getParseValue(jsonData: jsonDictionary , sourceString: value as! String))"
                    tempArray.append(finalRV)
                }
                for valuee in tempArray{
                    RestAPI.callRV_RC_Request(urlString: valuee)
                }
                tempArray.removeAll()
            }
        }else{
            if let rvValue = totalData.value(forKey: "rv") as? NSArray {
                for value in rvValue{
                    let finalRV = "\(getParseValue(jsonData: jsonDictionary , sourceString: value as! String))"
                    tempArray.append(finalRV)
                }
                for valuee in tempArray{
                    RestAPI.callRV_RC_Request(urlString: valuee)
                }
                tempArray.removeAll()
            }
        }
    }
    
    
    //Store RC with notificatiuon appear & hit on noti clicked by user
    @objc private static func adMediationRCDataStore(totalData: NSDictionary,jsonDictionary: [String:Any], bundleName: String, aDId: String){
        
        var temArray = [String]()
        if let annKey = totalData.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
            
            if  let rvValue = annKey.value(forKey: "rc") as? NSArray {
                
                let finalValue = rvValue[0] as! NSArray
                myRCArray.removeAll()
                for value in finalValue{
                    
                    let finalRC = "\(getParseValue(jsonData: jsonDictionary , sourceString: value as! String))"
                    temArray.append(finalRC)
                    
                }
                let dict = ["id": aDId, "rc": temArray] as [String : Any]
                myRCArray.append(dict)
                
                let groupName = "group."+bundleName+".iZooto"
                if let userDefaults = UserDefaults(suiteName: groupName) {
                    var tempArray: [[String : Any]] = []
                    if userDefaults.value(forKey: AppConstant.iZ_rcArray) != nil {
                        tempArray = userDefaults.value(forKey: AppConstant.iZ_rcArray) as! [[String : Any]]
                    }
                    tempArray.append(contentsOf: myRCArray)
                    userDefaults.setValue(tempArray, forKey: AppConstant.iZ_rcArray)
                    userDefaults.synchronize()
                }
            }
        }
    }
    
    
    //Hit the RC on click Notification
    @objc private static func getRcAndHitAPI(anKey: NSArray){
        var idArray: [[String:Any]] = []
        var rcArray: NSArray = []
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()){
            if let ids = userDefaults.value(forKey: AppConstant.iZ_rcArray) as? [[String : Any]]{
                idArray = ids
            }
            //for Ln & Id
            for dataaa in anKey {
                if let dict = dataaa as? NSDictionary {
                    let id = dict.value(forKey: AppConstant.iZ_IDKEY) as? String
                    let filterValue = idArray.filter {$0[AppConstant.iZ_IDKEY] as? String == id}
                    
                    if !filterValue.isEmpty{
                        if let value1 = filterValue[0] as? NSDictionary {
                            rcArray = value1.value(forKey: "rc") as! NSArray
                            let iddd = value1.value(forKey: AppConstant.iZ_IDKEY) as! String
                            if let index = idArray.firstIndex(where: {$0[AppConstant.iZ_IDKEY] as? String  == iddd }) {
                                idArray.remove(at: index)
                            }
                            userDefaults.setValue(idArray, forKey: AppConstant.iZ_rcArray)
                            userDefaults.synchronize()
                        }
                    }
                    for valuee in rcArray{
                        RestAPI.callRV_RC_Request(urlString: valuee as! String)
                    }
                    break
                }
            }
        }
    }
    
    // for json aaray
    @objc  private static func getParseArrayValue(jsonData :[[String : Any]], sourceString : String) -> String
    {
        if(sourceString.contains("~"))
        {
            return sourceString.replacingOccurrences(of: "~", with: "")
        }
        else
        {
            if(sourceString.contains("."))//[0].title -? [0].title // ads .[0].title
            
            {
                let array = sourceString.split(separator: ".")
                let value = "\(array[0])".replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                let data = Int(value)
                let data1 = jsonData[data!]
                let lastData = array.last
                let res = String(lastData!)
                return   data1[res]! as! String
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
                debugPrint("enabled notification setting")
                
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
            sharedUserDefault?.set(pluginVersion, forKey: "Plugin_Version")
        }else{
            sharedUserDefault?.set("", forKey: "Plugin_Version")
        }
    }
    
    // for jsonObject
    @objc private static func getParseValue(jsonData :[String : Any], sourceString : String) -> String
    {
        if(sourceString.contains("~"))
        {
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
                                return responseData["\(array[1])"]! as! String
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
                                return responseData["\(array[2])"]! as! String
                            }
                        }
                        else
                        {
                            if let content = jsonData["\(array[0])"] as? [String:Any] {
                                let value = content["\(array[1])"] as! [String:Any]
                                let fvalue = value["\(array[2])"] as! String
                                return fvalue
                            }
                        }
                    }
                }
                if (count == 4){
                    let array = sourceString.split(separator: ".")
                    let response = jsonData["\(array[0])"] as! [String:Any]
                    let documents = response["\(array[1])"] as! [String:Any]
                    //  let field = documents["\(array[2])"] as! [[String:Any]]
                    let field = documents["doc"] as! [[String:Any]]
                    
                    if !field.isEmpty{
                        if (field[0]["\(array[3])"] as? String != nil){
                            let name = field[0]["\(array[3])"]!
                            return (name as? String)!
                            
                        }else if (field[0]["\(array[3])"] as? NSArray != nil){
                            let name = field[0]["\(array[3])"]!
                            if let checkName = name as? NSArray{
                                let finalName = checkName[0] as! String
                                return finalName
                            }
                        }else{
                            return sourceString
                        }
                    }
                }
                if (count == 5){
                    if sourceString.contains("list"){
                        let array = sourceString.split(separator: ".")
                        let response = jsonData["\(array[0])"] as! [[String:Any]]
                        if response.count != 0{
                            let documents = response[0]
                            let field = documents["\(array[2])"] as! [[String:Any]]
                            if(field.count>0)
                            {
                                // let responseData = field[0]["\(array[3])"]as! [String:Any]
                                let response  = field[0]["\(array[4])"]!
                                return response as! String
                            }
                        }
                    }
                    else{
                        
                        let array = sourceString.split(separator: ".")
                        let response = jsonData["\(array[0])"] as! [String:Any]
                        let documents = response["\(array[1])"] as! [String:Any]
                        // let field = documents["\("doc")"] as! [[String:Any]]
                        let field = documents["doc"] as! [[String:Any]]
                        
                        if(!field.isEmpty)
                        {
                            let responseData = field[0]["\(array[3])"]as! [String:Any]
                            let response  = responseData["\(array[4])"]!
                            return response as! String
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
    @objc  private static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                debugPrint(error.localizedDescription)
                let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)) ?? 0
                let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? "No token here"
                RestAPI.sendExceptionToServer(exceptionName: error.localizedDescription, className: "iZooto", methodName: "convertToDictionary", pid: userID, token: token, rid: "0", cid: "0")
            }
        }
        return nil
    }
    
    // Handle the Notification behaviour
    @objc  public static func handleForeGroundNotification(notification : UNNotification,displayNotification : String,completionHandler : @escaping (UNNotificationPresentationOptions) -> Void)
    
    {
        let defaults = UserDefaults.standard
        let appstate = UIApplication.shared.applicationState
        if (appstate == .active && displayNotification == AppConstant.iZ_KEY_IN_APP_ALERT)
        {
            
            let userInfo = notification.request.content.userInfo
            let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
            
            let alert = UIAlertController(title: notificationData?.alert?.title, message:notificationData?.alert?.body, preferredStyle: UIAlertController.Style.alert)
            if (notificationData?.act1name != nil && notificationData?.act1name != ""){
                alert.addAction(UIAlertAction(title: notificationData?.act1name, style: .default, handler: { (action: UIAlertAction!) in
                    // UIApplication.shared.openURL(NSURL(string: notificationData!.act1link!)! as URL)
                    
                }))
            }
            if (notificationData?.act2name != nil && notificationData?.act2name != "")
            {
                alert.addAction(UIAlertAction(title: notificationData?.act2name, style: .default, handler: { (action: UIAlertAction!) in
                    
                    let izUrlStr = notificationData!.act2link!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    if let url = URL(string:izUrlStr!) {
                        
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
                    if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) {
                        debugPrint(anKey)
                        let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                        
                        if notificationData?.ankey != nil {
                            if(notificationData?.ankey?.fetchUrlAd != "" && notificationData?.ankey?.fetchUrlAd != nil)
                            {
                                if(notificationData?.global?.inApp != nil)
                                {
                                    
                                    if (notificationData?.global?.cfg != nil)
                                    {
                                        impressionTrack(notificationData: notificationData!, userInfo: userInfo)
                                    }
                                    completionHandler([.badge, .alert, .sound])
                                }
                            }
                            else
                            {
                                if(notificationData?.global?.inApp != nil)
                                {
                                    if (notificationData?.global?.cfg != nil)
                                    {
                                        impressionTrack(notificationData: notificationData!, userInfo: userInfo)
                                    }
                                    completionHandler([.badge, .alert, .sound])
                                }
                                else
                                {
                                    let isEnabled = UserDefaults.standard.bool(forKey: AppConstant.iZ_LOG_ENABLED)
                                    if isEnabled {
                                        debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                                    }
                                    
                                    if defaults.value(forKey: "handleForeGroundNotification") == nil{
                                        defaults.setValue("true", forKey: "handleForeGroundNotification")
                                        RestAPI.sendExceptionToServer(exceptionName: "iZooto Payload is not exits\(userInfo)", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "handleForeGroundNotification", pid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, rid: "",cid : "")
                                    }
                                }
                            }
                        }
                    }else{
                        let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                        
                        if(notificationData?.fetchurl != "" && notificationData?.fetchurl != nil)
                        {
                            if (notificationData?.cfg != nil)
                            {
                                impressionTrack(notificationData: notificationData!, userInfo: userInfo)
                            }
                            completionHandler([.badge, .alert, .sound])
                        }
                        else
                        {
                            if(notificationData?.inApp != nil)
                            {
                                notificationReceivedDelegate?.onNotificationReceived(payload: notificationData!)
                                if (notificationData?.cfg != nil)
                                {
                                    impressionTrack(notificationData: notificationData!, userInfo: userInfo)
                                }
                                completionHandler([.badge, .alert, .sound])
                            }
                            else
                            {
                                let isEnabled = UserDefaults.standard.bool(forKey: AppConstant.iZ_LOG_ENABLED)
                                if isEnabled {
                                    debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_OTHER_PAYLOD)
                                }
                                if defaults.value(forKey: "handleForeGroundNotification") == nil{
                                    defaults.setValue("true", forKey: "handleForeGroundNotification")
                                    RestAPI.sendExceptionToServer(exceptionName: "iZooto Payload is not exits\(userInfo)", className:"iZooto", methodName: "handleForeGroundNotification", pid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, rid: "",cid : "")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // handel the fallback url
    @objc public static func fallbackClickHandler(){
        
        let str = RestAPI.FALLBACK_URL
        let izUrlString = (str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        if let url = URL(string: izUrlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        if let jsonDictionary = json as? [String:Any] {
                            let notificationData = Payload(dictionary: (jsonDictionary) as NSDictionary)
                            if notificationData?.url! != "" {
                                
                                notificationData?.url = jsonDictionary[AppConstant.iZ_LNKEY] as? String
                                let izUrlStr = notificationData?.url!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                
                                if let url = URL(string:izUrlStr!) {
                                    if notificationData?.act1name != nil && notificationData?.act1name != ""
                                    {
                                        DispatchQueue.main.async {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    else
                                    {
                                        DispatchQueue.main.async {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                }
                            }
                        }
                    } catch let error {
                        debugPrint("Error",error)
                        let defaults = UserDefaults.standard
                        if defaults.value(forKey: "FallbackClickHandler") == nil{
                            defaults.setValue("true", forKey: "FallbackClickHandler")
                            RestAPI.sendExceptionToServer(exceptionName: "Error in fallback click API= \(izUrlString)", className: "iZooto", methodName: "FallbackClickHandler", pid: self.iZPid, token: self.iZTkn, rid: "",cid : "")
                        }
                    }
                }
            }.resume()
        }else{
            debugPrint("Wrong URL")
            let defaults = UserDefaults.standard
            if defaults.value(forKey: "FallbackClickHandler") == nil{
                defaults.setValue("true", forKey: "FallbackClickHandler")
                RestAPI.sendExceptionToServer(exceptionName: "Error in fallback click API \(izUrlString)", className: "iZooto", methodName: "FallbackClickHandler", pid: self.iZPid, token: self.iZTkn, rid: "",cid : "")
            }
        }
    }
    
    // Handle the clicks the notification from Banner,Button
    @objc public static func notificationHandler(response : UNNotificationResponse)
    {
        
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
            let badgeC = userDefaults.integer(forKey:"Badge")
            self.badgeCount = badgeC
            userDefaults.set(badgeC - 1, forKey: "Badge")
            RestAPI.fallBackLandingUrl = userDefaults.value(forKey: "fallBackLandingUrl") as? String ?? ""
            RestAPI.fallBackTitle = userDefaults.value(forKey: "fallBackTitle") as? String ?? ""
            userDefaults.synchronize()
        }
        
        badgeNumber = (sharedUserDefault?.integer(forKey: "BADGECOUNT"))!
        if(badgeNumber == -1)
        {
            UIApplication.shared.applicationIconBadgeNumber = -1 // clear the badge count // notification is not removed
        }
        else if(badgeNumber == 1)
        {
            UIApplication.shared.applicationIconBadgeNumber = 0 // clear the badge count
        }else{
            UIApplication.shared.applicationIconBadgeNumber = self.badgeCount - 1 //set badge default value
        }
        
        let userInfo = response.notification.request.content.userInfo
        
        var adlandingURL:String = ""
        var adTitle:String = ""
        let indexx = 0
        if let jsonDictionary = userInfo as? [String:Any] {
            if let aps = jsonDictionary["aps"] as? NSDictionary{
                if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                    debugPrint(anKey)
                    var finalData = [String: Any]()
                    let tempData = NSMutableDictionary()
                    var alertData = [String: Any]()
                    var gData = [String: Any]()
                    var anData: [[String: Any]] = []
                    
                    if let alert = aps.value(forKey: AppConstant.iZ_ALERTKEY) {
                        alertData = alert as! [String : Any]
                    }
                    if let gt = aps.value(forKey: AppConstant.iZ_G_KEY) as? NSDictionary {
                        gData = gt as! [String : Any]
                    }
                    
                    if let anKey = aps.value(forKey: AppConstant.iZ_ANKEY) as? NSArray {
                        
                        //To get clicked Notification landing Url
                        adTitle = self.ad_mediationTitleOnClick(anKey: anKey)
                        adlandingURL = self.ad_mediationLandingUrlOnClick(anKey: anKey)
                        
                        getRcAndHitAPI(anKey: anKey)
                        
                        anData = [anKey[indexx] as! [String : Any]]
                        tempData.setValue(alertData, forKey: AppConstant.iZ_ALERTKEY)
                        tempData.setValue(anData, forKey: AppConstant.iZ_ANKEY)
                        tempData.setValue(gData, forKey: AppConstant.iZ_G_KEY)
                        
                        tempData.setValue(1, forKey: "mutable-content")
                        tempData.setValue(0, forKey: "content_available")
                        
                        finalData["aps"] = tempData
                    }
                    
                    let notificationData = Payload(dictionary: (finalData["aps"] as? NSDictionary)!)
                    
                    clickTrack(notificationData: notificationData!, actionType: "0", userInfo: userInfo)
                    let notiRid = notificationData?.global?.rid
                    //for rid & bids call Ad-mediation click
                    self.ad_mediationClickCall(notiRid: notiRid!, adTitle: adTitle, adLn: adlandingURL)
                    
                    if notificationData?.ankey != nil{
                        if adlandingURL != ""
                        {
                            if let unencodedURLString = adlandingURL.removingPercentEncoding {
                                adlandingURL = unencodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                            } else {
                                adlandingURL = adlandingURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                            }
                            
                            if let url = URL(string: adlandingURL) {
                                if notificationData?.global!.act1name != nil && notificationData?.global!.act1name != ""
                                {
                                    DispatchQueue.main.async {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                else
                                {
                                    DispatchQueue.main.async {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }else{
                                print("")
                            }
                        }else{
                            let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)) ?? 0
                            let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? ""
                            let defaults = UserDefaults.standard
                            if defaults.value(forKey: "NotificationHandlerrr") == nil{
                                defaults.setValue("true", forKey: "NotificationHandlerrr")
                                RestAPI.sendExceptionToServer(exceptionName: "Mediation LandingUrl is blank", className: "iZooto", methodName: "notificationHandler", pid: userID, token: token, rid: notiRid ?? "", cid: notificationData?.global?.id ?? "")
                            }
                        }
                    }
                }else{
                    let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                    
                    if notificationData?.fetchurl != nil && notificationData?.fetchurl != ""
                    {
                        clickTrack(notificationData: notificationData!, actionType: "0", userInfo: userInfo)
                        
                        let izUrlString = (notificationData?.fetchurl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
                        
                        let session: URLSession = {
                            let configuration = URLSessionConfiguration.default
                            configuration.timeoutIntervalForRequest = 2
                            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
                        }()
                        if let url = URL(string: izUrlString)
                        {
                            session.dataTask(with: url) { data, response, error in
                                if error != nil{
                                    self.fallbackClickHandler()
                                }
                                if let data = data {
                                    do {
                                        
                                        let json = try JSONSerialization.jsonObject(with: data)
                                        
                                        //To Check FallBack
                                        if let jsonDictionary = json as? [String:Any] {
                                            if let value = jsonDictionary["msgCode"] as? String {
                                                debugPrint(value)
                                                self.fallbackClickHandler()
                                                
                                            }else{
                                                if let jsonDictionary = json as? [String:Any] {
                                                    
                                                    if notificationData?.url != "" {
                                                        notificationData?.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notificationData?.url)!))"
                                                        
                                                        var stringUrl = notificationData?.url
                                                        
                                                        if let unencodedURLString = stringUrl?.removingPercentEncoding {
                                                            stringUrl = unencodedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                                        } else {
                                                            stringUrl = stringUrl!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                                                        }
                                                        
                                                        if let url = URL(string: stringUrl!) {
                                                            if notificationData?.act1name != nil && notificationData?.act1name != ""
                                                            {
                                                                DispatchQueue.main.async {
                                                                    UIApplication.shared.open(url)
                                                                }
                                                            }
                                                            else
                                                            {
                                                                DispatchQueue.main.async {
                                                                    UIApplication.shared.open(url)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    if notificationData?.furc != nil{
                                                        var tempArray = [String]()
                                                        if let rcValue = aps.value(forKey: "rc") as? NSArray {
                                                            for value in rcValue{
                                                                let finalRC = "\(getParseValue(jsonData: jsonDictionary , sourceString: value as! String))"
                                                                tempArray.append(finalRC)
                                                            }
                                                            for valuee in tempArray{
                                                                RestAPI.callRV_RC_Request(urlString: valuee)
                                                            }
                                                            tempArray.removeAll()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            if let jsonArray = json as? [[String:Any]] {
                                                if notificationData?.url != "" {
                                                    
                                                    notificationData?.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notificationData?.url)!))"
                                                    let izUrlStr = notificationData?.url!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                                    
                                                    if notificationData?.act1name != nil && notificationData?.act1name != ""
                                                    {
                                                        if let url = URL(string:izUrlStr!) {
                                                            DispatchQueue.main.async {
                                                                UIApplication.shared.open(url)
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        if let url = URL(string:izUrlStr!) {
                                                            DispatchQueue.main.async {
                                                                UIApplication.shared.open(url)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } catch let error {
                                        debugPrint(AppConstant.TAG,error)
                                        
                                        //FallBack_Click Handler method.....
                                        self.fallbackClickHandler()
                                        let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)) ?? 0
                                        let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? ""
                                        let rid = (notificationData?.rid) ?? ""
                                        let defaults = UserDefaults.standard
                                        if defaults.value(forKey: "NotificationHandlerr") == nil{
                                            defaults.setValue("true", forKey: "NotificationHandlerr")
                                            RestAPI.sendExceptionToServer(exceptionName: error.localizedDescription, className: "iZooto", methodName: "notificationHandler", pid: userID, token: token, rid: rid, cid: notificationData?.rid ?? "")
                                        }
                                    }
                                }
                            }.resume()
                        }
                    }
                    else
                    {
                        notificationReceivedDelegate?.onNotificationReceived(payload: notificationData!)
                        
                        if notificationData?.category != nil && notificationData?.category != ""
                        {
                            if response.actionIdentifier == AppConstant.FIRST_BUTTON{
                                
                                type = "1"
                                clickTrack(notificationData: notificationData!, actionType: "1", userInfo: userInfo)
                                
                                if notificationData?.ap != "" && notificationData?.ap != nil
                                {
                                    handleClicks(response: response, actionType: "1")
                                }
                                else
                                {
                                    if notificationData?.act1link != nil && notificationData?.act1link != ""
                                    {
                                        let launchURl = notificationData?.act1link!
                                        if launchURl!.contains("tel:")
                                        {
                                            if let url = URL(string: launchURl!)
                                            {
                                                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                            }
                                        }
                                        else
                                        {
                                            if ((notificationData?.inApp?.contains("1"))! && notificationData?.inApp != "" && notificationData?.act1link != nil && notificationData?.act1link != "")
                                            {
                                                
                                                let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                                if checkWebview!
                                                {
                                                    landingURLDelegate?.onHandleLandingURL(url: (notificationData?.act1link)!)
                                                }
                                                else
                                                {
                                                    ViewController.seriveURL = notificationData?.act1link
                                                    UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                }
                                            }
                                            else
                                            {
                                                if(notificationData?.fetchurl != "" && notificationData?.fetchurl != nil)
                                                {
                                                    handleBroserNotification(url: (notificationData?.url)!)
                                                    
                                                }
                                                else
                                                {
                                                    if notificationData!.act1link == nil {
                                                        debugPrint("")
                                                    }
                                                    else
                                                    {
                                                        handleBroserNotification(url: (notificationData?.act1link)!)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else if response.actionIdentifier == AppConstant.SECOND_BUTTON{
                                type = "2"
                                clickTrack(notificationData: notificationData!, actionType: "2", userInfo: userInfo)
                                if notificationData?.ap != "" && notificationData?.ap != nil
                                {
                                    handleClicks(response: response, actionType: "2")
                                }
                                else
                                {
                                    if notificationData?.act2link != nil && notificationData?.act2link != ""
                                    {
                                        let launchURl = notificationData?.act2link!
                                        if launchURl!.contains("tel:")
                                        {
                                            if let url = URL(string: launchURl!)
                                            {
                                                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                            }
                                        }
                                        else
                                        {
                                            if ((notificationData?.inApp?.contains("1"))! && notificationData?.inApp != "" && notificationData?.act2link != nil && notificationData?.act2link != "")
                                            {
                                                
                                                let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                                if checkWebview!
                                                {
                                                    landingURLDelegate?.onHandleLandingURL(url: (notificationData?.act2link)!)
                                                }
                                                else
                                                {
                                                    ViewController.seriveURL = notificationData?.act2link
                                                    UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                }
                                            }
                                            else
                                            {
                                                
                                                if notificationData!.act2link == nil {
                                                    debugPrint("")
                                                }
                                                else
                                                {
                                                    handleBroserNotification(url: (notificationData?.act2link)!)
                                                }
                                            }
                                        }
                                    }
                                }
                            }else{
                                type = "0"
                                clickTrack(notificationData: notificationData!, actionType: "0", userInfo: userInfo)
                                if notificationData?.ap != "" && notificationData?.ap != nil
                                {
                                    handleClicks(response: response, actionType: "0")
                                    
                                }
                                else{
                                    if ((notificationData?.inApp?.contains("1"))! && notificationData?.inApp != "" && notificationData?.url != nil && notificationData?.url != "")
                                    {
                                        
                                        let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                        if checkWebview!
                                        {
                                            landingURLDelegate?.onHandleLandingURL(url: (notificationData?.url)!)
                                        }
                                        else
                                        {
                                            ViewController.seriveURL = notificationData?.url
                                            UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                        }
                                    }
                                    else
                                    {
                                        if notificationData!.url == nil {
                                            debugPrint("")
                                        }
                                        else
                                        {
                                            handleBroserNotification(url: (notificationData?.url)!)
                                        }
                                    }
                                }
                            }
                        }else{
                            type = "0"
                            clickTrack(notificationData: notificationData!, actionType: "0", userInfo: userInfo)
                            if notificationData?.ap != "" && notificationData?.ap != nil
                            {
                                handleClicks(response: response, actionType: "0")
                                
                            }
                            else{
                                if ((notificationData?.inApp?.contains("1"))! && notificationData?.inApp != "" && notificationData?.url != nil && notificationData?.url != "")
                                {
                                    
                                    let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                                    if checkWebview!
                                    {
                                        landingURLDelegate?.onHandleLandingURL(url: (notificationData?.url)!)
                                    }
                                    else
                                    {
                                        ViewController.seriveURL = notificationData?.url
                                        UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                    }
                                }
                                else
                                {
                                    if notificationData!.url == nil {
                                        debugPrint("")
                                    }
                                    else
                                    {
                                        handleBroserNotification(url: (notificationData?.url)!)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc static func impressionTrack(notificationData : Payload, userInfo : [AnyHashable : Any])
    {
        if(notificationData.cfg != nil || notificationData.global?.cfg != nil)
        {
            
            if(notificationData.cfg != nil)
            {
                let number = Int(notificationData.cfg ?? "0")
                let binaryString = String(number!, radix: 2)
                let firstDigit = Double(binaryString)?.getDigit(digit: 1.0) ?? 0
                let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                let seventhDigit = Double(binaryString)?.getDigit(digit: 7.0) ?? 0
                let ninthDigit = Double(binaryString)?.getDigit(digit: 9.0) ?? 0
                let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                let convertBinaryToDecimal = Int(domainURL, radix: 2)!
                if(firstDigit == 1)
                {
                    RestAPI.callImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, userInfo: userInfo)
                }
                
                if(seventhDigit == 1)
                {
                    let date = Date()
                    let format = DateFormatter()
                    format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                    let formattedDate = format.string(from: date)
                    if(ninthDigit == 1 && seventhDigit == 1)
                    {
                        if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW))
                        {
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW)
                            
                            if convertBinaryToDecimal != 0{
                                
                                let url = "https://lim"+"\(convertBinaryToDecimal)"+".izooto.com/lim"+"\(convertBinaryToDecimal)"
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo)
                            }
                            else
                            {
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONVIEWURL, userInfo: userInfo)
                            }
                        }
                    }
                    if(ninthDigit == 0 && seventhDigit == 1)
                    {
                        if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW_WEEKLY) && Date().dayOfWeek() == sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)){
                            
                            
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW_WEEKLY)
                            sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)
                            if convertBinaryToDecimal != 0{
                                
                                let url = "https://lim"+"\(convertBinaryToDecimal)"+".izooto.com/lim"+"\(convertBinaryToDecimal)"
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo)
                            }
                            else
                            {
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONVIEWURL, userInfo: userInfo)
                            }
                        }
                    }
                }
            }
            
            if(notificationData.global?.cfg != nil)
            {
                let number = Int(notificationData.global?.cfg ?? "0")
                let binaryString = String(number!, radix: 2)
                let firstDigit = Double(binaryString)?.getDigit(digit: 1.0) ?? 0
                let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                let seventhDigit = Double(binaryString)?.getDigit(digit: 7.0) ?? 0
                let ninthDigit = Double(binaryString)?.getDigit(digit: 9.0) ?? 0
                let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                let convertBinaryToDecimal = Int(domainURL, radix: 2)!
                if(firstDigit == 1)
                {
                    RestAPI.callImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, userInfo: userInfo)
                }
                
                if(seventhDigit == 1)
                {
                    let date = Date()
                    let format = DateFormatter()
                    format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                    let formattedDate = format.string(from: date)
                    if(ninthDigit == 1 && seventhDigit == 1)
                    {
                        
                        if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW))
                        {
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW)
                            
                            if convertBinaryToDecimal != 0{
                                
                                let url = "https://lim"+"\(convertBinaryToDecimal)"+".izooto.com/lim"+"\(convertBinaryToDecimal)"
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo)
                            }
                            else
                            {
                                
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONVIEWURL, userInfo: userInfo)
                            }
                        }
                    }
                    if(ninthDigit == 0 && seventhDigit == 1)
                    {
                        if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW_WEEKLY) && Date().dayOfWeek() == sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)){
                            
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_VIEW_WEEKLY)
                            sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_VIEW_WEEKDAYS)
                            if convertBinaryToDecimal != 0{
                                
                                let url = "https://lim"+"\(convertBinaryToDecimal)"+".izooto.com/lim"+"\(convertBinaryToDecimal)"
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo)
                            }
                            else
                            {
                                
                                RestAPI.lastImpression(notificationData: notificationData,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONVIEWURL, userInfo: userInfo)
                            }
                        }
                    }
                }
            }else
            {
                print(" No CFG Key defined ")
                let defaults = UserDefaults.standard
                if defaults.value(forKey: "ImpressionTrackkk") == nil{
                    defaults.setValue("true", forKey: "ImpressionTrackkk")
                    RestAPI.sendExceptionToServer(exceptionName: "No CFG Key defined \(userInfo)", className: "iZooto", methodName: "ImpressionTrack", pid: self.iZPid, token: self.iZTkn, rid: ((notificationData.rid) ?? (notificationData.global?.rid)) ?? "", cid: ((notificationData.id) ?? (notificationData.global?.id)) ?? "")
                }
            }
        }
    }
    
    @objc static func clickTrack(notificationData : Payload,actionType : String, userInfo: [AnyHashable: Any])
    {
        
        if(notificationData.cfg != nil || notificationData.global?.cfg != nil)
        {
            if(notificationData.cfg != nil){
                let number = Int(notificationData.cfg ?? "0")
                let binaryString = String(number!, radix: 2)
                let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                
                let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                let convertBinaryToDecimal = Int(domainURL, radix: 2)!
                
                if(secondDigit == 1)
                {
                    RestAPI.clickTrack(notificationData: notificationData, type: actionType,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, userInfo: userInfo )
                }
                if eighthDigit == 1
                {
                    let date = Date()
                    let format = DateFormatter()
                    format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                    let formattedDate = format.string(from: date)
                    if(tenthDigit == 1 && eighthDigit == 1){
                        let date = Date()
                        let format = DateFormatter()
                        format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                        let formattedDate = format.string(from: date)
                        if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK))
                        {
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK)
                            
                            if convertBinaryToDecimal != 0{
                                let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo )
                            }
                            else
                            {
                                
                                RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                            }
                            
                        }
                    }
                    if(tenthDigit == 0 && eighthDigit == 1)
                    {
                        if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKLY) && Date().dayOfWeek() == sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)){
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK_WEEKLY)
                            sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)
                            if convertBinaryToDecimal != 0{
                                let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo )
                            }
                            else
                            {
                                
                                RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                            }
                        }
                    }
                }
            }else if(notificationData.global?.cfg != nil ){
                
                let number = Int(notificationData.global?.cfg ?? "0")
                
                let binaryString = String(number!, radix: 2)
                let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                
                let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                
                if(secondDigit == 1)
                {
                    RestAPI.clickTrack(notificationData: notificationData, type: actionType,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, userInfo: userInfo )
                }
                if eighthDigit == 1
                {
                    let number = Int(notificationData.cfg ?? "0")
                    let binaryString = String(number!, radix: 2)
                    let secondDigit = Double(binaryString)?.getDigit(digit: 2.0) ?? 0
                    let fourthDigit = Double(binaryString)?.getDigit(digit: 4.0) ?? 0
                    let fifthDigit = Double(binaryString)?.getDigit(digit: 5.0) ?? 0
                    let sixthDigit = Double(binaryString)?.getDigit(digit: 6.0) ?? 0
                    let eighthDigit = Double(binaryString)?.getDigit(digit: 8.0) ?? 0
                    let tenthDigit = Double(binaryString)?.getDigit(digit: 10.0) ?? 0
                    
                    let domainURL =  String(sixthDigit) + String(fourthDigit) + String(fifthDigit)
                    let convertBinaryToDecimal = Int(domainURL, radix: 2)!
                    
                    if(secondDigit == 1)
                    {
                        RestAPI.clickTrack(notificationData: notificationData, type: actionType,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!, userInfo: userInfo )
                    }
                    if eighthDigit == 1
                    {
                        let date = Date()
                        let format = DateFormatter()
                        format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                        let formattedDate = format.string(from: date)
                        if(tenthDigit == 1 && eighthDigit == 1){
                            let date = Date()
                            let format = DateFormatter()
                            format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                            let formattedDate = format.string(from: date)
                            if(tenthDigit == 1 && eighthDigit == 1){
                                let date = Date()
                                let format = DateFormatter()
                                format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                                let formattedDate = format.string(from: date)
                                if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK))
                                {
                                    sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK)
                                    
                                    if convertBinaryToDecimal != 0{
                                        let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                        RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo )
                                    }
                                    else
                                    {
                                        
                                        RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                                    }
                                }
                            }
                            if(tenthDigit == 0 && eighthDigit == 1)
                            {
                                if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKLY) && Date().dayOfWeek() == sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)){
                                    sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK_WEEKLY)
                                    sharedUserDefault?.set(Date().dayOfWeek(), forKey: AppConstant.IZ_LAST_CLICK_WEEKDAYS)
                                    if convertBinaryToDecimal != 0{
                                        let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                        RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo )
                                    }
                                    else
                                    {
                                        RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                                    }
                                }
                            }
                        }
                        if(formattedDate != sharedUserDefault?.string(forKey: AppConstant.IZ_LAST_CLICK))
                        {
                            sharedUserDefault?.set(formattedDate, forKey: AppConstant.IZ_LAST_CLICK)
                            
                            if convertBinaryToDecimal != 0{
                                let url = "https://lci"+"\(convertBinaryToDecimal)"+".izooto.com/lci"+"\(convertBinaryToDecimal)"
                                print("URL",url)
                                RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: url, userInfo: userInfo )
                            }
                            else
                            {
                                RestAPI.lastClick(notificationData: notificationData, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!,url: RestAPI.LASTNOTIFICATIONCLICKURL, userInfo: userInfo )
                            }
                        }
                    }
                }
            }
            else
            {
                print(" No CFG defined")
                let defaults = UserDefaults.standard
                if defaults.value(forKey: "ClickTrackkk") == nil{
                    defaults.setValue("true", forKey: "ClickTrackkk")
                    RestAPI.sendExceptionToServer(exceptionName: "No CFG Key defined \(userInfo)", className: "iZooto", methodName: "ClickTrack", pid: self.iZPid, token: self.iZTkn, rid: ((notificationData.rid) ?? (notificationData.global?.rid)) ?? "", cid: ((notificationData.id) ?? (notificationData.global?.id)) ?? "")
                }
            }
        }
    }
    
    // Handle the InApp/Webview// and landing url listener
    @objc static func onHandleInAPP(response : UNNotificationResponse , actionType : String,launchURL : String)
    {
        let userInfo = response.notification.request.content.userInfo
        let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
        
        if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
        {
            ViewController.seriveURL = notifcationData?.url
            UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
        }
        else
        {
            onHandleLandingURL(response: response, actionType: actionType, launchURL: launchURL)
        }
    }
    
    // handle the borwser
    @objc  static func onHandleLandingURL(response : UNNotificationResponse , actionType : String,launchURL : String)
    {
        let userInfo = response.notification.request.content.userInfo
        let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
        if ((notifcationData?.inApp?.contains("0"))! && notifcationData?.inApp != "")
        {
            handleBroserNotification(url: launchURL)
        }
    }
    
    // Check the notification subscribe or not 0-> Subscribe 2- UNSubscribe
    @objc public static func setSubscription(isSubscribe : Bool)
    {
        var value = 0
        if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
            userDefaults.set(isSubscribe, forKey: "Subscribe")
        }
        UserDefaults.standard.set(isSubscribe, forKey: "Subscribe")
        if !isSubscribe
        {
            value = 2
        }
        let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
        let miZooto_id = sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)
        if token != nil && miZooto_id != 0{
            RestAPI.callSubscription(isSubscribe : value,token : token!,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!)
        }
        else{
            debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_SUBSCRIPTION_ERROR_MESSAGE)
            let defaults = UserDefaults.standard
            if defaults.value(forKey: "setSubscription") == nil{
                defaults.setValue("true", forKey: "setSubscription")
                RestAPI.sendExceptionToServer(exceptionName: "token or AppId not found", className: "iZooto", methodName: "setSubscription", pid: 0, token: "0", rid: "0", cid: "0")
            }
        }
    }
    
    
    // handle the addtional data
    @objc public static func handleClicks(response : UNNotificationResponse , actionType : String)
    {
        let userInfo = response.notification.request.content.userInfo
        let notifcationData = Payload(dictionary: (userInfo[AppConstant.iZ_NOTIFCATION_KEY_NAME] as? NSDictionary)!)
        var data = Dictionary<String,Any>()
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_ID] = notifcationData?.act1id ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_TITLE] = notifcationData?.act1name ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON1_URL] = notifcationData?.act1link ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_ADDITIONAL_DATA] = notifcationData?.ap ?? ""
        data[AppConstant.iZ_KEY_DEEP_LINK_LANDING_URL] = notifcationData?.url ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_ID] = notifcationData?.act2id ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_TITLE] = notifcationData?.act2name ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_BUTTON2_URL] = notifcationData?.act2link ?? ""
        data[AppConstant.iZ_KEY_DEEPL_LINK_ACTION_TYPE] = actionType
        notificationOpenDelegate?.onNotificationOpen(action: data)
    }
    
    
    @objc public static func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    // Add Event Functionality
    @objc  public static func addEvent(eventName : String , data : Dictionary<String,Any>)
    {
        if  eventName != ""{
            let returnData = Utils.dataValidate(data: data)
            if let theJSONData = try?  JSONSerialization.data(
                withJSONObject: returnData,
                options: .fragmentsAllowed),
               let validateData = NSString(data: theJSONData,
                                           encoding: String.Encoding.utf8.rawValue) {
                let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
                if (token != nil && !token!.isEmpty)
                {
                    RestAPI.callEvents(eventName: Utils.eventValidate(eventName: eventName), data: validateData as NSString, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: token!)
                }
                else{
                    sharedUserDefault?.set(data, forKey:AppConstant.KEY_EVENT)
                    sharedUserDefault?.set(eventName, forKey: AppConstant.KEY_EVENT_NAME)
                }
            }
        }
    }
    
    // Add User Properties
    @objc public static func addUserProperties( data : Dictionary<String,Any>)
    {
        let returnData =  Utils.dataValidate(data: data)
        if (!returnData.isEmpty)
        {
            if let theJSONData = try?  JSONSerialization.data(withJSONObject: returnData,options: .fragmentsAllowed),
               let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue) {
                let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
                if (token != nil && !token!.isEmpty)
                {
                    RestAPI.callUserProperties(data: validationData as NSString, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: token!)
                }
                else
                {
                    sharedUserDefault?.set(data, forKey:AppConstant.iZ_USERPROPERTIES_KEY)
                }
            }
        }
        else
        {
            let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)) ?? 0
            let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? "No token here"
            let defaults = UserDefaults.standard
            if defaults.value(forKey: "addUserPropertiess") == nil{
                defaults.setValue("true", forKey: "addUserPropertiess")
                RestAPI.sendExceptionToServer(exceptionName: "No data found in userProperties dictionary \(data)", className: AppConstant.IZ_TAG, methodName: AppConstant.iZ_USERPROPERTIES_KEY, pid: userID, token: token, rid: "0", cid: "0")
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
            let izUrlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let izUrl = URL(string: izUrlString!) {
                UIApplication.shared.open(izUrl)
            }
        }
    }
    
    
 /* added a new method
  This method returns the jsonString data
  method name -getNotificationFeed
  parameeter - isPagination = true -> 1,2,3,4 index  or false -> 0 index called
  completion  -> return String data
  */
    @objc public static func getNotificationFeed(isPagination: Bool,completion: @escaping (String?, Error?) -> Void){
            if let userID = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.registerID)), let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)){
                debugPrint(token)
                RestAPI.fetchDataFromAPI(isPagination: isPagination,iZPID: userID) { (jsonString, error) in
                    if let error = error {
                        debugPrint(error)
                        completion(AppConstant.IZ_NO_MORE_DATA, nil)
                    } else if let jsonString = jsonString {
                        completion(jsonString, nil)
                    }
                }
            }else{
                completion(AppConstant.IZ_INITIALISE_ERROR_MESSAGE, nil)
            }
        }
}

// Handle banner imange uploading and deleting
@available(iOS 11.0, *)
@available(iOSApplicationExtension 11.0, *)
extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
            
            
        } catch let error {
            let userID = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)) ?? 0
            let token = (sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)) ?? ""
            let defaults = UserDefaults.standard
            if defaults.value(forKey: "saveImageToDisk") == nil{
                defaults.setValue("true", forKey: "saveImageToDisk")
                RestAPI.sendExceptionToServer(exceptionName: error.localizedDescription, className: AppConstant.IZ_TAG, methodName: "saveImageToDisk", pid: userID, token: token, rid: "0", cid: "0")
            }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(string: key), value)})
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
