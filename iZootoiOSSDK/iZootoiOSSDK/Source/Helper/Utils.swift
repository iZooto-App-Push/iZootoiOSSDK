//
//  Utils.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
import UIKit
@objc
public class Utils : NSObject
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
    
    public static func saveAccessToken(access_token: String){
        let preferences = UserDefaults.standard
        preferences.set(access_token, forKey: TOKEN)
        Utils.didSave(preferences: preferences)
    }
    
    public static func getAccessToken() -> String{
        let preferences = UserDefaults.standard
        if preferences.string(forKey: TOKEN) != nil{
            if let access_token = preferences.string(forKey: TOKEN) {
                return access_token
            }
            return "Token not found."
        } else {
            return ""
        }
    }
    
    public static func getUserDeviceToken() -> String? {
        return sharedUserDefault?.string(forKey: SharedUserDefault.Key.token) ?? ""
    }
    
    public static func getUserId() -> String? {
        let userDefault = UserDefaults.standard
        return userDefault.string(forKey: AppConstant.REGISTERED_ID)
    }
    public static func initFireBaseInialise(isInitialise : Bool)
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
                
                if let value = value as? String{
                    let newValue = SimpleSubstring(string: value, length: 64)
                    updatedData[keyName.lowercased()] = newValue
                }
                
            }
        }
        return updatedData
    }
    public static func SimpleSubstring(string : String, length : Int) -> String {
        var returnString = string
        if (string.count > length) {
            returnString = String(string[...string.index(string.startIndex, offsetBy: length - 1)])
        }
        return returnString
    }
    
    public static func getBundleName()->String
    {
        if let bundleID = Bundle.main.bundleIdentifier{
            return "group."+bundleID + ".iZooto"
        }
        return "Not found"
    }
    
    // get Bundle ID
    static func getAppInfo()->String {
        if let dictionary = Bundle.main.infoDictionary {
            if let version = dictionary["CFBundleShortVersionString"] as? String {
                return version
            }
        }
        return "0.0"
    }
    
    // get App Name
    static func getAppName()->String {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        return appName ?? ""
    }
    
    // getOS Information
    static func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    // get App version
    static func getAppVersion() -> String {
        if let dictionary = Bundle.main.infoDictionary{
            if let version = dictionary["CFBundleShortVersionString"] as? String{
                return version
            }
        }
        return "0.0"
    }
    
    // current timestamp
    static func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    // get device id
    static func getUUID()->String
    {
        let device_id = UIDevice.current.identifierForVendor?.uuidString
        return device_id ?? ""
    }
    
    //get add version
    static func  getVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
//    static func checkTopicNameValidation(topicName : Dictionary<String,String>)-> Bool
//    {
//        let pattern = "[a-zA-Z0-9-_.~%]+"
//        return true
//    }
    static func handleOnceException(exceptionName: String, className: String, methodName: String,  rid: String, cid: String)
    {
        
        
        let userDefaults = UserDefaults.standard
        guard let appid = (UserDefaults.standard.value(forKey: "appID") as? String) else {
            print("App ID not found to send exception.")
            return
        }
        if userDefaults.object(forKey: methodName) == nil && (appid != nil || appid != ""){
               userDefaults.set("isPresent", forKey: methodName)
            RestAPI.sendExceptionToServer(exceptionName: exceptionName, className: className, methodName: methodName,  rid: rid, cid: cid, appId: appid)
               
           }
    }

}



extension LosslessStringConvertible {
    var string: String { .init(self) }
}

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}




