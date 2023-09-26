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

    }
    
    
    

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
       

      
        }
    func onNotificationOpen(action: Dictionary<String, Any>) {
        print(action)

        }

    }
   
   

   


