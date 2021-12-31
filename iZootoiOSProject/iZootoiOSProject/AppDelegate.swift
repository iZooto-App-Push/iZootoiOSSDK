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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,iZootoNotificationOpenDelegate ,iZootoNotificationReceiveDelegate
    ,iZootoLandingURLDelegate{
        

    // handle deeplink
    func onNotificationOpen(action: Dictionary<String, Any>) {
        NSLog("DeepLink2\(action)")
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
          let viewController = mainStoryBoard.instantiateViewController(withIdentifier: "green_vc")
          window?.rootViewController = viewController
          window?.makeKeyAndVisible()
    }
    
    // Handle url
    func onHandleLandingURL(url: String) {// setlandingURL
        print("ClickURL",url)
    }
    
    // Notification Received
    func onNotificationReceived(payload: Payload) {
        print("Payload",payload.alert?.body! as Any )
        

    }

    var i = 0
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        iZooto.registerForPushNotifications()
//5c6dae82ba66086df247f9766a1094fef62c162e    // 92d7f6d0e5ebc331d0ea9e00aaf0879db6fba9cf
        let iZootoInitSettings = ["auto_prompt": true,"nativeWebview": false,"provisionalAuthorization":false]
        iZooto.initialisation(izooto_id: "92d7f6d0e5ebc331d0ea9e00aaf0879db6fba9cf", application: application,  iZootoInitSettings:iZootoInitSettings)
        iZooto.notificationReceivedDelegate = self
        iZooto.landingURLDelegate = self
        iZooto.notificationOpenDelegate = self
      //  let data = ["language":"English"]
       // iZooto.addUserProperties(data: data)
       // iZooto.addEvent(eventName: "Event", data:data)
       // iZooto.getAdvertisementID(adid: RestAPI.identifierForAdvertising() as! NSString)
        //getAdvertisementIS()
        //iZooto.setSubscription(isSubscribe: true)

        return true
    }
        func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = -1
        iZooto.setBadgeCount(badgeNumber: -1)
            
           
          
    }
        func getAdvertisementIS()
        {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            // Authorized
                            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
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
        }

  
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
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


