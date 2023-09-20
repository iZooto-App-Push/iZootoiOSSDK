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
class SceneDelegate: UIResponder, UIWindowSceneDelegate ,iZootoNotificationOpenDelegate,iZootoLandingURLDelegate{
    func onHandleLandingURL(url: String) {
//                    let window = UIApplication.shared.windows.first { $0.isKeyWindow }
//                       let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                       let yourVC = storyboard.instantiateViewController(identifier: "SecondViewController")
//
//                       let navController = UINavigationController(rootViewController: yourVC)
//                       navController.modalPresentationStyle = .fullScreen
//
//                       // you can assign your vc directly or push it in navigation stack as follows:
//                       window!.rootViewController = navController
//                       window!.makeKeyAndVisible()
    }
    
    
    

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //iZooto.notificationOpenDelegate = self
       // iZooto.landingURLDelegate = self

      
        }
    func onNotificationOpen(action: Dictionary<String, Any>) {
        print(action)
//            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
//               let storyboard = UIStoryboard(name: "Main", bundle: nil)
//               let yourVC = storyboard.instantiateViewController(identifier: "SecondViewController")
//
//               let navController = UINavigationController(rootViewController: yourVC)
//               navController.modalPresentationStyle = .fullScreen
//
//               // you can assign your vc directly or push it in navigation stack as follows:
//               window!.rootViewController = navController
//               window!.makeKeyAndVisible()
        }

    }
   
   

   


