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






let sharedUserDefault = UserDefaults(suiteName: SharedUserDefault.suitName)

public class iZooto
{
    static var  appDelegate = UIApplication.shared.delegate!
    public  static var mizooto_id = Int()
    public static var rid : String!
    public static var cid : String!
    public static var tokenData : String!
    public let application : UIApplication
    @available(iOS 10.0, *)
    public static var firstAction : UNNotificationAction!
    @available(iOS 10.0, *)
    public static var secondAction : UNNotificationAction!
    @available(iOS 10.0, *)
    public static var category : UNNotificationCategory!
    public static var type : String!
    public static var delegate : iZootoNotificationActionDelegate?
    public static var actionType : String!
    public static var updateURL : String!
    public static let checkData = 1 as Int
    public static var badgeCount = 0
    private static var isAnalytics = false as Bool
    private static var isNativeWebview = false as Bool



    
    public init(application : UIApplication)
    {
        self.application = application
    }

    public static func initialisation(izooto_id : Int, application : UIApplication,provisioanlCheck : Bool)
         {
               mizooto_id = izooto_id
         if(provisioanlCheck){
            registerForPushNotificationsProvisional()
            }
            else
            {
               registerForPushNotifications()
            }
            
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
            }
        }
              public  static  func registerForPushNotifications() {
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
    
    
    private static func   registerForPushNotificationsProvisional()
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

    
    
    


      private static func getNotificationSettings() {
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
   
                        guard settings.authorizationStatus == .authorized else { return }
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                }
            }
            }
       private static func getNotificationSettingsProvisional() {
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
    public  static  func  getToken(deviceToken : Data)
        {
            let tokenParts = deviceToken.map { data -> String in
                         return String(format: "%02.2hhx", data)
                     }
            let token = tokenParts.joined()

            if UserDefaults.getRegistered()
            {

                guard let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
                else
                {return}
                print(AppConstant.DEVICE_TOKEN," \(token)")
                
                

            }
            else
            {

                print(AppConstant.SUCESSFULLY)
                RestAPI.registerToken(token: token, izootoid: mizooto_id)
                sharedUserDefault?.set(token, forKey: SharedUserDefault.Key.token)
                sharedUserDefault?.set(mizooto_id, forKey: SharedUserDefault.Key.registerID)

                   


            }
        }
    public static func iSPermissionAnalytics(isCheck : Bool)
    {
        isAnalytics = isCheck
    }
     
    @available(iOS 10.0, *)
    public static func didReceiveNotificationExtensionRequest(request : UNNotificationRequest, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
        {
                    
            let userInfo = request.content.userInfo
            let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
            delegate?.onNotificationReceived(payload: notifcationData!)
            bestAttemptContent.sound = UNNotificationSound.default()

            if let userDefaults = UserDefaults(suiteName: "group.com.iZooto-iOS-SDK") {

                let badgeCount = userDefaults.integer(forKey: AppConstant.BADGE)
                if badgeCount > 0 {
                    userDefaults.set(badgeCount + 1, forKey: AppConstant.BADGE)
                    bestAttemptContent.badge = badgeCount + 1 as NSNumber
                } else {

                    userDefaults.set(1, forKey: AppConstant.BADGE)
                    bestAttemptContent.badge = 1

                }
                
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
                         print(name!)
                        let firstAction = UNNotificationAction( identifier: AppConstant.FIREST_BUTTON, title: " \(name!)", options: .foreground)
                        let  category = UNNotificationCategory( identifier: AppConstant.CATEGORY_NAME, actions: [firstAction], intentIdentifiers: [], options: [])
                        UNUserNotificationCenter.current().setNotificationCategories([category])
                    }
               
                    contentHandler!(bestAttemptContent)

                
                }

           }
            }
            let state = UIApplication.shared.applicationState
            if state == .active {
              
                
            }
            
           
        }
    // for json aaray
    
    
    public static func getParseArrayValue(jsonData :[[String : Any]], sourceString : String) -> String
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
    
    
    public static func checkNotificationEnable()
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
    public static func getParseValue(jsonData :[String : Any], sourceString : String) -> String
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
                
                if count == 3 {
                                   if array.first != nil {
                                    let value = String(array[1])
                                  let data =  value.description.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                                    print(data)
                                   if let content = jsonData["\(array[0])"] as? [[String:Any]] {
                                   for responseData in content {
                                       return responseData["\(array[2])"]! as! String
                                       
                               }
                           }
                                       
                           }
                             }
                
                
                
                
                // count 3
               
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
                    else
                    {
                        print("No Result Found")
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
                                   else
                                   {
                                       return "Error"
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
                                        print("Response",response)

                                                                     return response as! String

                                                                    }
                                                                    else
                                                                    {
                                                                        return "Error"
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
    

   private static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    public static func handleForeGroundNotification(notification : UNNotification,displayNotification : String)
    {
        let appstate = UIApplication.shared.applicationState
        print(displayNotification,appstate)

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
               
    }


    
   
    public static func handleNotifcation(response : UNNotificationResponse)
             {
              


                 let userInfo = response.notification.request.content.userInfo
                 let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                                delegate?.onNotificationReceived(payload: notifcationData!)
                       if let userDefaults = UserDefaults(suiteName: "group.com.iZooto-iOS-SDK") {
                        userDefaults.set(0, forKey: AppConstant.BADGE)
                }
                UIApplication.shared.applicationIconBadgeNumber = 0

                
//                let num = notifcationData?.cfg! as! Int
//                let str = String(num, radix: 2)
//                print(str) // prints "10110"
//                let last = str.suffix(1)
//                print(last) // prints "10110"
//                let myInt1 = Int(last)
//


                
//
//                if checkData == myInt1
//                {
//                    print("Yes call")
                RestAPI.callImpression(notificationData: notifcationData!,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
//                }
//                else{
//                    print("No call")
//                }
                
////////
//                if isAnalytics{
//                    iZootoAnalytics.trackNotificationOpened(payload: notifcationData!)
//                    iZootoAnalytics.trackNotificationinfluence(payload: notifcationData!)
//                }

                
                 if notifcationData?.fetchurl != nil && notifcationData?.fetchurl != ""
                                          {
                                            
                                            RestAPI.clickTrack(notificationData: notifcationData!, type: "0",userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
                                             RestAPI.clickTrack(notificationData: notifcationData!, type: "0",userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
                                            
                                            
                                            
                                            if let url = URL(string: notifcationData!.fetchurl!) {
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
                                                     
                                                    
                                                                
                                                        } else if let jsonDictionary = json as? [String:Any] {
                                                            

                                                         
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
                                                                                                                              
                                                                    }        }                                                            }
                                                            
                                                        } else {
                                                           print("This should never be displayed")
                                                        }
                                               
                                                } catch let error {
                                                    print("Error",error)

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
                                              RestAPI.clickTrack(notificationData: notifcationData!, type: type,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
                                              if notifcationData?.ap != "" && notifcationData?.ap != nil
                                                             {
                                                     handleClicks(response: response, actionType: "1")
                                                         }
                                              else
                                              {
                                               
                                                
                                                
                                                if notifcationData?.act1link != nil && notifcationData?.act1link != "" {
                                                let launchURl = notifcationData?.act1link!

                                                if launchURl!.contains("tel:"){
                                                if let url = URL(string: launchURl!) {
                                                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                                }
                                                                                               
                                            }
                                                else
                                                {
                                              
                                                  //onHandleInAPP(response: response, actionType: type, launchURL: launchURl!)
                                                    if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
                                              {
                                                    ViewController.seriveURL =  notifcationData?.act1link
                                                                                        UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
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
                                                else
                                                {
                                                    print("No URl Founds..")
                                                }
                                              }
                                              //completion(.dismissAndForwardAction)

                                             
                                          break
                                         case "SecondButton" :
                                          
                                          type = "2"
                                          RestAPI.clickTrack(notificationData: notifcationData!, type: type,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )

                                          if notifcationData?.ap != "" && notifcationData?.ap != nil
                                          {

                                          handleClicks(response: response, actionType: "2")
                                                                    
                                                                    
                                          }
                                          else
                                          {
                                      
                                            if notifcationData?.act2link != nil && notifcationData?.act2link != "" {
                                              let launchURl = notifcationData?.act2link!
                                            if launchURl!.contains("tel:"){
                                                if let url = URL(string: launchURl!) {
                                                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                            }
                                                
                                            }
                                              else
                                              {
                                                 // onHandleInAPP(response: response, actionType: type, launchURL: notifcationData!.act2link!)
                                                
                                                if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
                                                     {
                                                                                                    ViewController.seriveURL = notifcationData?.act2link
                                                                                                                            UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                        }
                                                    else
                                                            {
                                                            if let url = URL(string: notifcationData!.act2link!) {
                                                
                                                                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                                
                                                
                                                                                                                        }
                                                
                                                                                  
                                                                                     }
                                              }
                                          }
                                            else
                                            {
                                                print("No URl Founds..")

                                            }
                                            
                                          }
                                           break
                                     default:
                                      type = "0"
                                       RestAPI.clickTrack(notificationData: notifcationData!, type: type,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
                                      if notifcationData?.ap != "" && notifcationData?.ap != nil
                                                            {
                                                            handleClicks(response: response, actionType: "0")

                                                            }
                                                            else
                                                            {
                                                                
                                                                 if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
                                                                        {
                                                                            ViewController.seriveURL = notifcationData?.url
                                                                            UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                                                        }
                                                                        else
                                                                        {
                                                                            
                                                                            

                                                                            if let url = URL(string: notifcationData!.url!) {


                                                                                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)


                                                                        }

                                  
                                     }
                                      }
                                    }

                                  }
                                  else{
                        
                        
                        
                        
                                      type = "0"
                        
                                    RestAPI.clickTrack(notificationData: notifcationData!, type: type,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
                        
                        
                        
                                 if notifcationData?.ap != "" && notifcationData?.ap != nil
                                      {
                                                                                                         
                                      handleClicks(response: response, actionType: "0")
                                                                                                         
                                                                                                         
                                      }
                                      else
                                      {
                                                                                                    
                                        if ((notifcationData?.inApp?.contains("1"))! && notifcationData?.inApp != "")
                                       {
                                        ViewController.seriveURL = notifcationData?.url
                                        UIApplication.shared.keyWindow!.rootViewController?.present(ViewController(), animated: true, completion: nil)
                                    }
                                    else
                                        {
                                        if let url = URL(string: notifcationData!.url!) {
                                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]) as [String : Any], completionHandler: nil)
                                    }
                                                                                
                                                                      
                                    }
                                    
                                      }
                                     

                                  
                                  }
             
                           
                }

                

                
              ///////////////////////

              

               
              
                
        }
    
  public static  func identifierForAdvertising() -> String? {
        // check if advertising tracking is enabled in user’s setting
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return "Not Found"
        }
    }
    private static func onHandleInAPP(response : UNNotificationResponse , actionType : String,launchURL : String)
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
        
       RestAPI.clickTrack(notificationData: notifcationData!, type: type,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
        
    }
    private static func onHandleLandingURL(response : UNNotificationResponse , actionType : String,launchURL : String)
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
    
    public static func setSubscription(isSubscribe : Bool)
    {
        var value = 0
        if isSubscribe
        {
            value = 2
           // print("Value",value)

        }
    
         let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)
        if token != nil && mizooto_id != 0{
        RestAPI.callSubscription(isSubscribe : value,token : token!,userid: mizooto_id)
        }
        else{
            print("No SubscriptionCall")
        }
       
    }
    
    // handle the addtional data
    private static func handleClicks(response : UNNotificationResponse , actionType : String)
        {
                       
            
            let userInfo = response.notification.request.content.userInfo
                         let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                               var data = [String : String]()
                              data["button1ID"] = notifcationData?.act1id
                               data["button1Title"] = notifcationData?.act1name
                               data["button1URL"] = notifcationData?.act1link
                               data["additionalData"] = notifcationData?.ap
                               data["landingURL"] = notifcationData?.url
                               data["button2ID"] = notifcationData?.act2id
                               data["button2Title"] = notifcationData?.act2name
                               data["button2URL"] = notifcationData?.act2link
                               data["actionType"] = actionType
                               delegate?.onOpenActionHandler( action : String(describing:data))
        }
    

      public static func getQueryStringParameter(url: String, param: String) -> String? {
         guard let url = URLComponents(string: url) else { return nil }
         return url.queryItems?.first(where: { $0.name == param })?.value
       }

    public static func addEvent(eventName : String , data : Dictionary<String,Any>)
    {
       let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)

        if  eventName != ""{
            let returnData = Utils.dataValidate(data: data)
            if let theJSONData = try?  JSONSerialization.data(
            withJSONObject: returnData,
            options: .fragmentsAllowed),
            let validateData = NSString(data: theJSONData,
                                       encoding: String.Encoding.ascii.rawValue) {
            
           RestAPI.callEvents(eventName: Utils.eventValidate(eventName: eventName), data: validateData as NSString, userid: mizooto_id, token: token!)

          }
        }
        else
        {
            print("No","Data Not Found")
        }
    }
   
        public static func addUserProperties( data : Dictionary<String,Any>)
           {
              
                let returnData = Utils.dataValidate(data: data)
            if returnData != nil {
                 if let theJSONData = try?  JSONSerialization.data(
                   withJSONObject: returnData,
                   options: .fragmentsAllowed
                   ),
                   let validationData = NSString(data: theJSONData,
                                              encoding: String.Encoding.ascii.rawValue) {
                   let token = sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)

                    RestAPI.callUserProperties(data: validationData as NSString, userid: mizooto_id, token: token!)
                }

                 }
            else
            {
                print("iZooto"," Not Added in Properties")
            }
               
          
        
        }

        
        
      

    private static func callURL(dataURL : String)->String{
        return "data"
    }


    }
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
public protocol iZootoNotificationActionDelegate
{
    func onNotificationReceived(payload :Payload )
    func onOpenActionHandler(action : String)
}

    


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(string: key), value)})
}
