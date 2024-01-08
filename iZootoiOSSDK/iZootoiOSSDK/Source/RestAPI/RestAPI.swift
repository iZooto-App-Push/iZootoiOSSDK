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
import UserNotifications

protocol ResponseHandler  : AnyObject{
    func onSuccess()
    func onFailure()
}

@objc
public class RestAPI : NSObject
{
    //******** Live *******
    
    static let BASEURL = "https://aevents.izooto.com/app"
    static let ENCRPTIONURL="https://cdn.izooto.com/app/app_"
    static let IMPRESSION_URL="https://impr.izooto.com/imp";
    static let LOG = "iZooto :"
    static let EVENT_URL = "https://et.izooto.com/evt";
    static let PROPERTIES_URL="https://prp.izooto.com/prp";
    static let CLICK_URL="https://clk.izooto.com/clk";
    static let LASTNOTIFICATIONCLICKURL="https://lci.izooto.com/lci";
    static let LASTNOTIFICATIONVIEWURL="https://lim.izooto.com/lim";
    static let LASTVISITURL="https://lvi.izooto.com/lvi";
    static let EXCEPTION_URL="https://aerr.izooto.com/aerr";
    static let MEDIATION_IMPRESSION_URL = "https://med.dtblt.com/medi";
    static let MEDIATION_CLICK_URL = "https://med.dtblt.com/medc";
    static let UNSUBSCRITPION_SUBSCRIPTION = "https://usub.izooto.com/sunsub"
    static let SDKVERSION = "2.2.2"
    //fallback url
    static let FALLBACK_URL = "https://flbk.izooto.com/default.json"
    static var fallBackLandingUrl = ""
    
    //All notification Data
    static let ALL_NOTIFICATION_DATA = "https://nh.iz.do/nh/"
    static var index = 0
    static var stopCalling = false
    static var lessData = 0
    
    static var fallBackTitle = ""
    static let defaults = UserDefaults.standard
    private static var clickStoreData: [[String:Any]] = []
    private static var mediationClickStoreData: [[String:Any]] = []
    
    /* Handle the subscription api */
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
            var request = URLRequest(url: URL(string: "\(RestAPI.UNSUBSCRITPION_SUBSCRIPTION)")!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                debugPrint("Subscription received Successfully:", data)
                            }
                        }else{
                            if self.defaults.value(forKey: "callSubscription") == nil{
                                self.defaults.setValue("true", forKey: "callSubscription")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callSubscription", pid: userid, token: token , rid: "",cid : "")
                            }
                        }
                    }
                } catch {
                    if self.defaults.value(forKey: "callSubscription") == nil{
                        self.defaults.setValue("true", forKey: "callSubscription")
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callSubscription", pid: userid, token: token , rid: "",cid : "")
                    }
                }
            }.resume()
        }
        else
        {
            if self.defaults.value(forKey: "callSubscription") == nil{
                self.defaults.setValue("true", forKey: "callSubscription")
                sendExceptionToServer(exceptionName: "isSubscribe\(isSubscribe) or UserId Null", className:AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callSubscription", pid: userid, token: token , rid: "",cid : "")
            }
        }
    }
    
    public static func getRequest(uuid: String, completionBlock: @escaping (String) -> Void) -> Void
    {
        let isEnabled : Bool = UserDefaults.standard.bool(forKey: AppConstant.iZ_LOG_ENABLED)
        if uuid != "" {
            if let requestURL = URL(string: "\(ENCRPTIONURL)\(uuid).dat"){
                var request = URLRequest(url: requestURL)
                request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
                let config = URLSessionConfiguration.default
                config.waitsForConnectivity = true
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    if(error != nil) {
                        if self.defaults.value(forKey: "getRequest") == nil{
                            self.defaults.setValue("true", forKey: "getRequest")
                            sendExceptionToServer(exceptionName: error?.localizedDescription ?? "not found", className: "Rest API", methodName: "getRequest", pid: 0, token: "" , rid: "",cid : "")
                        }
                        if isEnabled{
                            print(AppConstant.IZ_TAG,AppConstant.APP_ID_ERROR)
                        }
                    }else
                    {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200{
                                
                                if UserDefaults.standard.value(forKey: AppConstant.iZ_CLICK_OFFLINE_DATA) != nil{
                                    self.offlineClickTrackCall()
                                }
                                if UserDefaults.standard.value(forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA) != nil{
                                    self.mediationOfflineClickTrackCall()
                                }
                                let outputStr  = String(data: data!, encoding: String.Encoding.utf8) ?? ""
                                completionBlock(outputStr)
                            }
                            else
                            {
                                if self.defaults.value(forKey: "getRequest") == nil{
                                    self.defaults.setValue("true", forKey: "getRequest")
                                    sendExceptionToServer(exceptionName: error?.localizedDescription ?? "not found", className: "Rest API", methodName: "getRequest", pid: 0, token: "" , rid: "",cid : "")
                                }
                                if isEnabled{
                                    print(AppConstant.IZ_TAG,AppConstant.APP_ID_ERROR)
                                }
                            }
                        }
                    }
                }.resume()
            }
        }else{
            if self.defaults.value(forKey: "getRequest") == nil{
                self.defaults.setValue("true", forKey: "getRequest")
                sendExceptionToServer(exceptionName: "UUID not found", className: "Rest API", methodName: "getRequest", pid: 0, token: "" , rid: "",cid : "")
            }
            if isEnabled{
                print(AppConstant.IZ_TAG,AppConstant.APP_ID_ERROR)
            }
        }
    }
    
    
    
    // send event to server
    static func callEvents(eventName : String, data : NSString,userid : Int,token : String)
    {
        if( eventName != ""  && data != "" && userid != 0){
            let isEnabled : Bool = UserDefaults.standard.bool(forKey: AppConstant.iZ_LOG_ENABLED)
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
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                if isEnabled {
                                    debugPrint(AppConstant.ADD_EVENT)
                                }
                                sharedUserDefault?.set("", forKey:AppConstant.KEY_EVENT)
                                sharedUserDefault?.set("", forKey: AppConstant.KEY_EVENT_NAME)
                            }
                        }else{
                            if self.defaults.value(forKey: "callEvents") == nil{
                                self.defaults.setValue("true", forKey: "callEvents")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: "Rest API", methodName: "callEvents", pid: userid, token: token , rid: "",cid : "")
                            }
                        }
                    }
                } catch {
                    if self.defaults.value(forKey: "callEvents") == nil{
                        self.defaults.setValue("true", forKey: "callEvents")
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: "Rest API", methodName: "callEvents", pid: userid, token: token , rid: "",cid : "")
                    }
                    if isEnabled {
                        debugPrint("Incomplete parameters")
                    }
                }
            }.resume()
        }
        else
        {
            if self.defaults.value(forKey: "callEvents") == nil{
                self.defaults.setValue("true", forKey: "callEvents")
                sendExceptionToServer(exceptionName: "User EventName or data is blank = \(data)", className: "Rest API", methodName: "callEvents", pid: userid, token: token , rid: "",cid : "")
            }
        }
    }
    
    // send user properties to server
    static func callUserProperties( data : NSString,userid : Int,token : String)
    {
        let isEnabled : Bool = UserDefaults.standard.bool(forKey: AppConstant.iZ_LOG_ENABLED)
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
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                if isEnabled {
                                    debugPrint(AppConstant.ADD_PROPERTIES)
                                }
                                sharedUserDefault?.set("", forKey:AppConstant.iZ_USERPROPERTIES_KEY)
                            }
                        }else{
                            if self.defaults.value(forKey: "callUserProperties") == nil{
                                self.defaults.setValue("true", forKey: "callUserProperties")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: "Rest API", methodName: "callUserProperties", pid: userid, token: token , rid: "",cid : "")
                            }
                        }
                    }
                } catch {
                    if self.defaults.value(forKey: "callUserProperties") == nil{
                        self.defaults.setValue("true", forKey: "callUserProperties")
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: "Rest API", methodName: "callUserProperties", pid: userid, token: token , rid: "",cid : "")
                    }
                    if isEnabled {
                        debugPrint("Server error")
                    }
                }
            }.resume()
        }
        else
        {
            if self.defaults.value(forKey: "callUserProperties") == nil{
                self.defaults.setValue("true", forKey: "callUserProperties")
                sendExceptionToServer(exceptionName: "User Properties data is null, \(data)", className: "Rest API", methodName: "callUserProperties", pid: userid, token: token , rid: "",cid : "")
            }
            if isEnabled {
                debugPrint("Data or UserId is missing\(data)")
            }
        }
    }
    
    // track the notification impression
    static func callImpression(notificationData : Payload,userid : Int,token : String, userInfo:[AnyHashable : Any] )
    {
        if notificationData.ankey != nil{
            if(notificationData.global?.rid != nil && userid != 0 && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                    URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                    URLQueryItem(name: "op", value: "view"),
                    URLQueryItem(name: "ver", value: SDKVERSION)
                ]
                var request = URLRequest(url: URL(string: "\(RestAPI.IMPRESSION_URL)")!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                let config = URLSessionConfiguration.default
                config.waitsForConnectivity = true
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                if let data = data {
                                    debugPrint("callImpression Success")
                                }
                            }else{
                                
                                if self.defaults.value(forKey: "callImpression") == nil{
                                    self.defaults.setValue("true", forKey: "callImpression")
                                    sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: "Rest API", methodName: "callImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                                }
                            }
                        }
                    } catch {
                        if self.defaults.value(forKey: "callImpression") == nil{
                            self.defaults.setValue("true", forKey: "callImpression")
                            sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: "Rest API", methodName: "callImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                        }
                    }
                }.resume()
            }
            else
            {
                if self.defaults.value(forKey: "callImpression") == nil{
                    self.defaults.setValue("true", forKey: "callImpression")
                    sendExceptionToServer(exceptionName: "RID or CID is null, \(userInfo)", className: "Rest API", methodName: "callImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                }
            }
        }else{
            if(notificationData.rid != nil && userid != 0 && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                    URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                    URLQueryItem(name: "op", value: "view"),
                    URLQueryItem(name: "ver", value: SDKVERSION)
                ]
                var request = URLRequest(url: URL(string: "\(RestAPI.IMPRESSION_URL)")!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                let config = URLSessionConfiguration.default
                config.waitsForConnectivity = true
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                if let data = data {
                                    debugPrint("callImpression Success")
                                }
                            }else{
                                if self.defaults.value(forKey: "callImpression") == nil{
                                    self.defaults.setValue("true", forKey: "callImpression")
                                    sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: "Rest API", methodName: "callImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                                }
                            }
                        }
                    } catch let error {
                        if self.defaults.value(forKey: "callImpression") == nil{
                            self.defaults.setValue("true", forKey: "callImpression")
                            sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: "Rest API", methodName: "callImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                        }
                    }
                }.resume()
            }
            else
            {
                if self.defaults.value(forKey: "callImpression") == nil{
                    self.defaults.setValue("true", forKey: "callImpression")
                    sendExceptionToServer(exceptionName: "RID or CID is null, \(userInfo)", className: "Rest API", methodName: "callImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                }
            }
        }
    }
    
    // track the notification click
    static func clickTrack(notificationData : Payload,type : String, userid : Int,token : String, userInfo:[AnyHashable : Any], globalLn: String, title: String)
    {
        var clickLn = ""
        if globalLn == ""{
            clickLn = notificationData.url ?? ""
        }else{
            clickLn = globalLn
        }
        
        if notificationData.ankey != nil{
            if(notificationData.global?.rid != nil && userid != 0 && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                
                if type != "0"{
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: "btn", value: "\(type)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                        URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                        URLQueryItem(name: "ti", value: "\(title)"),
                        URLQueryItem(name: "op", value: "click"),
                        URLQueryItem(name: "ver", value: SDKVERSION),
                        URLQueryItem(name: "ln", value: "\(clickLn)"),
                        URLQueryItem(name: "ap", value: "")
                    ]
                }else{
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                        URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                        URLQueryItem(name: "ti", value: "\(title)"),
                        URLQueryItem(name: "op", value: "click"),
                        URLQueryItem(name: "ver", value: SDKVERSION),
                        URLQueryItem(name: "ln", value: "\(clickLn)"),
                        URLQueryItem(name: "ap", value: "")
                    ]
                }
                let dict = ["pid": "\(userid)", "bKey": token, "cid":"\(notificationData.global?.id ?? "")" , "rid":"\(notificationData.global?.rid ?? "")", "ti":"\(title)", "op":"click", "ver": SDKVERSION, "btn": "\(type)"]
                var request = URLRequest(url: URL(string: RestAPI.CLICK_URL)!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                URLSession.shared.dataTask(with: request){(data,response,error) in
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                if let data = data {
                                    print("clickTrack received:", data)
                                    print("clickTrack Success")
                                }
                            }else{
                                if self.defaults.value(forKey: "clickTrack") == nil{
                                    self.defaults.setValue("true", forKey: "clickTrack")
                                    sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: "Rest API", methodName: "clickTrack", pid: userid, token: token , rid: notificationData.global?.rid ?? "no rid value here",cid : notificationData.global?.id ?? "no cid value here")
                                }
                            }
                        }
                    } catch let error{
                        self.clickStoreData.append(dict)
                        UserDefaults.standard.set(self.clickStoreData, forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
                        if self.defaults.value(forKey: "clickTrack") == nil{
                            self.defaults.setValue("true", forKey: "clickTrack")
                            sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: "Rest API", methodName: "clickTrack", pid: userid, token: token , rid: notificationData.global?.rid ?? "no rid value here",cid : notificationData.global?.id ?? "no cid value here")
                        }
                    }
                }.resume()
            }
            else
            {
                if self.defaults.value(forKey: "clickTrack") == nil{
                    self.defaults.setValue("true", forKey: "clickTrack")
                    sendExceptionToServer(exceptionName: "RID or CID is null, \(userInfo)", className: "Rest API", methodName: "clickTrack", pid: userid, token: token , rid: notificationData.global?.rid ?? "no rid value here",cid : notificationData.global?.id ?? "no cid value here")
                }
            }
        }else{
            if(notificationData.rid != nil && userid != 0 && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                
                if type != "0"{
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: "btn", value: "\(type)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                        URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                        URLQueryItem(name: "ti", value: "\(title)"),
                        URLQueryItem(name: "op", value: "click"),
                        URLQueryItem(name: "ver", value: SDKVERSION),
                        URLQueryItem(name: "ln", value: "\(clickLn)"),
                        URLQueryItem(name: "ap", value: "\(String(describing: notificationData.ap ?? ""))")
                    ]
                }else{
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                        URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                        URLQueryItem(name: "ti", value: "\(title)"),
                        URLQueryItem(name: "op", value: "click"),
                        URLQueryItem(name: "ver", value: SDKVERSION),
                        URLQueryItem(name: "ln", value: "\(clickLn)"),
                        URLQueryItem(name: "ap", value: "\(String(describing: notificationData.ap ?? ""))")
                    ]
                }
                let dict = ["pid": "\(userid)", "bKey": token, "cid":"\(notificationData.id ?? "")" , "rid":"\(notificationData.rid ?? "")", "ti":"\(title)", "op":"click", "ver": SDKVERSION, "btn": "\(type)"]
                
                var request = URLRequest(url: URL(string: RestAPI.CLICK_URL)!)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                URLSession.shared.dataTask(with: request){(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                if let data = data {
                                    print("clickTrack received:", data)
                                    print("clickTrack Success")
                                }
                            }else{
                                if self.defaults.value(forKey: "clickTrack") == nil{
                                    self.defaults.setValue("true", forKey: "clickTrack")
                                    sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: "Rest API", methodName: "clickTrack", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                                }
                            }
                        }
                    } catch let error{
                        self.clickStoreData.append(dict)
                        UserDefaults.standard.set(self.clickStoreData, forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
                        if self.defaults.value(forKey: "clickTrack") == nil{
                            self.defaults.setValue("true", forKey: "clickTrack")
                            sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: "Rest API", methodName: "clickTrack", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                        }
                    }
                }.resume()
            }
            else
            {
                if self.defaults.value(forKey: "clickTrack") == nil{
                    self.defaults.setValue("true", forKey: "clickTrack")
                    sendExceptionToServer(exceptionName: "RID or CID is blank, \(userInfo)", className: "Rest API", methodName: "clickTrack", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                }
            }
        }
    }
    
    static func offlineClickTrackCall(){
        
        if let dd = UserDefaults.standard.value(forKey: AppConstant.iZ_CLICK_OFFLINE_DATA) as? [[String : Any]]{
            var tempArray: [[String:Any]] = []
            for dict in dd{
                tempArray = dd
                let data = dict as? NSDictionary
                
                self.clickOfflineTrack(pid: data?.value(forKey: "pid") as? String ?? "", cid: data?.value(forKey: "cid") as? String ?? "", rid: data?.value(forKey: "rid") as? String ?? "", ver: data?.value(forKey: "ver") as? String ?? "", btn: data?.value(forKey: "btn") as? String ?? "", bKey: data?.value(forKey: "bKey") as? String ?? "", title: data?.value(forKey: "ti") as? String ?? "")
            }
            tempArray.removeAll()
            UserDefaults.standard.set(tempArray, forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
            self.clickStoreData.removeAll()
        }
    }
    
    static func mediationOfflineClickTrackCall(){
        if let dd = UserDefaults.standard.value(forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA) as? [[String : Any]]{
            var tempArray: [[String:Any]] = []
            tempArray = dd
            for dict in dd{
                let data = dict as? NSDictionary
                self.callAdMediationClickApi(finalDict: data!)
            }
            tempArray.removeAll()
            UserDefaults.standard.set(tempArray, forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
            self.mediationClickStoreData.removeAll()
        }
    }
    
    //Offline click track
    static func clickOfflineTrack(pid: String, cid: String, rid: String, ver: String, btn: String , bKey : String, title: String)
    {
        if(rid != "" && pid != "" && bKey != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: bKey),
                URLQueryItem(name: "cid", value: "\(cid)"),
                URLQueryItem(name: "rid", value: "\(rid)"),
                URLQueryItem(name: "ti", value: "\(title)"),
                URLQueryItem(name: "op", value: "click"),
                URLQueryItem(name: "ver", value: ver),
                URLQueryItem(name: "btn", value: "\(btn)")
            ]
            var request = URLRequest(url: URL(string: RestAPI.CLICK_URL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                print("clickTrack received:", data)
                                print("clickTrack Success")
                            }
                        }else{
                            if self.defaults.value(forKey: "clickTrack") == nil{
                                self.defaults.setValue("true", forKey: "clickTrack")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: "Rest API", methodName: "clickTrackOffline", pid: Int(pid) ?? 0, token: bKey , rid: rid, cid :"")
                            }
                        }
                    }
                } catch {
                    if self.defaults.value(forKey: "clickTrack") == nil{
                        self.defaults.setValue("true", forKey: "clickTrack")
                        sendExceptionToServer(exceptionName: "Error = \(error.localizedDescription)", className: "Rest API", methodName: "clickTrackOffline", pid: Int(pid) ?? 0, token: bKey , rid: rid, cid :"")
                    }
                }
            }.resume()
        }
        else
        {
            if self.defaults.value(forKey: "clickTrack") == nil{
                self.defaults.setValue("true", forKey: "clickTrack")
                sendExceptionToServer(exceptionName: "rid not found", className: "Rest API", methodName: "clickTrackOffline", pid: Int(pid) ?? 0, token: bKey , rid: rid, cid :"")
            }
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
                let config = URLSessionConfiguration.default
                config.waitsForConnectivity = true
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                if let data = data {
                                    debugPrint("lastVisit Success")
                                }
                            }else{
                                if self.defaults.value(forKey: "lastVisit") == nil{
                                    self.defaults.setValue("true", forKey: "lastVisit")
                                    sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastVisit", pid: userid, token: token , rid: "",cid :"")
                                }
                            }
                        }
                    } catch {
                        if self.defaults.value(forKey: "lastVisit") == nil{
                            self.defaults.setValue("true", forKey: "lastVisit")
                            sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastVisit", pid: userid, token: token , rid: "",cid :"")
                        }
                    }
                }.resume()
            }
            else
            {
                if self.defaults.value(forKey: "lastVisit") == nil{
                    self.defaults.setValue("true", forKey: "lastVisit")
                    sendExceptionToServer(exceptionName: "Json data validation failed, \(data)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastVisit", pid: userid, token: token , rid: "",cid :"")
                }
            }
        }
        else
        {
            if self.defaults.value(forKey: "lastVisit") == nil{
                self.defaults.setValue("true", forKey: "lastVisit")
                sendExceptionToServer(exceptionName: "UserId not found", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastVisit", pid: userid, token: token , rid: "",cid :"")
            }
        }
    }
    // last impression send to server
    @objc static func lastImpression(notificationData : Payload,userid : Int,token : String,url : String, userInfo: [AnyHashable: Any])
    {
        if(notificationData.rid != nil && userid != 0 && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                URLQueryItem(name: "op", value: "view")
            ]
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                debugPrint("lastImpression Success")
                            }
                        }else{
                            if self.defaults.value(forKey: "lastImpression") == nil{
                                self.defaults.setValue("true", forKey: "lastImpression")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                            }
                        }
                    }
                } catch {
                    if self.defaults.value(forKey: "lastImpression") == nil{
                        self.defaults.setValue("true", forKey: "lastImpression")
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                    }
                }
            }.resume()
        }
        else
        {
            if self.defaults.value(forKey: "lastImpression") == nil{
                self.defaults.setValue("true", forKey: "lastImpression")
                sendExceptionToServer(exceptionName: "UserId or rid is null, \(userInfo)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
            }
        }
    }
    
    // last click data send to server
    @objc static func lastClick(notificationData : Payload,userid : Int,token : String,url : String, userInfo: [AnyHashable: Any])
    {
        if(userid != 0 && token != "" && notificationData.rid != nil)
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(userid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                URLQueryItem(name: "op", value: "view")
            ]
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                debugPrint("LastClick Success")
                            }
                        }else{
                            
                            if self.defaults.value(forKey: "lastClick") == nil{
                                self.defaults.setValue("true", forKey: "lastClick")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                            }
                        }
                    }
                    
                } catch {
                    if self.defaults.value(forKey: "lastClick") == nil{
                        self.defaults.setValue("true", forKey: "lastClick")
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                    }
                }
            }.resume()
        }
        else
        {
            if self.defaults.value(forKey: "lastClick") == nil{
                self.defaults.setValue("true", forKey: "lastClick")
                sendExceptionToServer(exceptionName: "Error in userId or rid, \(userInfo)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick", pid: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
            }
        }
    }
    
    // register the token on our panel
    @objc static func registerToken(token : String, izootoid : Int)
    {
        let isEnabled = UserDefaults.standard.bool(forKey: AppConstant.iZ_LOG_ENABLED)
        if(token != "" && izootoid != 0)
        {
            let defaults = UserDefaults.standard
            defaults.setValue(izootoid, forKey: AppConstant.iZ_PID)
            defaults.setValue(token, forKey: "token")
            let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems =
            [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(izootoid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: "8"),
                URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: "3"),
                URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(Utils.currentTimeInMilliSeconds())"),
                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(Utils.getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: "5"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: identifierForAdvertising()!),
                URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(Utils.getVersion())"),
                URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(Utils.getDeviceName())"),
                URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(Utils.getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: "\(pluginVersion)")
            ]
            var request = URLRequest(url: URL(string: RestAPI.BASEURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
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
                        }else{
                            if self.defaults.value(forKey: "registerTokennss") == nil{
                                self.defaults.setValue("true", forKey: "registerTokennss")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, pid: izootoid, token: token, rid: "", cid: "")
                            }
                            if isEnabled{
                                debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR)
                            }
                        }
                    }
                } catch {
                    if self.defaults.value(forKey: "registerTokennss") == nil{
                        self.defaults.setValue("true", forKey: "registerTokennss")
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, pid: izootoid, token: token, rid: "", cid: "")
                    }
                    if isEnabled{
                        debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR)
                    }
                }
            }.resume()
        }
        else
        {
            if self.defaults.value(forKey: "registerTokennss") == nil{
                self.defaults.setValue("true", forKey: "registerTokennss")
                sendExceptionToServer(exceptionName: AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, pid: 0, token: "", rid: "", cid: "")
            }
            if isEnabled{
                print(AppConstant.IZ_TAG,AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR)
            }
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
                URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(Utils.currentTimeInMilliSeconds())"),
                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(Utils.getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: "5"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: identifierForAdvertising()!),
                URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(Utils.getVersion())"),
                URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(Utils.getDeviceName())"),
                URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(Utils.getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: "\(pluginVersion)")
                
            ]
            var request = URLRequest(url: URL(string: RestAPI.BASEURL)!)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            if let data = data {
                                let isEnabled : Bool = UserDefaults.standard.bool(forKey: AppConstant.iZ_LOG_ENABLED)
                                if isEnabled {
                                    print("\(AppConstant.iZ_KEY_ADVERTISEMENT_ID) Success")
                                }
                                sharedUserDefault?.set(true,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                                sharedUserDefault?.set("", forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID_)
                            }
                        }else{
                            if self.defaults.value(forKey: "registerToken") == nil{
                                self.defaults.setValue("true", forKey: "registerToken")
                                sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, pid: izootoid, token: token, rid: "", cid: "")
                            }
                        }
                    }
                    
                } catch {
                    if self.defaults.value(forKey: "registerToken") == nil{
                        self.defaults.setValue("true", forKey: "registerToken")
                        sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, pid: izootoid, token: token, rid: "", cid: "")
                    }
                }
            }.resume()
        }
        else
        {
            if self.defaults.value(forKey: "registerToken") == nil{
                self.defaults.setValue("true", forKey: "registerToken")
                sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                sendExceptionToServer(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, pid: 0, token: "", rid: "", cid: "")
            }
        }
    }
    
    // send exception to the server
    @objc static func sendExceptionToServer(exceptionName : String ,className : String ,methodName: String,pid :Int ,token : String,rid : String,cid : String)
    {
        let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""
        let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(pid)"),
                                            URLQueryItem(name: "exceptionName", value: "\(exceptionName)"),
                                            URLQueryItem(name: "methodName", value: "\(methodName)"),
                                            URLQueryItem(name: "className", value:"\(className)"),
                                            URLQueryItem(name: "bKey", value: token),
                                            URLQueryItem(name: "av", value: SDKVERSION),
                                            URLQueryItem(name: "rid", value: "\(rid)"),
                                            URLQueryItem(name: "cid", value: "\(cid)"),
                                            URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: "\(pluginVersion)"),
                                            URLQueryItem(name: "osVersion", value: "\(Utils.getVersion())"),
                                            URLQueryItem(name: "deviceName", value: "\(Utils.getDeviceName())"),
                                            URLQueryItem(name: "appVersion", value: "\(Utils.getAppVersion())")]
        var request = URLRequest(url: URL(string: RestAPI.EXCEPTION_URL)!)
        request.httpMethod = AppConstant.iZ_POST_REQUEST
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
            
            do {
                if let error = error {
                    throw error
                }
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        debugPrint("Success")
                    }else{
                        throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: nil)
                    }
                }
            } catch {
                print("Error:", error)
            }
        }.resume()
    }
    
    //Ad-Mediation Impression
    @objc static func callAdMediationImpressionApi(finalDict: NSDictionary){
        
        let defaults = UserDefaults.standard
        let pid = defaults.integer(forKey: AppConstant.iZ_PID)
        let token = defaults.string(forKey: "token")
        
        if (finalDict.count != 0) {
            let rid = finalDict.value(forKey: "rid") as? String
            let jsonData = try? JSONSerialization.data(withJSONObject: finalDict as? [String: Any])
            let url = URL(string: "\(MEDIATION_IMPRESSION_URL)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "\(AppConstant.iZ_CONTENT_TYPE)")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true
            URLSession(configuration: config).dataTask(with: request) {data,response,error in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            debugPrint("Mediation Impression Success")
                        }else{
                            if defaults.value(forKey: "adImpression") == nil{
                                defaults.setValue("true", forKey: "adImpression")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Impression API", pid: pid, token: token ?? "", rid: rid ?? "" , cid: "")
                            }
                        }
                    }
                } catch {
                    if defaults.value(forKey: "adImpression") == nil{
                        defaults.setValue("true", forKey: "adImpression")
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "CallAdMediationImpressionApi", pid: pid , token: token ?? "", rid: rid ?? "", cid: "")
                    }
                }
            }.resume()
        }else{
            if defaults.value(forKey: "adImpression") == nil{
                defaults.setValue("true", forKey: "adImpression")
                sendExceptionToServer(exceptionName: "key's are blank in request parameter,\(finalDict) ", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Impression API", pid: pid, token: token ?? "", rid: "", cid: "")
            }
        }
    }
    
    //Ad-Mediation ClickAPI
    @objc static func callAdMediationClickApi(finalDict: NSDictionary){
        
        let defaults = UserDefaults.standard
        let pid = defaults.integer(forKey: AppConstant.iZ_PID)
        let token = defaults.string(forKey: "token")
        
        print(finalDict)
        
        if (finalDict.count != 0) {
            let rid = finalDict.value(forKey: "rid") as? String
            let jsonData = try? JSONSerialization.data(withJSONObject: finalDict)
            let url = URL(string: "\(MEDIATION_CLICK_URL)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            URLSession.shared.dataTask(with: request){(data,response,error) in
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            debugPrint("Mediation Impression Success")
                            
                        }else{
                            if self.defaults.value(forKey: "adClick") == nil{
                                self.defaults.setValue("true", forKey: "adClick")
                                sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API", pid: pid, token: token ?? "", rid: rid ?? "", cid: "")
                            }
                        }
                    }
                } catch {
                    
                    self.mediationClickStoreData.append(finalDict as! [String : Any])
                    UserDefaults.standard.set(self.mediationClickStoreData, forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
                    if self.defaults.value(forKey: "adClick") == nil{
                        self.defaults.setValue("true", forKey: "adClick")
                        sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API", pid: pid, token: token ?? "", rid: rid ?? "", cid: "")
                    }
                }
            }.resume()
        }else{
            if self.defaults.value(forKey: "adClick") == nil{
                self.defaults.setValue("true", forKey: "adClick")
                sendExceptionToServer(exceptionName: "key's are blank in request parameter, \(finalDict)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API", pid: pid, token: token ?? "", rid: "", cid: "")
            }
        }
    }
    
    static func callRV_RC_Request( urlString : String)
    {
        let pid = UserDefaults.standard.integer(forKey: AppConstant.iZ_PID)
        let token = UserDefaults.standard.string(forKey: "token")
        if urlString.contains("https"){
            // create post request
            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                
                let config = URLSessionConfiguration.default
                config.waitsForConnectivity = true
                URLSession(configuration: config).dataTask(with: request) { data, response, error in
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                debugPrint("callRV_RC_Request Success")
                            }else{
                                if self.defaults.value(forKey: "callRV_RC_Request") == nil{
                                    self.defaults.setValue("true", forKey: "callRV_RC_Request")
                                    sendExceptionToServer(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callRV_RC_Request", pid: pid, token: token ?? "", rid: "", cid: "")
                                }
                            }
                        }
                    } catch {
                        if self.defaults.value(forKey: "callRV_RC_Request") == nil{
                            self.defaults.setValue("true", forKey: "callRV_RC_Request")
                            sendExceptionToServer(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callRV_RC_Request", pid: pid, token: token ?? "", rid: "", cid: "")
                        }
                    }
                }.resume()
            }
        }else{
            if self.defaults.value(forKey: "callRV_RC_Request") == nil{
                self.defaults.setValue("true", forKey: "callRV_RC_Request")
                sendExceptionToServer(exceptionName: "Url is not in correct format = \(urlString)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callRV_RC_Request", pid: pid, token: token ?? "", rid: "", cid: "")
            }
        }
    }
    
    //All Notification Data
    @objc static func fetchDataFromAPI(isPagination: Bool,iZPID: String,completion: @escaping (String?, Error?) -> Void) {
        
        if isPagination == false{
            index = 0
        }
        if index > 4{
            completion("No more data",nil)
            return
        }
        var arrayOfDictionaries : [[String: Any]] = []
        let sID = iZPID.sha1()
        let url = URL(string: RestAPI.ALL_NOTIFICATION_DATA+"\(sID)/\(index).json")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                debugPrint("\(error)")
                completion("No more data", nil)
                return
            }
            // Convert HTTP Response Data to a String
            if let data = data {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    for data in jsonResponse as! NSArray {
                        if let dictDa = data as? NSDictionary {
                            let allData = dictDa.value(forKey: AppConstant.iZ_P_KEY) as? NSDictionary
                            let title = allData?.value(forKey: AppConstant.iZ_T_KEY) ?? ""
                            let message = allData?.value(forKey: AppConstant.iZ_M_KEY) ?? ""
                            let image = allData?.value(forKey: AppConstant.iZ_BI_KEY) ?? ""
                            let time = allData?.value(forKey: AppConstant.iZ_CT_KEY) ?? ""
                            let ln = allData?.value(forKey: AppConstant.iZ_LNKEY) ?? ""
                            let dictionary1: [String: Any] = ["title": title, "message": message, "banner_image": image, "time_stamp": time,"landing_url": ln]
                            arrayOfDictionaries.append(dictionary1)
                        }
                    }
                    
                    if arrayOfDictionaries.count != 15{
                        if lessData == 1{
                            stopCalling = true
                        }
                        lessData = 1
                        index = index
                    }else{
                        lessData = 0
                        stopCalling = false
                        index = index + 1
                    }
                    
                    if stopCalling == false{
                        let jsonData = try JSONSerialization.data(withJSONObject: arrayOfDictionaries, options: .prettyPrinted)
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            completion(jsonString, nil)
                            return
                        }
                    }else{
                        completion("No more data", nil)
                        return
                    }
                }
                catch let error
                {
                    completion("No more data", nil)
                    print(error)
                    return
                    
                }
            }
        }
        task.resume()
    }
    
    // get App version
    static func getAppVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        // print(version)
        return "\(version)"
    }
    
    public static func getBundleName()->String
    {
        let bundleID = Bundle.main.bundleIdentifier
        return "group."+bundleID! + ".iZooto"
    }
}





