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

    
    public init(application : UIApplication)
    {
        self.application = application
    }

    public static func initialisation(izooto_id : Int, application : UIApplication)
         {
               mizooto_id = izooto_id
               registerForPushNotifications()
            
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
            } else {
                
            }
        }
              public  static  func registerForPushNotifications() {
                
                if #available(iOS 10.0, *) {
                    UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
                } else {
                    // Fallback on earlier versions
                }
            if #available(iOS 10.0, *) {
              UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                  (granted, error) in
                  print("Permission granted: \(granted)")
                guard granted else { return }
                getNotificationSettings()
          }
                }
        }
        @available(iOS 10.0, *)
           func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
                   iZooto.getToken(deviceToken: deviceToken)

                 }

       public static func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            }
        } else {
            // Fallback on earlier versions
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
                print("Token \(token)")
                
                

            }
            else
            {

                UserDefaults.isRegistered(isRegister: true)
                print("InstallationSuccessfully")
                RestAPI.registerToken(token: token, izootoid: mizooto_id)
                sharedUserDefault?.set(token, forKey: SharedUserDefault.Key.token)
                sharedUserDefault?.set(mizooto_id, forKey: SharedUserDefault.Key.registerID)

                   


            }
        }
     
    @available(iOS 10.0, *)
    @available(iOS 10.0, *)
    public static func didReceiveNotificationExtensionRequest(request : UNNotificationRequest, bestAttemptContent :UNMutableNotificationContent,contentHandler:((UNNotificationContent) -> Void)?)
        {
            
            let userInfo = request.content.userInfo
            print("UserInfo\(userInfo)")
            let notifcationData = Aps(dictionary: (userInfo["aps"] as? NSDictionary)!)
          //  RestAPI.callImpression(notificationData: notifcationData!,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )
            delegate?.onNotificationReceived(payload: notifcationData!)

                
                                        
            if notifcationData != nil
            {
                
                if let urlString = (notifcationData?.alert?.attachment_url),let fileUrl = URL(string: urlString ) {
                      guard let imageData = NSData(contentsOf: fileUrl) else {
                        contentHandler!(bestAttemptContent)
                          return
                      }
                    let string = notifcationData?.alert?.attachment_url

                    let url: URL? = URL(string: string!)
                    let urlExtension: String? = url?.pathExtension
                        guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "img."+urlExtension!, data: imageData, options: nil) else {
                            print("error in UNNotificationAttachment.saveImageToDisk()")
                            contentHandler!(bestAttemptContent)
                            return
                        }
                        bestAttemptContent.attachments = [ attachment ]

                    
                    }
                if notifcationData!.category != ""
                {
                    if notifcationData?.act1name != ""
                    {
                        let name = notifcationData?.act1name!

                            firstAction = UNNotificationAction( identifier: "FirstButton", title:  name!, options: [.foreground])
                        
                        
                      
                    }
                    if notifcationData?.act2name != ""
                    {
                         secondAction = UNNotificationAction( identifier: "SecondButton", title:   (notifcationData?.act2name!)!, options: [.foreground])
                       
                    }
                    if notifcationData?.act1name != ""
                    {
                        if secondAction != nil {
                                category = UNNotificationCategory( identifier: (notifcationData?.category!)!, actions: [firstAction,secondAction], intentIdentifiers: [], options: [])
                            
                                UNUserNotificationCenter.current().setNotificationCategories([category])
                            
                        }
                        else{
                            category = UNNotificationCategory( identifier: (notifcationData?.category!)!, actions: [firstAction], intentIdentifiers: [], options: [])
                            UNUserNotificationCenter.current().setNotificationCategories([category])

                        }
                    }
                    }
                else
                {
                    print(RestAPI.LOG,"No category Defined","Category")
                }
            }
            else
            {
                print(RestAPI.LOG, "Error Notifcation")
            }
        }
    @available(iOS 10.0, *)
    public static func HandleNotifcation(response : UNNotificationResponse)
             {
                let userInfo = response.notification.request.content.userInfo
                 let notifcationData = Aps(dictionary: (userInfo["aps"] as? NSDictionary)!)
                delegate?.onNotificationView(isView: true)

                if notifcationData?.category != nil
                
                {
                  
                   
                    switch response.actionIdentifier
                   {
                        case "FirstButton" :
                          //  let conVc = iZootoViewController as UIViewController
                            
                            let string = notifcationData?.act1link!
                            if string!.range(of: "http://route.izooto.com") != nil {
                                parseURL(parseLink: notifcationData!.act1link!)
                                print("Yes")
                            }
                            else
                            {
                                ViewController.seriveURL = notifcationData?.act1link
                                print("No")
                                UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
                            }


                            type = "btn1"
                         break
                       case "SecondButton" :
                        let string = notifcationData?.act2link!
                        if string!.range(of: "http://route.izooto.com") != nil {
                            ViewController.seriveURL = notifcationData?.act2link
                            parseURL(parseLink: notifcationData!.act2link!)
                            }
                            else
                            {
                            ViewController.seriveURL = notifcationData?.act2link
                                    UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
                            }
                        type = "btn2"

                        
                         break
                   default:
                   ViewController.seriveURL = notifcationData?.url
                     UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
                    type = "btn0"

                   }
                }
                else{
                    ViewController.seriveURL = notifcationData?.url
                    UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)
                    type = "btn0"
                }
                RestAPI.clickTrack(notificationData: notifcationData!, type: type,userid: (sharedUserDefault?.integer(forKey: SharedUserDefault.Key.registerID))!,token:(sharedUserDefault?.string(forKey: SharedUserDefault.Key.token)!)! )

        }
        
        public static func parseURL(parseLink : String )
        {
            
            let test1 = getQueryStringParameter(url: parseLink, param: "frwd")
            let base64Encoded = test1!

            let decodedData = Data(base64Encoded: base64Encoded)!
            let decodedString = String(data: decodedData, encoding: .utf8)!
            if ((decodedString.range(of: "tel:")) != nil)
            {
                               if let url = URL(string: decodedString) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                } else {
                                    // Fallback on earlier versions
                                }
                                                }

            }
            else
            {
                ViewController.seriveURL = parseLink
                UIApplication.shared.keyWindow?.rootViewController?.present(ViewController(), animated: true, completion: nil)

            }


        }
      public static func getQueryStringParameter(url: String, param: String) -> String? {
         guard let url = URLComponents(string: url) else { return nil }
         return url.queryItems?.first(where: { $0.name == param })?.value
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
    func onNotificationReceived(payload :Aps )
    func onNotificationView(isView : Bool)
}
    

