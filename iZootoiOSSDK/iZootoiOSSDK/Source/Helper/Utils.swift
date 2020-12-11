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
        preference.set(isInitialise, forKey: "INSTALL")
        didSave(preferences: preference)
    }
    // Checking the UserDefaults is saved or not
   public static func didSave(preferences: UserDefaults){
        let didSave = preferences.synchronize()
        if !didSave{
            // Couldn't Save
            print("Preferences could not be saved!")
        }
    }
    public static func eventValidate(eventName : String)->String
       {
           let replaced = eventName.replacingOccurrences(of: " ", with: "_")
           let validataEventname = SimpleSubstring(string: replaced, length: 32)
          return validataEventname.lowercased()
       }
    public static func dataValidate( data : Dictionary<String,Any>)->Dictionary<String,Any>
    {
        
     
        var updatedData = Dictionary<String,Any>()
         for key in data.keys {


            let value = data[key]
            let keyName = SimpleSubstring(string: key, length: 32)

            if value is Int {
                updatedData[keyName.lowercased()] = value
            }

            if value is Bool {
                updatedData[keyName.lowercased()] = value
            }
           if value is String
           {
            let newValue = SimpleSubstring(string: value as! String, length: 64)
            updatedData[keyName.lowercased()] = newValue
        }
        

        }
        
        
        return updatedData
    }
          private static func SimpleSubstring(string : String, length : Int) -> String {
               var returnString = string

               if (string.count > length) {
                   returnString = String(string[...string.index(string.startIndex, offsetBy: length - 1)])
               }

               return returnString
           }

}
public  func checkTopicNameValidation(topicName : Dictionary<String,String>)-> Bool
{
    let pattern = "[a-zA-Z0-9-_.~%]+"
    

    return true
}
 
  

