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
        print("DeepLink",action)
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
        
        let iZootoInitSettings = ["auto_prompt": true,"nativeWebview": false,"provisionalAuthorization":false]
        iZooto.initialisation(izooto_id: "92d7f6d0e5ebc331d0ea9e00aaf0879db6fba9cf", application: application,  iZootoInitSettings:iZootoInitSettings)
        UNUserNotificationCenter.current().delegate = self
       // let data = ["language" :"tamil","match":"cricket"]
       // iZooto.addUserProperties(data: data)
        
        iZooto.notificationReceivedDelegate = self
        iZooto.landingURLDelegate = self
        iZooto.notificationOpenDelegate = self
      
        return true
    }
        func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        iZooto.setBadgeCount(badgeNumber: 0)
    }
    func showAlert()
    {
        
        let alert = UIAlertController(title: "Hello!", message: "Greetings from AppDelegate.", preferredStyle: .alert)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)


    }
    func requestPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
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
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        iZooto.getToken(deviceToken: deviceToken)
    
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        iZooto.handleForeGroundNotification(notification: notification, displayNotification: "None", completionHandler: completionHandler)
        
    }


   // @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        iZooto.notificationHandler(response: response)//iZooto.notificationHandler
        completionHandler()

    }
    
}


