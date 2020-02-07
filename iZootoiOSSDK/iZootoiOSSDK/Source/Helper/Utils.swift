//
//  Utils.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
import UIKit
public class Utils
{
   public static  let TOKEN = "save_token"

    public static func getDeviceName()->String
    {
        let deviceName = UIDevice.current.name
        return deviceName
        
        
    }
    public static func getSystemVersion()->String{
        let systemVersion = UIDevice.current.systemVersion
        return systemVersion
        
    }
    public static func getCapitalCharacter( string : String)->String{
        return ""
    }
    

    public static func saveAccessToken(access_token: String){
        let preferences = UserDefaults.standard
        preferences.set(access_token, forKey: TOKEN)
        Utils.didSave(preferences: preferences)
    }
    
    
    
   public static func getAccessToken() -> String{
        let preferences = UserDefaults.standard
        if preferences.string(forKey: TOKEN) != nil{
            let access_token = preferences.string(forKey: TOKEN)
            return access_token!
        } else {
            return ""
        }
    }
   public static func  initFireBaseInialise(isInitialise : Bool)
    {
        let preference = UserDefaults.standard
        print("Install",isInitialise)
        preference.set(isInitialise, forKey: "INSTALL")
        didSave(preferences: preference)
    }
  public static func getInstalled()->Bool
    {
        let preference = UserDefaults.standard
        if preference.bool(forKey: "INSTALL") != nil

        {
            let isIntalled = preference.bool(forKey: "INSTALL")
            return isIntalled

        }
        else{
        return false
        }
    }

    // Checking the UserDefaults is saved or not
   public static func didSave(preferences: UserDefaults){
        let didSave = preferences.synchronize()
        if !didSave{
            // Couldn't Save
            print("Preferences could not be saved!")
        }
    }

}
 
  

