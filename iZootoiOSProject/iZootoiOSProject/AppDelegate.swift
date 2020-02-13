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
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        iZooto.initialisation(izooto_id: 42540, application: application)
        UNUserNotificationCenter.current().delegate = self
        let bundleID = Bundle.main.bundleIdentifier
        print("BundleIdentifire",bundleID!)

        if launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
           print("from push")
        }
        
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        iZooto.getToken(deviceToken: deviceToken)
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
       completionHandler([.badge, .alert, .sound])

    }


    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        iZooto.HandleNotifcation(response: response)
    }

}

