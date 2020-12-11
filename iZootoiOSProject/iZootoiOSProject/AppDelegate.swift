//
//  AppDelegate.swift
//  iZootoiOSProject
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import UIKit
import iZootoiOSSDK
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,iZootoNotificationOpenDelegate ,iZootoNotificationReceiveDelegate
    ,iZootoLandingURLDelegate{
  
    
    // handle deeplink
    func onNotificationOpen(action: Dictionary<String, Any>) {
        print(action)
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
       
        // for setting
        let iZootoInitSettings = ["auto_prompt": true,"nativeWebview": true,"provisionalAuthorization":false]
       
        // initialisation
        iZooto.initialisation(izooto_id: "89fd02e5e91f0cbd4e456d3cbef98ce60c517dbe", application: application,  iZootoInitSettings:iZootoInitSettings)//iZootoKeySetting=iZootoInitSettings
        UNUserNotificationCenter.current().delegate = self//initialize()

        iZooto.setFirebaseAnalytics(isCheck: false)
       // iZooto.notificationOpenDelegate = self
        iZooto.notificationReceivedDelegate = self
     //   iZooto.landingURLDelegate = self
        
      
        

            return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        iZooto.getToken(deviceToken: deviceToken)
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        let sharedPref = UserDefaults.standard
        sharedPref.setValue(token, forKey: "Token")
        
        
    


       
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .alert, .sound])

    }


   // @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        iZooto.notificationHandler(response: response)//iZooto.notificationHandler
        completionHandler()

    }
    
}


