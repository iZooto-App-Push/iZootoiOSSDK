//
//  iZooto.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import Darwin
import AdSupport
import AVFoundation
import CommonCrypto
import WebKit

let sharedUserDefault = UserDefaults(suiteName: SharedUserDefault.suitName)
@objc
public class iZooto : NSObject
{
    static var  appDelegate = UIApplication.shared.delegate!
    private  static var mizooto_id = Int()
    private static var rid : String!
    private static var cid : String!
    private static var tokenData : String!
    private let application : UIApplication
    @available(iOS 10.0, *)
    private static var firstAction : UNNotificationAction!
    @available(iOS 10.0, *)
    private static var secondAction : UNNotificationAction!
    @available(iOS 10.0, *)
    private static var category : UNNotificationCategory!
    private static var type : String!
  //  public static var iZootoActionDelegate : iZootoNotificationActionDelegate?
    private static var actionType : String!
    private static var updateURL : String!
    private static let checkData = 1 as Int
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
   @objc  public static var landingURLDelegate : iZootoLandingURLDelegate?
    private static var keySettingDetails = Dictionary<String,Any>()
  @objc  public static var notificationReceivedDelegate : iZootoNotificationReceiveDelegate?
  @objc   public static var notificationOpenDelegate : iZootoNotificationOpenDelegate?
   @objc public init(application : UIApplication)
    {
        self.application = application
    }
    
// initialise the device and register the token
   @objc public static func initialisation(izooto_id : String, application : UIApplication,iZootoInitSettings : Dictionary<String,Any>)
         {
            izooto_uuid = izooto_id
            keySettingDetails = iZootoInitSettings
            RestAPI.createRequest(uuid: izooto_uuid) { (output) in
                
                let jsonString = output.fromBase64()
            let data = jsonString!.data(using: .utf8)!
                   let json = try? JSONSerialization.jsonObject(with: data)
                  if let dictionary = json as? [String: Any] {
                    
                    sharedUserDefault?.set(dictionary["pid"]!, forKey: SharedUserDefault.Key.registerID)
                    mizooto_id = (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!
                  }
                  else{
                    print("Some error occured")
                  }
                  }
        
           
        if(keySettingDetails != nil)
        {
            let nativeWebviewKey = keySettingDetails["nativeWebview"] != nil
            if nativeWebviewKey{
                sharedUserDefault?.set(keySettingDetails["nativeWebview"]!, forKey:AppConstant.ISWEBVIEW)
            } else {
                print("The nativeWebview  key is not present in the dictionary")
            }
            let provisionalKey = keySettingDetails["provisionalAuthorization"] != nil
            if(provisionalKey)
            {
                if(keySettingDetails["provisionalAuthorization"]!) as! Bool
                {
                    registerForPushNotificationsProvisional() // check for provisional
                }
                else{
                    registerForPushNotifications() // check for prompt
                  }
                
            }
            else
            {
                print("The provisional Authorization key  is not present in the dictionary")

            }
            let autoPromptkey = keySettingDetails["auto_prompt"] != nil
            if autoPromptkey{
                
                 if(keySettingDetails["auto_prompt"]!) as! Bool
                   {
                    if(keySettingDetails["provisionalAuthorization"]!) as! Bool
                    {
                        registerForPushNotificationsProvisional() // check for provisional
                    }
                    else{
                        registerForPushNotifications() // check for prompt
                      }// check for prompt
                   }
            }
          else {
                print("The auto_prompt  key is not present in the dictionary")
            }
           
        if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
            }
        }
        else{
          
                  registerForPushNotifications() // check for prompt
               
               
               if #available(iOS 10.0, *) {
                   UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
               }
            
        }
    let dicData = sharedUserDefault?.dictionary(forKey:"UserPropertiesData")
    if(dicData != nil)
    {
        addUserProperties(data: dicData!)
    }
    else
    {
       // print("No User Properties Data")
    }
            
    }
    
    
    // register for pushNotification Setting
@objc public  static  func registerForPushNotifications() {
                if #available(iOS 10.0, *) {
                    UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
                }
            if #available(iOS 10.0, *) {

                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                                           (granted, error) in
                        print(AppConstant.PERMISSION_GRANTED ,"\(granted)")
                                           guard granted else { return }
                                           getNotificationSettings()
                        
                }
                
                }

        }
    
   
    
    // provision setting
   @objc private static func   registerForPushNotificationsProvisional()
    {
        
        if #available(iOS 12.0, *) {
                           UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge,.provisional]) {
                               (granted, error) in
                                print(AppConstant.PERMISSION_GRANTED ,"\(granted)")
                                guard granted else { return }
                                getNotificationSettingsProvisional()
                            }
                        }
    }

   //  Handle notification prompt setting
  @objc  private static func getNotificationSettings() {
            if #available(iOS 10.0, *) {
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
        if #available(iOS 10.0, *) {
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
   @objc public  static  func  getToken(deviceToken : Data)
        {
    
  
            let tokenParts = deviceToken.map { data -> String in
                         return String(format: "%02.2hhx", data)
                     }
            let token = tokenParts.joined()
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)


            if UserDefaults.getRegistered()
            {
                guard let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
                else
                {return}
                print(AppConstant.DEVICE_TOKEN," \(token)")
                if(formattedDate != (sharedUserDefault?.string(forKey: "LastVisit")))
                {
                    RestAPI.lastVisit(userid: mizooto_id, token:token)
                    sharedUserDefault?.set(formattedDate, forKey: "LastVisit")
                }
               
            }
            else
            {
                RestAPI.registerToken(token: token, izootoid: mizooto_id)
                sharedUserDefault?.set(token, forKey: SharedUserDefault.Key.token)
            }
        }
    @objc public static func setBadgeCount(badgeNumber : NSInteger)
    {

        if(badgeNumber>0)
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

     // Handle the payload and show the notification
    @available(iOS 10.0, *)
   @objc public static func didReceiveNotificationExtensionRequest(bundleName : String,
                                                                    request : UNNotificationRequest, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
        {
            let userInfo = request.content.userInfo
            let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
    if(notifcationData?.inApp != nil)
    {
            notificationReceivedDelegate?.onNotificationReceived(payload: notifcationData!)
            bestAttemptContent.sound = UNNotificationSound.default()
            badgeNumber = (sharedUserDefault?.integer(forKey: "BADGECOUNT"))!
    
            if(bundleName != nil)
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
                userDefaults.synchronize()


            }
            }
        else
            {
                print("No GroupName added here")
            }
        
          
            if notifcationData?.fetchurl != nil && notifcationData?.fetchurl != ""
                          {
                              if let url = URL(string: notifcationData!.fetchurl!) {
                                 URLSession.shared.dataTask(with: url) { data, response, error in
                                    if let data = data {
                                do {
                                    
                                    
                                    
                                     let json = try JSONSerialization.jsonObject(with: data)
                                        if let jsonArray = json as? [[String:Any]] {
                                            bestAttemptContent.title = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notifcationData?.alert!.title)!))"
                                            bestAttemptContent.body = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notifcationData?.alert!.body)!))"
                                        if notifcationData?.url != "" {
                                            notifcationData?.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notifcationData?.url)!))"
                                          
                                            }
                                        if notifcationData?.alert?.attachment_url != "" {
                                          notifcationData?.alert?.attachment_url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notifcationData?.alert!.attachment_url)!))"
                                            if (notifcationData?.alert?.attachment_url!.contains(".webp"))!
                                            {
                                                notifcationData?.alert?.attachment_url = notifcationData?.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpg")
                                            }
                                            
                                    }
                                                
                                        } else if let jsonDictionary = json as? [String:Any] {
                                            // print("Hello",jsonDictionary)

                                            bestAttemptContent.title = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notifcationData?.alert!.title)!))"
                                            bestAttemptContent.body = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notifcationData?.alert!.body)!))"
                                            if notifcationData?.url != "" {
                                             notifcationData?.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notifcationData?.url)!))"
                                            }
                                            if notifcationData?.alert?.attachment_url != "" {
                                                
                                                
                                            notifcationData?.alert?.attachment_url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notifcationData?.alert!.attachment_url)!))"
                                                if (notifcationData?.alert?.attachment_url!.contains(".webp"))!
                                              {
                                                  notifcationData?.alert?.attachment_url = notifcationData?.alert?.attachment_url?.replacingOccurrences(of: ".webp", with: ".jpeg")
                                               
                                              }
                                              if (notifcationData?.alert?.attachment_url!.contains("http:"))!
                                                                                          {
                                                                                              notifcationData?.alert?.attachment_url = notifcationData?.alert?.attachment_url?.replacingOccurrences(of: "http:", with: "https:")
                                                                                           
                                                                                          }
                                                                                          
                                               
                                               
                                                
                                            }
                                        }
                                       
                                      autoreleasepool {
                                        if let urlString = (notifcationData?.alert?.attachment_url),
                                                       let fileUrl = URL(string: urlString ) {

                                                              guard let imageData = NSData(contentsOf: fileUrl) else {
                                                                contentHandler!(bestAttemptContent)
                                                                 return
                                                               }
                                                              let string = notifcationData?.alert?.attachment_url
                                                              let url: URL? = URL(string: string!)
                                                              let urlExtension: String? = url?.pathExtension
                                                                guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                                                                    print(AppConstant.IMAGE_ERROR)
                                                                  contentHandler!(bestAttemptContent)
                                                                  return
                                                                }
                                                                bestAttemptContent.attachments = [ attachment ]
                                                              }


                                                 }
                                                     
                                        contentHandler!(bestAttemptContent)


                                    


                                } catch let error {
                                    print("Error",error)

                                }
                                                                      }
                                    
                                 }.resume()
                              }
                             
                            let firstAction = UNNotificationAction( identifier: "FirstButton", title: "Sponsored", options: .foreground)
                                                  let  category = UNNotificationCategory( identifier: "izooto_category", actions: [firstAction], intentIdentifiers: [], options: [])
                                                   UNUserNotificationCenter.current().setNotificationCategories([category])
                             

                          }

                
            else{
            if notifcationData != nil
            {
                

            autoreleasepool {
                if let urlString = (notifcationData?.alert?.attachment_url),
                let fileUrl = URL(string: urlString ) {
                       guard let imageData = NSData(contentsOf: fileUrl) else {
                            contentHandler!(bestAttemptContent)
                          return
                        }
                       let string = notifcationData?.alert?.attachment_url
                       let url: URL? = URL(string: string!)
                       let urlExtension: String? = url?.pathExtension

                         guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                           print(AppConstant.IMAGE_ERROR)
                           contentHandler!(bestAttemptContent)
                           return
                         }
                         bestAttemptContent.attachments = [ attachment ]
                       }
            }
                
                
                  

                if notifcationData!.category != "" && notifcationData!.category != nil
                {
                     if notifcationData?.act1name != "" && notifcationData?.act1name != nil && notifcationData?.act2name != nil && notifcationData?.act2name != ""
                    {
                        let name = notifcationData?.act1name!
                        let secondName = notifcationData?.act2name!
                      

                        let   firstAction = UNNotificationAction( identifier: AppConstant.FIREST_BUTTON, title: " \(name!)", options:.foreground)
                        let   secondAction = UNNotificationAction( identifier: AppConstant.SECOND_BUTTON, title: "\(secondName!)",options: .foreground)
                        
                        let  category = UNNotificationCategory( identifier:AppConstant.CATEGORY_NAME, actions: [firstAction,secondAction], intentIdentifiers: [], options: [])
                     
                        UNUserNotificationCenter.current().setNotificationCategories([category])


                    }
                    else
                    {
                       
                        let name = notifcationData?.act1name!
                        let firstAction = UNNotificationAction( identifier: AppConstant.FIREST_BUTTON, title: " \(name!)", options: .foreground)
                        let  category = UNNotificationCategory( identifier: AppConstant.CATEGORY_NAME, actions: [firstAction], intentIdentifiers: [], options: [])
                        UNUserNotificationCenter.current().setNotificationCategories([category])
                    }
               
                    contentHandler!(bestAttemptContent)

                
                }

           }
            }
    }
    else
    {
        print("Other Notification providers")
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
    
    // Check the notification enable or not from device setting
  @objc  public static func checkNotificationEnable()
    {
        let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
                if isNotificationEnabled!{
                        print("enabled notification setting")
                           }else{

                    let alert = UIAlertController(title: "Please enable notifications for \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "APP Name")", message: "To receive these updates,you must first allow to receive \(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "APP Name") notification from settings", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: " Not Now", style: UIAlertAction.Style.default, handler: nil))
                    alert.addAction(UIAlertAction(title: "Take me there", style: .default, handler: { (action: UIAlertAction!) in
                        
                        
                         DispatchQueue.main.async {
                            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                    return
                                }

                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    if #available(iOS 10.0, *) {
                                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                            print("Settings opened: \(success)") // Prints true
                                        })
                                    } else {
                                        UIApplication.shared.openURL(settingsUrl as URL)
                                    }
                                }
                            }
                        }))
                        
                   
                   
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)

                    
      
                    
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
}
}
if (count == 4){
let array = sourceString.split(separator: ".")
let response = jsonData["\(array[0])"] as! [String:Any]
let documents = response["\(array[1])"] as! [String:Any]
//  let field = documents["\(array[2])"] as! [[String:Any]]
let field = documents["doc"] as! [[String:Any]]
if !field.isEmpty{
let name = field[0]["\(array[3])"]!
    return name as! String
}
}
if (count == 5){
if sourceString.contains("list"){
let array = sourceString.split(separator: ".")
let response = jsonData["\(array[0])"] as! [[String:Any]]
let documents = response[0]
let field = documents["\(array[2])"] as! [[String:Any]]
if(field.count>0)
{
// let responseData = field[0]["\(array[3])"]as! [String:Any]
    let response  = field[0]["\(array[4])"]!
    return response as! String
    
}
}
else{
let array = sourceString.split(separator: ".")
let response = jsonData["\(array[0])"] as! [String:Any]
let documents = response["\(array[1])"] as! [String:Any]
let field = documents["\("doc")"] as! [[String:Any]]
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
print(sourceString)
    
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
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    // Handle the Notification behaviour
    @objc  public static func handleForeGroundNotification(notification : UNNotification,displayNotification : String,completionHandler : @escaping (UNNotificationPresentationOptions) -> Void)
      {
        let appstate = UIApplication.shared.applicationState
        if (appstate == .active && displayNotification == "InAppAlert")
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
                  UIApplication.shared.openURL(NSURL(string: notificationData!.act2link!)! as URL)
                  }))
              }
              alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
              UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
              }
      else
        {
            let userInfo = notification.request.content.userInfo
          let notificationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
            if(notificationData?.inApp != nil)
            {
            
          notificationReceivedDelegate?.onNotificationReceived(payload: notificationData!)
          if (notificationData?.cfg != nil)
          {
              let str = String((notificationData?.cfg)!)
              let binaryString = (str.data(using: .utf8, allowLossyConversion: false)?.reduce("") { (a, b) -> String in a + String(b, radix: 2) })
              let lastChar = binaryString?.last!
              let str1 = String((lastChar)!)
              let impr = Int(str1)
              if(impr == 1)
              {
                  RestAPI.callImpression(notificationData: notificationData!,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)!)
              }
              }
                completionHandler([.badge, .alert, .sound])

        }
            else
            {
                print("other notification provider")
            
            }
        }
        
    
          }
// Handle the clicks the notification from Banner,Button
@objc public static func notificationHandler(response : UNNotificationResponse)
{
    
    let userInfo = response.notification.request.content.userInfo
    let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
   
    UIApplication.shared.applicationIconBadgeNumber = 0 // clear the badge count
    if let userDefaults = UserDefaults(suiteName: Utils.getBundleName()) {
        userDefaults.set(0, forKey: "Badge")
        userDefaults.synchronize()
   }

   // iZootoActionDelegate?.onNotificationReceived(payload: notifcationData!)
    notificationReceivedDelegate?.onNotificationReceived(payload: notifcationData!)

    
    clickTrack(notificationData: notifcationData!, actionType: "0")

                
if notifcationData?.fetchurl != nil && notifcationData?.fetchurl != ""
  {
   // clickTrack(notificationData: notifcationData!, actionType: "0")

    if let url = URL(string: notifcationData!.fetchurl!)
         {
        URLSession.shared.dataTask(with: url) { data, response, error in
        if let data = data {
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            if let jsonArray = json as? [[String:Any]] {
            if notifcationData?.url != "" {
             notifcationData?.url = "\(getParseArrayValue(jsonData: jsonArray, sourceString: (notifcationData?.url)!))"
              notifcationData?.url = "https:"+notifcationData!.url!
            if notifcationData?.act1name != nil && notifcationData?.act1name != ""
                {
            if let url = URL(string:notifcationData!.url!) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
}
    }
else
    {
      if let url = URL(string:notifcationData!.url!) {
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
        }
    }
  }
}
else if let jsonDictionary = json as? [String:Any] {
    if notifcationData?.url != "" {
    notifcationData?.url = "\(getParseValue(jsonData: jsonDictionary, sourceString: (notifcationData?.url)!))"
    if let url = URL(string:notifcationData!.url!) {
    if notifcationData?.act1name != nil && notifcationData?.act1name != ""
     {
       if let url = URL(string:notifcationData!.url!) {
           UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
            }
    }
else
{
   UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
}
        
}
}
}
} catch let error {
    print(AppConstant.TAG,error)
}
}
}.resume()
}
}
else
    {
    if notifcationData?.category != nil
     {

        switch response.actionIdentifier
         {
              case "FirstButton" :
               type = "1"
               // clickTrack(notificationData: notifcationData!, actionType: "1")

            if notifcationData?.ap != "" && notifcationData?.ap != nil
                {
                    handleClicks(response: response, actionType: "1")
                }
            else
            {
             if notifcationData?.act1link != nil && notifcationData?.act1link != ""
                {
                 let launchURl = notifcationData?.act1link!
                 if launchURl!.contains("tel:")
                    {
                     if let url = URL(string: launchURl!)
                      {
                        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                        }
                                                                                               
                    }
                 else
                    {
                    if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
                    {
                      
                        let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                        if checkWebview!
                        {
                        landingURLDelegate?.onHandleLandingURL(url: (notifcationData?.act1link)!)
                        }
                        else
                        {
                            ViewController.seriveURL = notifcationData?.act1link
                        UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                        }
                     
                        
                    }
                  else
                   {
                    if(notifcationData?.fetchurl != "" && notifcationData?.fetchurl != nil)
                        {
                            if let url = URL(string: notifcationData!.url!) {
                             UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                }
                        }
                    else
                        {
                        if let url = URL(string: notifcationData!.act1link!) {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                    }
                                }
                        }
                        }
                    }
                   
                    }
break
case "SecondButton" :
                type = "2"
   // clickTrack(notificationData: notifcationData!, actionType: "2")

            if notifcationData?.ap != "" && notifcationData?.ap != nil
             {
                    handleClicks(response: response, actionType: "2")
             }
            else
            {
                if notifcationData?.act2link != nil && notifcationData?.act2link != ""
                 {
                    let launchURl = notifcationData?.act2link!
                if launchURl!.contains("tel:")
                 {
                  if let url = URL(string: launchURl!)
                  {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                    }
                   }
                else
                 {
                    if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
                    {
                      
                        let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
                        if checkWebview!
                        {
                        landingURLDelegate?.onHandleLandingURL(url: (notifcationData?.act2link)!)
                        }
                        else
                        {
                            ViewController.seriveURL = notifcationData?.act2link
                        UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                        }
                     
                    }
                else
                 {
                    if let url = URL(string: notifcationData!.act2link!)
                     {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                     }
                 }
                }
            }
        }
break
default:
            type = "0"
    if notifcationData?.ap != "" && notifcationData?.ap != nil
    {
     handleClicks(response: response, actionType: "0")
    }
else{
    if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
     {
       
        let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
        if checkWebview!
        {
        landingURLDelegate?.onHandleLandingURL(url: (notifcationData?.url)!)
        }
        else
        {
        ViewController.seriveURL = notifcationData?.url
        UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
        }
     }
     else{
       // clickTrack(notificationData: notifcationData!, actionType: "0")

        if let url = URL(string: notifcationData!.url!) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
             }

                                  
          }
    }
 }

}
else{
     type = "0"
   // clickTrack(notificationData: notifcationData!, actionType: "0")

          if notifcationData?.ap != "" && notifcationData?.ap != nil
            {
                handleClicks(response: response, actionType: "0")
                                                                                                         
            }
        else
        {
         if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
            {
           
            let checkWebview = (sharedUserDefault?.bool(forKey: AppConstant.ISWEBVIEW))
            if checkWebview!
            {
            landingURLDelegate?.onHandleLandingURL(url: (notifcationData?.url)!)
            }
            else
            {
            ViewController.seriveURL = notifcationData?.url
            UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
            }
            }
            else
            {
                if let url = URL(string: notifcationData!.url!) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                    }
            }
                                    
        }
    } //close else
            }
   
}
    
    @objc private static func clickTrack(notificationData : Payload,actionType : String)
    {
        if(notificationData.cfg != nil)
        {
            let str = String((notificationData.cfg)!)
            let binaryString = (str.data(using: .utf8, allowLossyConversion: false)?.reduce("") { (a, b) -> String in a + String(b, radix: 2) })
        let data = binaryString!.suffix(2)
            let clickCFG = data.prefix(1)
            let click = Int(clickCFG)

            if(click == 1)
            {
                RestAPI.clickTrack(notificationData: notificationData, type: actionType,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
            }
        }
        else
        {

            RestAPI.clickTrack(notificationData: notificationData, type: actionType,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
        }
    }
    
        
    

    
    // Handle the InApp/Webview
  @objc  private static func onHandleInAPP(response : UNNotificationResponse , actionType : String,launchURL : String)
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
   @objc private static func onHandleLandingURL(response : UNNotificationResponse , actionType : String,launchURL : String)
       {
           let userInfo = response.notification.request.content.userInfo
            let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
          if ((notifcationData?.inApp?.contains("0"))! && notifcationData?.inApp != "")
           {
               if let url = URL(string: launchURL) {
                if #available(iOS 10.0, *) {
                    
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                }
                                                            
            }
           }

           
       }
    // Check the notification subscribe or not 0-> Subscribe 2- UNSubscribe
   @objc public static func setSubscription(isSubscribe : Bool)
    {
        var value = 0
        if isSubscribe
        {
            value = 2
        }
    
         let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
         let miZooto_id = sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID)
        if token != nil && miZooto_id != 0{
        RestAPI.callSubscription(isSubscribe : value,token : token!,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!)
        }
        else{
            print("No SubscriptionCall")
        }
       
    }
    
    // handle the addtional data
   @objc private static func handleClicks(response : UNNotificationResponse , actionType : String)
        {
            let userInfo = response.notification.request.content.userInfo
            let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
            var data = Dictionary<String,Any>()
                data["button1ID"] = notifcationData?.act1id
                data["button1Title"] = notifcationData?.act1name
                data["button1URL"] = notifcationData?.act1link
                data["additionalData"] = notifcationData?.ap
                data["landingURL"] = notifcationData?.url
                data["button2ID"] = notifcationData?.act2id
                data["button2Title"] = notifcationData?.act2name
                data["button2URL"] = notifcationData?.act2link
                data["actionType"] = actionType
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
               
          }
        }
       
    }
   
   
    // Add User Properties
@objc public static func addUserProperties( data : Dictionary<String,Any>)
{
    
  let returnData =  Utils.dataValidate(data: data)
  if returnData != nil {
  if let theJSONData = try?  JSONSerialization.data(withJSONObject: returnData,options: .fragmentsAllowed),
     let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue) {
     let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
    if (token != nil && !token!.isEmpty)
    {
     RestAPI.callUserProperties(data: validationData as NSString, userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!, token: token!)
                
    }
    else
    {
        sharedUserDefault?.set(data, forKey:"UserPropertiesData")
       

    }
  }
    }
        
        }
   
}

// Handle banner imange uploading and deleting
@available(iOS 10.0, *)
@available(iOSApplicationExtension 10.0, *)
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
                print("error \(error)")
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
}
