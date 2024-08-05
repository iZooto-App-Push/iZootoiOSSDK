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
import os.log


protocol ResponseHandler  : AnyObject{
    func onSuccess()
    func onFailure()
}
// Define custom error types
enum DataConversionError: Error {
    case encodingFailed
}

enum DataError: Error {
    case noData
}
@objc
public class RestAPI : NSObject
{
    //******** Live *******
    // url for prod
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
    static let SDKVERSION = "2.3.3"
    //fallback url
    static let FALLBACK_URL = "https://flbk.izooto.com/default.json"
    static var fallBackLandingUrl = ""
    
    // email capture api
    static var EMAIL_CAPTURE_API = "https://eenp.izooto.com/eenp"
    //All notification Data
    static let ALL_NOTIFICATION_DATA = "https://nh.iz.do/nh/"
    static var index = 0
    static var stopCalling = false
    static var lessData = 0
    static var fallBackTitle = ""
    static let defaults = UserDefaults.standard
    private static var clickStoreData: [[String:Any]] = []
    private static var mediationClickStoreData: [[String:Any]] = []
    
    static var tag_name = "RestAPI"
    
    
    public static func getRequest(uuid: String, completionBlock: @escaping (String) -> Void) -> Void
    {
        if uuid != "" {
            if let requestURL = URL(string: "\(ENCRPTIONURL)\(uuid).dat"){
                var request = URLRequest(url: requestURL)
                request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
                let config = URLSessionConfiguration.default
                if #available(iOS 11.0, *) {
                    config.waitsForConnectivity = true
                } else {
                    // Fallback on earlier versions
                }
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    if(error != nil) {
                        Utils.handleOnceException(exceptionName: error?.localizedDescription ?? "no found", className: tag_name, methodName: "getRequest", rid: "", cid: "")
                        print(AppConstant.IZ_TAG,AppConstant.APP_ID_ERROR)
                        
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
                                do {
                                    if let data = data {
                                        guard let outputStr = String(data: data, encoding: .utf8) else {
                                            throw DataConversionError.encodingFailed
                                        }
                                        completionBlock(outputStr)
                                    } else {
                                        throw DataError.noData
                                    }
                                } catch DataConversionError.encodingFailed {
                                    print("Failed to encode data to a string.")
                                    // Handle encoding error here
                                    completionBlock("Encoding error occurred.")
                                } catch DataError.noData {
                                    // Handle no data error here
                                    completionBlock("No data error occurred.")
                                } catch {
                                    print("An unexpected error occurred: \(error.localizedDescription)")
                                    // Handle any other unexpected errors here
                                    completionBlock("Unexpected error occurred.")
                                }
                            }
                            else
                            {
                                Utils.handleOnceException(exceptionName: "response error generated\(uuid)", className: tag_name, methodName: "getRequest", rid: "", cid: "")
                            }
                        }
                    }
                }.resume()
            }
        }else{
            Utils.handleOnceException(exceptionName: "iZooto app id is blank or null", className: tag_name, methodName: "getRequest", rid: "", cid: "")
        }
    }
    
    
    
    // send event to server
    static func callEvents(eventName : String, data : NSString,pid : String,token : String)
    {
        if( eventName != ""  && data != "" && pid != ""){
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "act", value: "\(eventName)"),
                URLQueryItem(name: "et", value: "evt"),
                URLQueryItem(name: "val", value: "\(data)")
            ]
            guard let url = URL(string: RestAPI.EVENT_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            if #available(iOS 11.0, *) {
                config.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            sharedUserDefault?.set("", forKey:AppConstant.KEY_EVENT)
                            sharedUserDefault?.set("", forKey: AppConstant.KEY_EVENT_NAME)
                            
                        }else{
                            Utils.handleOnceException(exceptionName: error?.localizedDescription ?? "Error code" , className: tag_name, methodName: "callEvents",  rid: "", cid: "")
                        }
                    }
                } catch {
                    Utils.handleOnceException(exceptionName: error.localizedDescription , className: tag_name, methodName: "callEvents",rid: "", cid: "")
                    
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: "user id or event data is null" , className: tag_name, methodName: "callEvents",  rid: "", cid: "")
        }
    }
    
    // send user properties to server
    static func callUserProperties( data : NSString,pid : String,token : String)
    {
        if( data != ""  && pid != ""){
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "act", value: "add"),
                URLQueryItem(name: "et", value: "userp"),
                URLQueryItem(name: "val", value: "\(data)")
            ]
            guard let url = URL(string: RestAPI.PROPERTIES_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            if #available(iOS 11.0, *) {
                config.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            sharedUserDefault?.set("", forKey:AppConstant.iZ_USERPROPERTIES_KEY)
                        }else{
                            Utils.handleOnceException(exceptionName:  "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")" , className: tag_name, methodName: "callUserProperties", rid: "", cid: "")
                            
                        }
                    }
                } catch {
                    Utils.handleOnceException(exceptionName:  "" , className: tag_name, methodName: "callUserProperties", rid: "", cid: "")
                    
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName:  "User Properties data is blank" , className: tag_name, methodName: "callUserProperties",  rid: "", cid: "")
            
        }
    }
    
    // track the notification impression
    static func callImpression(notificationData : Payload,pid : String,token : String)
    {
        if notificationData.ankey != nil{
            if(notificationData.global?.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                    URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                    URLQueryItem(name: "op", value: "view"),
                    URLQueryItem(name: "ver", value: SDKVERSION)
                ]
                
                guard let url = URL(string: RestAPI.IMPRESSION_URL) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                let config = URLSessionConfiguration.default
                if #available(iOS 11.0, *) {
                    config.waitsForConnectivity = true
                } else {
                    // Fallback on earlier versions
                }
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
//                                debugPrint("callImpression Success")
                            }else{
                                
                                Utils.handleOnceException(exceptionName:  "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")" , className: tag_name, methodName: "callImpression",  rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                            }
                        }
                    } catch {
                        Utils.handleOnceException(exceptionName:  "\(error.localizedDescription)" , className: tag_name, methodName: "callImpression", rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName:  "rid or cid value is  blank" , className: tag_name, methodName: "callImpression",  rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
            }
        }else{
            if(notificationData.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                    URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                    URLQueryItem(name: "op", value: "view"),
                    URLQueryItem(name: "ver", value: SDKVERSION)
                ]
                
                guard let url = URL(string: RestAPI.IMPRESSION_URL) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                let config = URLSessionConfiguration.default
                if #available(iOS 11.0, *) {
                    config.waitsForConnectivity = true
                } else {
                    // Fallback on earlier versions
                }
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                               // debugPrint("callImpression Success")
                                
                            }else{
                                Utils.handleOnceException(exceptionName:  error?.localizedDescription ?? "Error code " , className: tag_name, methodName: "callImpression",rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                                
                            }
                        }
                    } catch let error {
                        Utils.handleOnceException(exceptionName:  error.localizedDescription, className: tag_name, methodName: "callImpression",  rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName:  "rid or cid value is blank" , className: tag_name, methodName: "callImpression",  rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
            }
        }
    }
    
    // track the notification click
    static func clickTrack(notificationData : Payload,type : String, pid : String,token : String, userInfo:[AnyHashable : Any], globalLn: String, title: String)
    {
        var clickLn = ""
        if globalLn == ""{
            clickLn = notificationData.url ?? ""
        }else{
            clickLn = globalLn
        }
        
        if notificationData.ankey != nil{
            if(notificationData.global?.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                
                if type != "0"{
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: "btn", value: "\(type)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                        URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                        URLQueryItem(name: "op", value: "click"),
                        URLQueryItem(name: "ver", value: SDKVERSION),
                        URLQueryItem(name: "ln", value: "\(clickLn)"),
                        URLQueryItem(name: "ap", value: ""),
                        URLQueryItem(name:"ti",value: "\(title)")
                        
                    ]
                }else{
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(String(describing: notificationData.global?.id ?? ""))"),
                        URLQueryItem(name: "rid", value: "\(String(describing: notificationData.global?.rid ?? ""))"),
                        URLQueryItem(name: "ti", value: "\(title)"),
                        URLQueryItem(name: "op", value: "click"),
                        URLQueryItem(name: "ver", value: SDKVERSION),
                        URLQueryItem(name: "ln", value: "\(clickLn)"),
                        URLQueryItem(name: "ap", value: ""),
                    ]
                }
                let dict = ["pid": "\(pid)", "bKey": token, "cid":"\(notificationData.global?.id ?? "")" , "rid":"\(notificationData.global?.rid ?? "")", "ti":"\(title)", "op":"click", "ver": SDKVERSION, "btn": "\(type)"]
                guard let url = URL(string: RestAPI.CLICK_URL) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                var request = URLRequest(url: url)
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
                               // print("Click sucess")
                                
                            }else{
                                Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")" , className: tag_name, methodName: "clickTrack", rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                            }
                        }
                    } catch let error{
                        self.clickStoreData.append(dict)
                        UserDefaults.standard.set(self.clickStoreData, forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
                        Utils.handleOnceException(exceptionName: "\(error.localizedDescription)" , className: tag_name, methodName: "clickTrack",  rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName: "rid or cid value is blank" , className: tag_name, methodName: "clickTrack",  rid: notificationData.global?.rid ?? "no rid value here", cid: notificationData.global?.id ?? "no cid value here")
            }
        }else{
            if(notificationData.rid != nil && pid != "" && token != "")
            {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                
                if type != "0"{
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: "btn", value: "\(type)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                        URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                        URLQueryItem(name: "op", value: "click"),
                        URLQueryItem(name: "ver", value: SDKVERSION),
                        URLQueryItem(name: "ln", value: "\(clickLn)"),
                        URLQueryItem(name: "ti", value: "\(title)"),
                    ]
                }else{
                    requestBodyComponents.queryItems = [
                        URLQueryItem(name: "ti", value: "\(title)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                        URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                        URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                        URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                        URLQueryItem(name: "op", value: "click"),
                        URLQueryItem(name: "ver", value: SDKVERSION),
                        URLQueryItem(name: "ln", value: "\(clickLn)"),
                        URLQueryItem(name: "ap", value: "\(String(describing: notificationData.ap ?? ""))"),

                    ]
                }
                let dict = ["pid": "\(pid)", "bKey": token, "cid":"\(notificationData.id ?? "")" , "rid":"\(notificationData.rid ?? "")", "ti":"\(title)", "op":"click", "ver": SDKVERSION, "btn": "\(type)","ln":"\(clickLn)"]
                
                guard let url = URL(string: RestAPI.CLICK_URL) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                var request = URLRequest(url: url)
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
                               // print("Click sucess")
                            }else{
                                Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "clickTrack", rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                            }
                        }
                    } catch let error{
                        self.clickStoreData.append(dict)
                        UserDefaults.standard.set(self.clickStoreData, forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
                        Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: tag_name, methodName: "clickTrack", rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                        
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName: "rid or cid value is blank", className: tag_name, methodName: "clickTrack", rid: notificationData.rid ?? "no rid value here", cid: notificationData.id ?? "no cid value here")
                
            }
        }
    }
    
    static func offlineClickTrackCall(){
        
        if let dd = UserDefaults.standard.value(forKey: AppConstant.iZ_CLICK_OFFLINE_DATA) as? [[String : Any]]{
            var tempArray: [[String:Any]] = []
            for dict in dd{
                tempArray = dd
                let data = dict as? NSDictionary
                
                self.clickOfflineTrack(pid: data?.value(forKey: "pid") as? String ?? "", cid: data?.value(forKey: "cid") as? String ?? "", rid: data?.value(forKey: "rid") as? String ?? "", ver: data?.value(forKey: "ver") as? String ?? "", btn: data?.value(forKey: "btn") as? String ?? "", token: data?.value(forKey: "bKey") as? String ?? "", title: data?.value(forKey: "ti") as? String ?? "",ln: data?.value(forKey: "ln") as? String ?? "")
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
                if let data = dict as? NSDictionary {
                    self.callAdMediationClickApi(finalDict: data)
                }
            }
            tempArray.removeAll()
            UserDefaults.standard.set(tempArray, forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
            self.mediationClickStoreData.removeAll()
        }
    }
    
    //Offline click track
    static func clickOfflineTrack(pid: String, cid: String, rid: String, ver: String, btn: String , token : String, title: String,ln :String)
    {
        if(rid != "" && pid != "" && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: "\(cid)"),
                URLQueryItem(name: "rid", value: "\(rid)"),
                URLQueryItem(name: "ti", value: "\(title)"),
                URLQueryItem(name: "ln", value: "\(ln)"),
                URLQueryItem(name: "op", value: "click"),
                URLQueryItem(name: "ver", value: ver),
                URLQueryItem(name: "btn", value: "\(btn)")
            ]
            guard let url = URL(string: RestAPI.CLICK_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
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
                        }else{
                            Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "clickTrackOffline", rid:"", cid: "")
                        }
                    }
                } catch {
                    Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: tag_name, methodName: "clickTrackOffline", rid:"", cid: "")
                    
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: "rid or pid or token is blank", className: tag_name, methodName: "clickTrackOffline", rid:"", cid: "")
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
    @objc static func lastVisit(pid : String,token : String)
    {
        if(token != "" && pid != "")
        {
            let data = ["last_website_visit":"true","lang":"en"] as [String:String]
            if let theJSONData = try?  JSONSerialization.data(withJSONObject: data,options: .fragmentsAllowed),
               let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue) {
                let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
                var requestBodyComponents = URLComponents()
                requestBodyComponents.queryItems = [
                    URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                    URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                    URLQueryItem(name: "act", value: "add"),
                    URLQueryItem(name: "isid", value: "1"),
                    URLQueryItem(name: "et", value: "userp"),
                    URLQueryItem(name: "val", value: "\(validationData)")
                ]
                
                guard let url = URL(string: RestAPI.LASTVISITURL) else {
                    // Handle the case where the URL is nil
                    print("Error: Invalid URL")
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.allHTTPHeaderFields = requestHeaders
                request.httpBody = requestBodyComponents.query?.data(using: .utf8)
                let config = URLSessionConfiguration.default
                if #available(iOS 11.0, *) {
                    config.waitsForConnectivity = true
                } else {
                    // Fallback on earlier versions
                }
                URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                    
                    do {
                        if let error = error {
                            throw error
                        }
                        // Check the HTTP response status code
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
//                                print("LastVisit successfully")
                                
                            }else{
                                Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "lastVisit" , rid: "",cid :"")
                            }
                        }
                    } catch {
                        Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: tag_name, methodName: "lastVisit" , rid: "",cid :"")
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(exceptionName: "json is not correct", className: tag_name, methodName: "lastVisit" , rid: "",cid :"")
            }
        }
        else
        {
            Utils.handleOnceException(exceptionName: "pid is not found", className: tag_name, methodName: "lastVisit" , rid: "",cid :"")
        }
    }
    // last impression send to server
    @objc static func lastImpression(notificationData : Payload,pid : String,token : String,url : String)
    {
        if(notificationData.rid != nil && pid != "" && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                URLQueryItem(name: "op", value: "view")
            ]
            guard let url = URL(string: url) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            if #available(iOS 11.0, *) {
                config.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            print("Last impression successfully")
                            
                        }else{
                            Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                        }
                    }
                } catch {
                    Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: "rid value is blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
        }
    }
    
    // last click data send to server
    @objc static func lastClick(notificationData : Payload,pid : String,token : String,url : String, userInfo: [AnyHashable: Any])
    {
        if(pid != "" && token != "" && notificationData.rid != nil)
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: "\(notificationData.id ?? "")"),
                URLQueryItem(name: "rid", value: "\(notificationData.rid ?? "")"),
                URLQueryItem(name: "op", value: "view")
            ]
            
            guard let url = URL(string: url) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            if #available(iOS 11.0, *) {
                config.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                           // print("LastClick Success")
                        }else{
                            Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                        }
                    }
                    
                } catch {
                    Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: "rid value is blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
        }
    }
    
    // register the token on our panel
    @objc static func registerToken(token : String, pid : String)
    {
        if(token != "" && pid != "")
        {
            let defaults = UserDefaults.standard
            defaults.setValue(pid, forKey: AppConstant.iZ_PID)
            defaults.setValue(token, forKey: "token")
            let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems =
            [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: AppConstant.IZ_BTYPE),
                URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: AppConstant.IZ_DTYPE),
                URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(Utils.currentTimeInMilliSeconds())"),
                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(Utils.getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: AppConstant.IZ_OS_TYPE),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: identifierForAdvertising()),
                URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(Utils.getVersion())"),
                URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(Utils.getDeviceName())"),
                URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(Utils.getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: "\(pluginVersion)")
            ]
            
            guard let url = URL(string: RestAPI.BASEURL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            if #available(iOS 11.0, *) {
                config.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            print(AppConstant.DEVICE_TOKEN,token)
                            UserDefaults.isRegistered(isRegister: true)
                            print(AppConstant.SUCESSFULLY)
                            
                            let date = Date()
                            let format = DateFormatter()
                            format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                            let formattedDate = format.string(from: date)
                            if(formattedDate != (sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_LAST_VISIT)))
                            {
                                RestAPI.lastVisit(pid: pid, token:token)
                                sharedUserDefault?.set(formattedDate, forKey: AppConstant.iZ_KEY_LAST_VISIT)
                                let dicData = sharedUserDefault?.dictionary(forKey:AppConstant.iZ_USERPROPERTIES_KEY)
                                if(dicData != nil)
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                        iZooto.addUserProperties(data: dicData!)
                                    }
                                }
                            }
                            
                        }else{
                            Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: "", cid: "")
                            print(AppConstant.IZ_TAG,AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR)
                            
                        }
                    }
                } catch {
                    Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: "", cid: "")
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: "pid or token is not generated", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: "", cid: "")
        }
    }
    
    // send the token with adID
    @objc static func registerToken(token : String, pid : String ,adid : NSString)
    {
        if(token != "" && pid != "")
        {
            let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems =
            [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: AppConstant.IZ_BTYPE),
                URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: AppConstant.IZ_DTYPE),
                URLQueryItem(name: AppConstant.iZ_KEY_TIME_ZONE, value:"\(Utils.currentTimeInMilliSeconds())"),
                URLQueryItem(name: AppConstant.iZ_KEY_SDK_VERSION, value:"\(Utils.getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_OS, value: AppConstant.IZ_OS_TYPE),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
                URLQueryItem(name: AppConstant.iZ_KEY_ADID, value: identifierForAdvertising()),
                URLQueryItem(name: AppConstant.iZ_DEVICE_OS_VERSION, value: "\(Utils.getVersion())"),
                URLQueryItem(name: AppConstant.iZ_DEVICE_NAME, value: "\(Utils.getDeviceName())"),
                URLQueryItem(name: AppConstant.iZ_KEY_CHECK_VERSION, value: "\(Utils.getAppVersion())"),
                URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: "\(pluginVersion)")
                
            ]
            guard let url = URL(string: RestAPI.BASEURL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let config = URLSessionConfiguration.default
            if #available(iOS 11.0, *) {
                config.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
            URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            sharedUserDefault?.set(true,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                            sharedUserDefault?.set("", forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID_)
                            
                        }else{
                            sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
                            Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: "", cid: "")
                        }
                    }
                    
                } catch {
                    Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: "", cid: "")
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(exceptionName: AppConstant.iZ_KEY_REGISTERED_ID_ERROR, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD,  rid: "", cid: "")
            sharedUserDefault?.set(false,forKey: AppConstant.iZ_KEY_ADVERTISEMENT_ID)
        }
    }
    
    // send exception to the server
    @objc static func sendExceptionToServer(exceptionName: String, className: String, methodName: String,rid: String, cid: String, appId: String) {
        
         let pid = Utils.getUserId() ?? ""
         let token = Utils.getUserDeviceToken() ?? ""
        let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""
        let requestHeaders: [String: String] = [AppConstant.iZ_CONTENT_TYPE: AppConstant.iZ_CONTENT_TYPE_VALUE]
        
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "pid", value: "\(pid)"),
            URLQueryItem(name: "appId", value: appId),// need to add iZooto app id
            URLQueryItem(name: "exceptionName", value: exceptionName),
            URLQueryItem(name: "methodName", value: methodName),
            URLQueryItem(name: "className", value: className),
            URLQueryItem(name: "bKey", value: token),
            URLQueryItem(name: "av", value: SDKVERSION),
            URLQueryItem(name: "rid", value: rid),
            URLQueryItem(name: "cid", value: cid),
            URLQueryItem(name: AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, value: pluginVersion),
            URLQueryItem(name: "osVersion", value: Utils.getVersion()),
            URLQueryItem(name: "deviceName", value: Utils.getDeviceName()),
            URLQueryItem(name: "appVersion", value: Utils.getAppVersion())
        ]
        guard let url = URL(string: RestAPI.EXCEPTION_URL) else {
            // Handle the case where the URL is nil
            print("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = AppConstant.iZ_POST_REQUEST
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        URLSession(configuration: config).dataTask(with: request) { data, response, error in
            do {
                if let error = error {
                    throw error
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                       // debugPrint("Exception sent successfully to server")
                    } else {
                        throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: nil)
                    }
                }
            } catch {
                print("Failed to send exception to server: \(error)")
            }
        }.resume()
    }
    
    //Ad-Mediation Impression
    @objc static func callAdMediationImpressionApi(finalDict: NSDictionary){
        
        let defaults = UserDefaults.standard
        
        if (finalDict.count != 0) {
            let rid = finalDict.value(forKey: "rid") as? String
            let jsonData = try? JSONSerialization.data(withJSONObject: finalDict as? [String: Any])
            
            guard let url = URL(string: RestAPI.MEDIATION_IMPRESSION_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "\(AppConstant.iZ_CONTENT_TYPE)")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let config = URLSessionConfiguration.default
            if #available(iOS 11.0, *) {
                config.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
            URLSession(configuration: config).dataTask(with: request) {data,response,error in
                
                do {
                    if let error = error {
                        throw error
                    }
                    // Check the HTTP response status code
                    if let httpResponse = response as? HTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            print("Mediation Impression Success")
                            
                        }else{
                            Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Impression API",  rid: rid ?? "" , cid: "")
                        }
                    }
                } catch {
                    
                    Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "CallAdMediationImpressionApi", rid: rid ?? "", cid: "")
                    
                }
            }.resume()
        }else{
            Utils.handleOnceException(exceptionName: "key's are blank in request parameter,\(finalDict) ", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Impression API",  rid: "", cid: "")
        }
    }
    
    //Ad-Mediation ClickAPI
    @objc static func callAdMediationClickApi(finalDict: NSDictionary){
        
        let defaults = UserDefaults.standard
        if (finalDict.count != 0) {
            let rid = finalDict.value(forKey: "rid") as? String
            let jsonData = try? JSONSerialization.data(withJSONObject: finalDict)
            
            guard let url = URL(string: RestAPI.MEDIATION_CLICK_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            
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
                            print("Mediation Impression Success")
                        }else{
                            Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 1", rid: rid ?? "", cid: "")
                        }
                    }
                } catch {
                    
                    if let data = finalDict as? [String : Any] {
                        self.mediationClickStoreData.append(data)
                    }
                    UserDefaults.standard.set(self.mediationClickStoreData, forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
                    
                    Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 2", rid: rid ?? "", cid: "")
                }
            }.resume()
        }else{
            Utils.handleOnceException(exceptionName: "key's are blank in request parameter, \(finalDict)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 3",  rid: "", cid: "")
        }
    }
    
    static func callRV_RC_Request( urlString : String)
    {
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
                                print("RC and RC api hits successfully")
                            }else{
                                Utils.handleOnceException(exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callRV_RC_Request", rid: "", cid: "")
                                
                            }
                        }
                    } catch {
                        Utils.handleOnceException(exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callRV_RC_Request", rid: "", cid: "")
                    }
                }.resume()
            }
        }else{
            Utils.handleOnceException(exceptionName: "Url is not in correct format = \(urlString)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callRV_RC_Request", rid: "", cid: "")
        }
    }
    
   // All Notification Data
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
                    if let jsonArray = jsonResponse as? NSArray {
                        for data in jsonArray {
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
                catch _
                {
                    completion("No more data", nil)
                    return
                    
                }
            }
        }
        task.resume()
    }
    
    
    // add email capture api
    @objc static func addEmailDetails(token:String,pid : String,email : String,fName:String,lName:String)
    {
        guard !token.isEmpty, pid != "" else {
           // Logger.warning("Token is an empty string or pid is 0")
            let emailAndName = ["email":email, "fName":fName, "lName": lName]
            UserDefaults.standard.set(emailAndName, forKey: "syncUserData")
            sharedUserDefault?.set("email", forKey: "email")
            return
        }
        let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems =
        [
            URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
            URLQueryItem(name: AppConstant.iZ_KEY_BTYPE, value: AppConstant.IZ_BTYPE),
            URLQueryItem(name: AppConstant.iZ_KEY_DTYPE, value: AppConstant.IZ_DTYPE),
            URLQueryItem(name: AppConstant.iZ_KEY_APP_SDK_VERSION, value: SDKVERSION),
            URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN,value: token),
            URLQueryItem(name: AppConstant.iZ_KEY_OS, value: AppConstant.IZ_OS_TYPE),
            URLQueryItem(name: "email", value: email),
            URLQueryItem(name: "fn", value: fName),
            URLQueryItem(name: "ln", value: lName)
          ]
        guard let url = URL(string: RestAPI.EMAIL_CAPTURE_API) else {
            // Handle the case where the URL is nil
            print("Error: Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = AppConstant.iZ_POST_REQUEST
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        let config = URLSessionConfiguration.default
        if #available(iOS 11.0, *) {
            config.waitsForConnectivity = true
        } else {
            // Fallback on earlier versions
        }
        URLSession(configuration: config).dataTask(with: request) {(data,response,error) in
            
            do {
                if let error = error {
                    throw error
                }
                // Check the HTTP response status code
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("google sign in success!")
                        if UserDefaults.standard.value(forKey: "syncUserData") != nil {
                            UserDefaults.standard.setValue(nil, forKey: "syncUserData")
//                            let data = UserDefaults.standard.value(forKey: "syncUserData")
                            sharedUserDefault?.set("email", forKey:"email")

                        }
                        let dict = ["nlo":"0"]
                        iZooto.addUserProperties(data: dict)
                       // print("Email received sucessfully\(httpResponse.statusCode)")
                    }
                }
            } catch {
                debugPrint("Error occured on api")
            }
        }.resume()
    }
    
    // get App version
    static func getAppVersion() -> String {
        if let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String{
            // print(version)
            return "\(version)"
        }
        return "0.0"
    }
    
    public static func getBundleName()->String
    {
        guard let bundleID = Bundle.main.bundleIdentifier else {return "not found"}
        return "group."+bundleID + ".iZooto"
    }
}





