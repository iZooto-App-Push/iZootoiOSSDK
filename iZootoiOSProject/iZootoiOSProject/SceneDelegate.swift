//
//  SceneDelegate.swift
//  iZootoiOSProject
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import UIKit
import iZootoiOSSDK

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//       if let response = connectionOptions.notificationResponse{
//           print(response.notification.request.content.userInfo)
//           if #available(iOS 13.0, *) {
//               guard let _ = (scene as? UIWindowScene) else { return }
//
//               NSLog("SceneDelegate\(response.notification.request.content.userInfo)")
//                let userinfo = response.notification.request.content.userInfo
//               let notifcationData = Payload(dictionary: (userinfo["aps"] as? NSDictionary)!)
//               if(notifcationData?.ap != nil)
//               {
//                 var data = Dictionary<String,Any>()
//                   data["button1ID"] = notifcationData?.act1id
//                   data["button1Title"] = notifcationData?.act1name
//                   data["button1URL"] = notifcationData?.act1link
//                   data["additionalData"] = notifcationData?.ap
//                   data["landingURL"] = notifcationData?.url
//                   data["button2ID"] = notifcationData?.act2id
//                   data["button2Title"] = notifcationData?.act2name
//                   data["button2URL"] = notifcationData?.act2link
//                   data["actionType"] = 0
//               NSLog("DeepLinkData\(data)")
//                   //navigate the class
//                   let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//                     let viewController = mainStoryBoard.instantiateViewController(withIdentifier: "green_vc")
//                     window?.rootViewController = viewController
//
//
//           }
//       }
//
//
//       guard let _ = (scene as? UIWindowScene) else { return }
//    }
//
        guard (scene as? UIWindowScene) != nil else { return }
        if let userInfo = connectionOptions.notificationResponse?.notification.request.content.userInfo {
            let notifcationData = Payload(dictionary: (userInfo["aps"] as? NSDictionary)!)
                         if(notifcationData?.ap != nil)
                         {
                           var data = Dictionary<String,Any>()
                             data["button1ID"] = notifcationData?.act1id
                             data["button1Title"] = notifcationData?.act1name
                             data["button1URL"] = notifcationData?.act1link
                             data["additionalData"] = notifcationData?.ap
                             data["landingURL"] = notifcationData?.url
                             data["button2ID"] = notifcationData?.act2id
                             data["button2Title"] = notifcationData?.act2name
                             data["button2URL"] = notifcationData?.act2link
                             data["actionType"] = 0
                             //navigate the class
                             let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                               let viewController = mainStoryBoard.instantiateViewController(withIdentifier: "green_vc")
                               window?.rootViewController = viewController
          
          
                     }
        }

    }
    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        iZooto.setBadgeCount(badgeNumber: 0)
    }
    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
            UIApplication.shared.applicationIconBadgeNumber = 0
            iZooto.setBadgeCount(badgeNumber: 0)

    }
   

   
}

