//
//  Utils.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
import UIKit
import AdSupport
@objc
internal class Utils : NSObject
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
    
    public static func getUserDeviceToken(bundleName: String) -> String? {
        if let userDefault = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
            return userDefault.string(forKey: AppConstant.IZ_DEVICE_TOKEN)
        }else{
            return "token not found"
        }
    }
    
    public static func getUserId(bundleName: String) -> String? {
        if let userDefault = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
            return userDefault.string(forKey: AppConstant.REGISTERED_ID)
        }else{
            return "pid not found"
        }
        
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
    
    public static func getGroupName(bundleName: String)->String?
    {
        return "group."+bundleName+".iZooto"
    }
    
    // getOS Information
    static func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    // get App version
    static func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    }
    
    // current timestamp
    static func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
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
    static func handleOnceException(bundleName: String, exceptionName: String, className: String, methodName: String,  rid: String?, cid: String?, userInfo: [AnyHashable: Any]?)
    {
        let userDefaults = UserDefaults.standard
        var appid = ""
        if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
            appid = userDefaults.value(forKey: "appID") as? String ?? ""
        }
        if userDefaults.object(forKey: methodName) == nil{
            userDefaults.set("isPresent", forKey: methodName)
            RestAPI.sendExceptionToServer(bundleName: bundleName, exceptionName: exceptionName, className: className, methodName: methodName,  rid: rid, cid: cid, appId: appid, userInfo: userInfo ?? nil)
            
        } else {
            print("Key \(methodName) already exists. Data not stored.")
        }
    }
    
    static func addMacros(url: String) -> String {
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
        var finalUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
        if finalUrl != "" && !finalUrl.isEmpty{
            var registerTime: TimeInterval = 0
            let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
            let pid = Utils.getUserId(bundleName: bundleName) ?? ""
            if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){
                registerTime = userDefaults.value(forKey: "unixTS") as? TimeInterval ?? 0
            }
            let time = Utils.unixTimeDifference(unixTimestamp: registerTime )
            
            if finalUrl.contains("{~UUID~}") {
                finalUrl = finalUrl.replacingOccurrences(of: "{~UUID~}", with: token)
            }
            if finalUrl.contains("{~ADID~}") {
                finalUrl = finalUrl.replacingOccurrences(of: "{~ADID~}", with: ASIdentifierManager.shared().advertisingIdentifier.uuidString)
            }
            if finalUrl.contains("{~PID~}") {
                finalUrl = finalUrl.replacingOccurrences(of: "{~PID~}", with: pid)
            }
            if finalUrl.contains("{~DEVICEID~}") {
                finalUrl = finalUrl.replacingOccurrences(of: "{~DEVICEID~}", with: token)
            }
            if finalUrl.contains("{~DEVICETOKEN~}")
            {
                finalUrl = finalUrl.replacingOccurrences(of: "{~DEVICETOKEN~}", with: token)
            }
            if finalUrl.contains("{~SUBAGED~}")
            {
                finalUrl = finalUrl.replacingOccurrences(of: "{~SUBAGED~}", with: String(time.days))
            }
            if finalUrl.contains("{~SUBAGEM~}")
            {
                finalUrl = finalUrl.replacingOccurrences(of: "{~SUBAGEM~}", with: String(time.months))
            }
            if finalUrl.contains("{~SUBAGEY~}")
            {
                finalUrl = finalUrl.replacingOccurrences(of: "{~SUBAGEY~}", with: String(time.years))
            }
            if finalUrl.contains("{~SUBUTS~}")
            {
                finalUrl = finalUrl.replacingOccurrences(of: "{~SUBUTS~}", with: String(Int64(registerTime)))
            }
            
        }
        return finalUrl
    }
    
   
    static func unixTimeDifference(unixTimestamp: TimeInterval) -> (years: Int, months: Int, days: Int) {
        
        let registeredTimestampMillis: TimeInterval = unixTimestamp// Add your registered timestamp in milliseconds here
        let currentTimestampMillis: TimeInterval = TimeInterval(Int(Date().timeIntervalSince1970 * 1000))
        
//        let registeredTimestampMillis: TimeInterval = 1754718397000
//        let currentTimestampMillis: TimeInterval = 1838368000000
        
        let currentDate = Date(timeIntervalSince1970: currentTimestampMillis / 1000)
        let registeredDate = Date(timeIntervalSince1970: registeredTimestampMillis / 1000)
        
        var calendar = Calendar.current
        calendar.timeZone = .current
        let components = calendar.dateComponents([.year, .month, .day], from: registeredDate, to: currentDate)
        
        let years = components.year ?? 0
        let months = components.month ?? 0
        let totalDays = calendar.dateComponents([.day], from: registeredDate, to: currentDate).day ?? 0
        let totalMonths = months + years * 12
        
        return (years: years, months: totalMonths, days: totalDays)
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




