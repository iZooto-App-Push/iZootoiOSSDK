//
//  AppDelegate.swift
//  iZootoiOSProject
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import UIKit
import iZootoiOSSDK
import AppTrackingTransparency
import AdSupport
import WebKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,iZootoNotificationOpenDelegate ,iZootoNotificationReceiveDelegate
    ,iZootoLandingURLDelegate{
        var i = 0
        var window: UIWindow?
        private static var controllerData = UIViewController.self


    // handle deeplink
    func onNotificationOpen(action: Dictionary<String, Any>) {

       
    }
    
    // Handle url
    func onHandleLandingURL(url: String) {// setlandingURL
        print("ClickURL",url)
//    UIApplication.shared.keyWindow!.rootViewController?.present(new V, animated: true, completion: nil)
      
    }
    
    // Notification Received
    func onNotificationReceived(payload: Payload) {
        print("Payload",payload.alert?.body! as Any )
        

    }

   
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UNUserNotificationCenter.current().delegate = self
        iZooto.registerForPushNotifications()
//5c6dae82ba66086df247f9766a1094fef62c162e    // 92d7f6d0e5ebc331d0ea9e00aaf0879db6fba9cf
       // let iZootoInitSettings = ["auto_prompt": true,"nativeWebview": false,"provisionalAuthorization":false]
       // iZooto.initialisation(izooto_id: "92d7f6d0e5ebc331d0ea9e00aaf0879db6fba9cf", application: application,  iZootoInitSettings:iZootoInitSettings)
        iZooto.initWithLaunchOptions(launchOptions: launchOptions)
        iZooto.setAppId(izooto_app_id: "92d7f6d0e5ebc331d0ea9e00aaf0879db6fba9cf")
        iZooto.notificationReceivedDelegate = self
       // iZooto.landingURLDelegate = self
        iZooto.notificationOpenDelegate = self
      //  let data = ["language":"English"]
       // iZooto.addUserProperties(data: data)
       // iZooto.addEvent(eventName: "Event", data:data)
       // iZooto.getAdvertisementID(adid: RestAPI.identifierForAdvertising() as! NSString)
        //getAdvertisementIS()
        //iZooto.setSubscription(isSubscribe: true)
        getAdvertisementId();

       
        return true
    }
        func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = -1
        iZooto.setBadgeCount(badgeNumber: -1)

           // requestPermission()
           
          
    }
        func requestPermission() {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        // Tracking authorization dialog was shown
                        // and we are authorized
                        print("Authorized")
                        
                        
                        // Now that we are authorized we can get the IDFA
                        print(ASIdentifierManager.shared().advertisingIdentifier)
                    case .denied:
                        // Tracking authorization dialog was
                        // shown and permission is denied
                        print("Denied")
                    case .notDetermined:
                        // Tracking authorization dialog has not been shown
                        print("Not Determined")
                    case .restricted:
                        print("Restricted")
                    @unknown default:
                        print("Unknown")
                    }
                }
            }
        }
        
        
        func getAdvertisementId()
        {
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
             
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:

                            // Authorized
                            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                            print(idfa)
                            iZooto.getAdvertisementID(adid: idfa as NSString)
                        case .denied,
                                .notDetermined,
                                .restricted:
                            break
                        @unknown default:

                            break
                        }
                    }
                }
            } else {
                let adID = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                iZooto.getAdvertisementID(adid: adID as NSString)

            }
            })
        }

  
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
                     return String(format: "%02.2hhx", data)
                 }
        let sharedPref = UserDefaults.standard
        let token = tokenParts.joined()
        sharedPref.setValue(token, forKey: "TOKEN")
        iZooto.getToken(deviceToken: deviceToken)
    
    }
   // @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification.request.content.userInfo)
        iZooto.handleForeGroundNotification(notification: notification, displayNotification: "None", completionHandler: completionHandler)

        
    }

    //@available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        iZooto.notificationHandler(response: response)//iZooto.notificationHandler
        completionHandler()

    }
    
}


