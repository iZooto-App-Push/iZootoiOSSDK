//
//  RestAPI.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//
import Foundation
import Foundation
import UIKit
import AdSupport
import AppTrackingTransparency

protocol ResponseHandler  : AnyObject{
    func onSuccess()
    func onFailure()
}
@objc
public class RestAPI : NSObject
{
     static let   BASEURL = "https://aevents.izooto.com/app.php"
     static let   DATURL="https://cdn.izooto.com/app/app_"
     static let   IMPRESSION_URL="https://impr.izooto.com/imp";
     static let   LOG = "iZooto :"
     static let EVENT_URL = "https://et.izooto.com/evt";
     static let  PROPERTIES_URL="https://prp.izooto.com/prp";
     static let  CLICK_URL="https://clk.izooto.com/clk";
     static let LASTNOTIFICATIONCLICKURL="https://lci.izooto.com/lci";
     static let LASTNOTIFICATIONVIEWURL="https://lim.izooto.com/lim";
     static let LASTVISITURL="https://lvi.izooto.com/lvi";
     static let EXCEPTION_URL="https://aerr.izooto.com/aerr";
     static let SUBSCRIPTIONURL = "https://usub.izooto.com/sunsub";
     static let FALLBACK_URL = "https://flbk.izooto.com/default.json"
     static let  SDKVERSION = "2.0.8"
    static func callSubscription(isSubscribe : Int,token : String,userid : Int)
    {
        if(isSubscribe != -1 && userid != 0)
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                                                URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: "8"),
                                                URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: "3"),
                                                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value: SDKVERSION),
                                                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN,value: token),
                                                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: "5"),
                                                URLQueryItem(name: AppConstant.iZ_KEY_PT, value: "0")]
            var request = URLRequest(url: URL(string: self.SUBSCRIPTIONURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                    // print("Subscribe","sucess")
                }
            }.resume()
        }
        else
        {
            sendExceptionToServer(exceptionName: "isSubscribe\(isSubscribe)", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callSubscription", pid: userid, token: token , rid: "",cid : "")
            
        }
        
    }
    
    public static   func getRequest(uuid: String, completionBlock: @escaping (String) -> Void) -> Void
    {
        let requestURL = URL(string: self.DATURL + "\(uuid).dat")
        let request = URLRequest(url: requestURL!)
        let requestTask = URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            if(error != nil) {
                sendExceptionToServer(exceptionName: error?.localizedDescription ?? "not found", className: "Rest API", methodName: "getRequest", pid: 0, token: "" , rid: "",cid : "")
                
            }else
            {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200{
                        let outputStr  = String(data: data!, encoding: String.Encoding.utf8)!
                        completionBlock(outputStr);
                    }
                    else
                    {
                        print(AppConstant.IZ_TAG,AppConstant.APP_ID_ERROR)
                        
                    }
                }
                
                
            }
        }
        requestTask.resume()
    }
    
    
   
    // get Bundle ID
    static func getAppInfo()->String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
    }
    
    // get App Name
    static func getAppName()->String {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        return appName
    }
    
    // getOS Information
    static func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    // get App version
    static func getAppVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return "\(version)"
    }
    
    
    // send event to server
    static func callEvents(eventName : String, data : NSString,userid : Int,token : String)
    {
        if( eventName != ""  && data != "" && userid != 0){
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                                                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                                                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                                                URLQueryItem(name: "act", value: "\(eventName)"),
                                                URLQueryItem(name: "et", value: "evt"),
                                                URLQueryItem(name: "val", value: "\(data)")
                                                ]
                                              
            var request = URLRequest(url: URL(string: RestAPI.EVENT_URL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                    print(AppConstant.ADD_EVENT)
                    sharedUserDefault?.set("", forKey:AppConstant.KEY_EVENT)
                    sharedUserDefault?.set("", forKey: AppConstant.KEY_EVENT_NAME)
                }
            }.resume()
            
        }
        else{
            print(AppConstant.ERROR_EVENT)
            sendExceptionToServer(exceptionName: "User Event name and  data are blank", className: "Rest API", methodName: "callEvents", pid: userid, token: token , rid: "",cid : "")
        }
        
    }
    
    // send user properties to server
    static func callUserProperties( data : NSString,userid : Int,token : String)
    {
        if( data != ""  && userid != 0){
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                                                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                                                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                                                URLQueryItem(name: "act", value: "add"),
                                                URLQueryItem(name: "et", value: "userp"),
                                                URLQueryItem(name: "val", value: "\(data)")
                                                ]
            var request = URLRequest(url: URL(string: RestAPI.PROPERTIES_URL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                    sharedUserDefault?.set("", forKey:"UserPropertiesData")
                    print(AppConstant.ADD_PROPERTIES)
                    
                }
                
            }.resume()
            
        }
        else
        {
            sendExceptionToServer(exceptionName: "User Properties data are blank", className: "Rest API", methodName: "callUserProperties", pid: userid, token: token , rid: "",cid : "")
        }
    }
    
    // track the notification impression
    static func callImpression(notificationData : Payload,userid : Int,token : String)
    {
        if(notificationData.rid != nil && userid != 0 && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                                                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                                                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                                                URLQueryItem(name: "cid", value: "\(notificationData.id!)"),
                                                URLQueryItem(name: "rid", value: "\(notificationData.rid!)"),
                                                URLQueryItem(name: "op", value: "view"),
                                                URLQueryItem(name: "ver", value: SDKVERSION)
                                                ]
            var request = URLRequest(url: URL(string: self.IMPRESSION_URL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                    // print("imp","success")
                    
                }
            }.resume()
        }
        else
        {
            sendExceptionToServer(exceptionName: "Notification payload is not loading", className: "Rest API", methodName: "clickTrack", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
            
        }
        
    }
    
    // track the notification click
    static func clickTrack(notificationData : Payload,type : String, userid : Int,token : String)
    {
        if(notificationData.rid != nil && userid != 0 && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                                                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                                                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                                                URLQueryItem(name: "cid", value: "\(notificationData.id!)"),
                                                URLQueryItem(name: "rid", value: "\(notificationData.rid!)"),
                                                URLQueryItem(name: "op", value: "click"),
                                                URLQueryItem(name: "ver", value: SDKVERSION),
                                                URLQueryItem(name: "btn", value: "\(type)")
                                               ]
            var request = URLRequest(url: URL(string: RestAPI.CLICK_URL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {
                    // print("C-N")
                }
            }.resume()
        }
        else
        {
            
            sendExceptionToServer(exceptionName: "Notification payload is not loading", className: "Rest API", methodName: "clickTrack", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
            
            
        }
        
        
    }
    static func performRequest(with urlString : String)
    {
        if let url = URL(string: urlString)
        {
            let session = URLSession(configuration: .default)
            let task  = session.dataTask(with: url)
            {(data,response,error)in
                if error != nil
                {
                    print(AppConstant.FAILURE)
                    return
                }
                if data != nil{
                    print(AppConstant.SUCESS)
                }
                
            }
            task.resume()
        }
    }
    
    // getting advertisement id
    
    @objc public static func identifierForAdvertising() -> String? {
        if #available(iOS 14, *) {
            
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return "0000-0000-0000-0000"
            }
            print(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
            
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            
            
        }
        else {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
    }
    
    // last visit data send to server
    @objc static func lastVisit(userid : Int,token : String)
    {
        if(token != "" && userid != 0)
        {
            let data = ["last_website_visit":"true","lang":"en"] as [String:String]
            if let theJSONData = try?  JSONSerialization.data(withJSONObject: data,options: .fragmentsAllowed),
               let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue) {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                                                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                                                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                                                    URLQueryItem(name: "act", value: "add"),
                                                    URLQueryItem(name: "isid", value: "1"),
                                                    URLQueryItem(name: "et", value: "userp"),
                                                    URLQueryItem(name: "val", value: "\(validationData)")
                                                    ]
                var request = URLRequest(url: URL(string: RestAPI.LASTVISITURL)!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                URLSession.shared.dataTask(with: request){(data,response,error) in
                    
                    do {
                        //print("l","v")
                        
                    }
                }.resume()
                
                
                
            }
        }
        else
        {
            sendExceptionToServer(exceptionName: "Token or  pid or missing", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression", pid: userid, token: token , rid: "",cid :"")
        }
        
    }
    // last impression send to server
    @objc   static func lastImpression(notificationData : Payload,userid : Int,token : String)
    {
        if(notificationData.rid != nil && userid != 0 && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                                                 URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                                                 URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                                                 URLQueryItem(name: "cid", value: "\(notificationData.id!)"),
                                                 URLQueryItem(name: "rid", value: "\(notificationData.rid!)"),
                                                 URLQueryItem(name: "op", value: "view")
                                              ]
            var request = URLRequest(url: URL(string: RestAPI.LASTNOTIFICATIONVIEWURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                    //print("l","i")
                    
                }
            }.resume()
        }
        else
        {
            
            sendExceptionToServer(exceptionName: "Notification payload is not loading", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
            
            
        }
        
        
        
    }
    // last click data send to server
    @objc   static func lastClick(notificationData : Payload,userid : Int,token : String)
    {
        if(userid != 0 && token != "" && notificationData.rid != nil)
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                                                 URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                                                 URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                                                 URLQueryItem(name: "cid", value: "\(notificationData.id!)"),
                                                 URLQueryItem(name: "rid", value: "\(notificationData.rid!)"),
                                                 URLQueryItem(name: "op", value: "view")
                                              ]
            
            var request = URLRequest(url: URL(string: RestAPI.LASTNOTIFICATIONCLICKURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                    // print("l","c")
                    
                }
            }.resume()
        }
        else
        {
            sendExceptionToServer(exceptionName: "Notification payload is not loading", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
            
        }
        
    }
    // register the token on our panel
    @objc  static func registerToken(token : String, izootoid : Int)
    {
        if(token != "" && izootoid != 0)
        {
            
            let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""


            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems =
            [
                            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(izootoid)"),
                            URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: "8"),
                            URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: "3"),
                            URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(currentTimeInMilliSeconds())"),
                            URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(getAppVersion())"),
                            URLQueryItem(name: AppConstant.iZ_KEY_OS, value: "5"),
                            URLQueryItem(name:AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                            URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                            URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: identifierForAdvertising()!),
                            URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(getVersion())"),
                            URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(getDeviceName())"),
                            URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(getAppVersion())"),
                            URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: "\(pluginVersion)")
                            
            ]
            var request = URLRequest(url: URL(string: RestAPI.BASEURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                    print(AppConstant.DEVICE_TOKEN,token)
                    UserDefaults.isRegistered(isRegister: true)
                    print(AppConstant.SUCESSFULLY)
                    let date = Date()
                    let format = DateFormatter()
                    format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                    let formattedDate = format.string(from: date)
                    if(formattedDate != (sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_LAST_VISIT)))
                    {
                        RestAPI.lastVisit(userid: izootoid, token:token)
                        sharedUserDefault?.set(formattedDate, forKey: AppConstant.iZ_KEY_LAST_VISIT)
                        let dicData = sharedUserDefault?.dictionary(forKey:AppConstant.iZ_USERPROPERTIES_KEY)
                        if(dicData != nil)
                        {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                iZooto.addUserProperties(data: dicData!)
                                
                            }
                        }
                        
                    }
                    
                }
            }.resume()
        }
        else
        {
            sendExceptionToServer(exceptionName: AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, pid: 0, token: "", rid: "", cid: "")
            
        }
        
    }
    
    // send the token with adID
    @objc static func registerToken(token : String, izootoid : Int ,adid : NSString)
    {
        if(token != "" && izootoid != 0)
        {
            let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems =
            [
                                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(izootoid)"),
                                URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: "8"),
                                URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: "3"),
                                URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(currentTimeInMilliSeconds())"),
                                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(getAppVersion())"),
                                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: "5"),
                                URLQueryItem(name:AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                                URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                                URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: "\(adid)"),
                                URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(getVersion())"),
                                URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(getDeviceName())"),
                                URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(getAppVersion())"),
                                URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: "\(pluginVersion)")

            ]
            var request = URLRequest(url: URL(string: RestAPI.BASEURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
                do {
                    sharedUserDefault?.set(true,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                    sharedUserDefault?.set("", forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID_)
                    
                    
                    
                }
            }.resume()
        }
        else
        {
            sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
            sendExceptionToServer(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, pid: 0, token: "", rid: "", cid: "")
            
        }
    }
    
    // send exception to the server
 @objc  public static func sendExceptionToServer(exceptionName : String ,className : String ,methodName: String,pid :Int ,token : String,rid : String,cid : String)
    {
        let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""

        let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(pid)"),
                                            URLQueryItem(name: "exceptionName", value: "\(exceptionName)"),
                                            URLQueryItem(name: "methodName", value: "\(methodName)"),
                                            URLQueryItem(name: "className", value:"\(className))"),
                                            URLQueryItem(name: "bKey", value: token),
                                            URLQueryItem(name: "av", value: SDKVERSION),
                                            URLQueryItem(name: "rid", value: "\(rid)"),
                                            URLQueryItem(name: "cid", value: "\(cid)"),
                                            URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: "\(pluginVersion)"),

                                            URLQueryItem(name: "osVersion", value: "\(getVersion())"),
                                            URLQueryItem(name: "deviceName", value: "\(getDeviceName())"),
                                            URLQueryItem(name: "check", value: "\(getAppVersion())")]
        var request = URLRequest(url: URL(string: RestAPI.EXCEPTION_URL)!)
        request.httpMethod = AppConstant.iZ_POST_REQUEST
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        URLSession.shared.dataTask(with: request){(data,response,error) in
            
            do {
                
                
            }
        }.resume()
    }
    
    // current timestamp
    
    static func currentTimeInMilliSeconds()-> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    // get device name
    static func getDeviceName()->String
    {
        let name = UIDevice.current.model
        return name
        
    }
    
    // get device id
    static func getUUID()->String
    {
        let device_id = UIDevice.current.identifierForVendor!.uuidString
        
        return device_id
        
    }
    
    //get add version
    
    static func  getVersion() -> String {
        return UIDevice.current.systemVersion
        
    }
    
}





