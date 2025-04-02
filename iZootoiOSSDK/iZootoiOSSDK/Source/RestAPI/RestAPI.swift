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
    static let SDKVERSION = "2.4.2"
    static let FALLBACK_URL = "https://flbk.izooto.com/default.json"
    static var EMAIL_CAPTURE_API = "https://eenp.izooto.com/eenp"
   
   
    //All notification Data
    static let ALL_NOTIFICATION_DATA = "https://nh.izooto.com/nh/"
    static var index = 0
    static var stopCalling = false
    static var lessData = 0
    
    static let defaults = UserDefaults.standard
    private static var clickStoreData: [[String:Any]] = []
    private static var mediationClickStoreData: [[String:Any]] = []
    
    static var tag_name = "RestAPI"
    
    
    public static func getRequest(bundleName: String, uuid: String, completionBlock: @escaping (String?) -> Void) -> Void
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
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: error?.localizedDescription ?? "no found", className: tag_name, methodName: "getRequest", rid: nil, cid: nil, userInfo: nil)
                        print(AppConstant.IZ_TAG,AppConstant.APP_ID_ERROR)
                        
                    }else
                    {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200{
                                
                                if UserDefaults.standard.value(forKey: AppConstant.iZ_CLICK_OFFLINE_DATA) != nil{
                                    self.offlineClickTrackCall(bundleName: bundleName)
                                }
                                if UserDefaults.standard.value(forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA) != nil{
                                    self.mediationOfflineClickTrackCall(bundleName: bundleName)
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
                                    print("No data received.")
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
                                Utils.handleOnceException(bundleName: bundleName, exceptionName: "response error generated\(uuid)", className: tag_name, methodName: "getRequest", rid: nil, cid: nil, userInfo: nil)
                            }
                        }
                    }
                }.resume()
            }
        }else{
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "iZooto app id is blank or null", className: tag_name, methodName: "getRequest", rid: nil, cid: nil, userInfo: nil)
        }
    }
    
    
    
    // send event to server
    static func callEvents(bundleName: String, eventName : String, data : NSString,pid : String,token : String)
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
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: error?.localizedDescription ?? "Error code" , className: tag_name, methodName: "callEvents",  rid: nil, cid: nil, userInfo: nil)
                        }
                    }
                } catch {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription , className: tag_name, methodName: "callEvents",rid: nil, cid: nil, userInfo: nil)
                    
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "user id or event data is null" , className: tag_name, methodName: "callEvents",  rid: nil, cid: nil, userInfo: nil)
        }
    }
    
    // send user properties to server
    static func callUserProperties(bundleName : String, data : NSString,pid : String,token : String)
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
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
                            print("User properties added.")
                        }else{
                            Utils.handleOnceException(bundleName: bundleName, exceptionName:  "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")" , className: tag_name, methodName: "callUserProperties", rid: nil, cid: nil, userInfo: nil)
                            
                        }
                    }
                } catch {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName:  "" , className: tag_name, methodName: "callUserProperties", rid: nil, cid: nil, userInfo: nil)
                    
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName:  "User Properties data is blank" , className: tag_name, methodName: "callUserProperties",  rid: nil, cid: nil, userInfo: nil)
            
        }
    }
    
    // track the notification impression
    static func callImpression(notificationData : Payload,pid : String,token : String,bundleName : String, isSilentPush: Bool, userInfo: [AnyHashable : Any]?)
    {
        var cid: String? = nil
        var rid: String? = nil
        if notificationData.ankey != nil{
            cid = notificationData.global?.id ?? nil
            rid = notificationData.global?.rid ?? nil
        }else{
            cid = notificationData.id ?? nil
            rid = notificationData.rid ?? nil
        }
        if(rid != nil && pid != "" && token != ""){
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: pid),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "rid", value: rid),
                URLQueryItem(name: "op", value: "view"),
                URLQueryItem(name: "ver", value: SDKVERSION)
            ]
            if isSilentPush {
                requestBodyComponents.queryItems?.append(URLQueryItem(name: "sn", value: "1"))
            }
            
            guard let url = URL(string: RestAPI.IMPRESSION_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.setValue(bundleName, forHTTPHeaderField: "Referer")
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
//                            debugPrint("callImpression Success")
                        }else{
                            Utils.handleOnceException(bundleName: bundleName, exceptionName:  error?.localizedDescription ?? "Error code " , className: tag_name, methodName: "callImpression",rid: rid, cid: cid, userInfo: userInfo)
                        }
                    }
                } catch let error {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName:  error.localizedDescription, className: tag_name, methodName: "callImpression",  rid: rid, cid: cid, userInfo: userInfo)
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName:  "rid,pid or token is blank" , className: tag_name, methodName: "callImpression",  rid: rid, cid: cid, userInfo: userInfo)
        }
    }
    
    // track the notification click
    static func clickTrack(bundleName : String, notificationData : Payload,type : String, pid : String,token : String, userInfo:[AnyHashable : Any]?)
    {
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~#[]@!$'()*+,;")  //-> /:?&
        var clickLn = notificationData.url?.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? ""
        if let encodedURLString = clickLn.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            clickLn = encodedURLString
        }
        if notificationData.rid != "" && notificationData.rid != nil && pid != "" && token != ""{
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: notificationData.id),
                URLQueryItem(name: "rid", value: notificationData.rid),
                URLQueryItem(name: "ti", value: "\(notificationData.alert?.title)"),
                URLQueryItem(name: "op", value: "click"),
                URLQueryItem(name: "ver", value: SDKVERSION),
                URLQueryItem(name: "ln", value: "\(clickLn)"),
                URLQueryItem(name: "ap", value: "\(notificationData.ap)"),
            ]
            
            if type != "0"{
                queryItems.append(URLQueryItem(name: "btn", value: type))
            }
            requestBodyComponents.queryItems = queryItems
            
            let dict = ["pid": pid, "bKey": token, "cid":notificationData.id , "rid":notificationData.rid, "ti":notificationData.alert?.title, "op":"click", "ver": SDKVERSION, "btn": type]
            guard let url = URL(string: RestAPI.CLICK_URL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
//                            print("medition clk")
                        }else{
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "clickTrack", rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
                        }
                    }
                } catch let error{
                    self.clickStoreData.append(dict)
                    UserDefaults.standard.set(self.clickStoreData, forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)" , className: tag_name, methodName: "clickTrack",  rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
                }
            }.resume()
        }else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid or cid value is blank" , className: tag_name, methodName: "clickTrack",  rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
        }
    }
    
    static func offlineClickTrackCall(bundleName:String){
        
        if let dd = UserDefaults.standard.value(forKey: AppConstant.iZ_CLICK_OFFLINE_DATA) as? [[String : Any]]{
            var tempArray: [[String:Any]] = []
            for dict in dd{
                tempArray = dd
                let data = dict as? NSDictionary
                
                self.clickOfflineTrack(bundleName: bundleName, pid: data?.value(forKey: "pid") as? String ?? "", cid: data?.value(forKey: "cid") as? String, rid: data?.value(forKey: "rid") as? String, ver: data?.value(forKey: "ver") as? String ?? "", btn: data?.value(forKey: "btn") as? String ?? "", token: data?.value(forKey: "bKey") as? String ?? "", title: data?.value(forKey: "ti") as? String ?? "",ln: data?.value(forKey: "ln") as? String ?? "", userInfo: nil)
            }
            tempArray.removeAll()
            UserDefaults.standard.set(tempArray, forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
            self.clickStoreData.removeAll()
        }
    }
    
    static func mediationOfflineClickTrackCall(bundleName: String){
        if let dd = UserDefaults.standard.value(forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA) as? [[String : Any]]{
            var tempArray: [[String:Any]] = []
            tempArray = dd
            for dict in dd{
                if let data = dict as? NSDictionary {
                    self.callAdMediationClickApi(bundleName: bundleName, finalDict: data, userInfo: nil)
                }
            }
            tempArray.removeAll()
            UserDefaults.standard.set(tempArray, forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
            self.mediationClickStoreData.removeAll()
        }
    }
    
    //Offline click track
    static func clickOfflineTrack(bundleName: String, pid: String, cid: String?, rid: String?, ver: String, btn: String , token : String, title: String,ln :String, userInfo: [AnyHashable : Any]?)
    {
        if(rid != nil && pid != "" && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "rid", value: rid),
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
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
                        }
                    }
                } catch {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: tag_name, methodName: "clickTrackOffline", rid:rid, cid: cid, userInfo: userInfo)
                    
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid or pid or token is blank", className: tag_name, methodName: "clickTrackOffline", rid: rid, cid: cid, userInfo: userInfo)
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
        var idfa = ""
        if #available(iOS 14, *) {
            let trackingStatus = ATTrackingManager.trackingAuthorizationStatus
            switch trackingStatus {
            case .authorized:
                idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                UserDefaults.standard.set(true, forKey: "registerTokenKey")
                return idfa
            case .denied, .notDetermined, .restricted :
                idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                return idfa
            @unknown default:
                idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                return idfa
            }
        } else {
            // Fallback for iOS 13 and below
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                return idfa
            } else {
                idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                return idfa
            }
        }
    }
    
    // last visit data send to server
    @objc static func lastVisit(bundleName: String,pid : String,token : String)
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
                request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
                                
                            }else{
                                Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "lastVisit" , rid: nil,cid :nil, userInfo: nil)
                            }
                        }
                    } catch {
                        Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: tag_name, methodName: "lastVisit" , rid: nil,cid :nil, userInfo: nil)
                    }
                }.resume()
            }
            else
            {
                Utils.handleOnceException(bundleName: bundleName, exceptionName: "json is not correct", className: tag_name, methodName: "lastVisit" , rid: nil,cid :nil, userInfo: nil)
            }
        }
        else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "pid is not found", className: tag_name, methodName: "lastVisit" , rid: nil,cid :nil, userInfo: nil)
        }
    }
    // last impression send to server
    @objc static func lastImpression(notificationData : Payload,pid : String,token : String,url : String,bundleName : String, userInfo: [AnyHashable : Any]? )
    {
        let rid = notificationData.rid ?? notificationData.global?.rid
        let cid = notificationData.id ?? notificationData.global?.id
        if(rid != nil && pid != "" && token != "")
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "rid", value: rid),
                URLQueryItem(name: "op", value: "view")
            ]
            guard let url = URL(string: url) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(bundleName, forHTTPHeaderField: "Referer")
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
                            //print("last impression called.")
                        }else{
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: rid,cid : cid, userInfo: userInfo)
                        }
                    }
                } catch {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: rid, cid : cid, userInfo: userInfo)
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid value is blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastImpression" , rid: rid, cid : cid, userInfo: userInfo)
        }
    }
    
    // last click data send to server
    @objc static func lastClick(bundleName: String, notificationData : Payload,pid : String,token : String,url : String, userInfo: [AnyHashable: Any]?)
    {
        if(pid != "" && token != "" && notificationData.rid != nil)
        {
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
               requestBodyComponents.queryItems = [
                URLQueryItem(name: AppConstant.iZ_KEY_PID, value: "\(pid)"),
                URLQueryItem(name: AppConstant.iZ_KEY_DEVICE_TOKEN, value: token),
                URLQueryItem(name: "cid", value: notificationData.id),
                URLQueryItem(name: "rid", value: notificationData.rid),
                URLQueryItem(name: "op", value: "click")
            ]
            
            guard let url = URL(string: url) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
                            //print("last click called.")
                        }else{
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid,cid : notificationData.id, userInfo: userInfo)
                        }
                    }
                    
                } catch {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid, cid : notificationData.id, userInfo: userInfo)
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "rid value is blank", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "lastClick" , rid: notificationData.rid, cid : notificationData.id, userInfo: userInfo)
        }
    }
    
    // register the token on our panel
    @objc static func registerToken(bundleName:String, token : String, pid : String)
    {
        if(token != "" && pid != "")
        {
            let defaults = UserDefaults.standard
            defaults.setValue(pid, forKey: AppConstant.iZ_PID)
            defaults.setValue(token, forKey: "token")
            let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""
            let requestHeaders:[String:String] = [AppConstant.iZ_CONTENT_TYPE:AppConstant.iZ_CONTENT_TYPE_VALUE]
            var requestBodyComponents = URLComponents()
            let queryParameters: [(String, String?)] = [
                (AppConstant.iZ_KEY_PID, "\(pid)"),
                (AppConstant.iZ_KEY_BTYPE, AppConstant.IZ_BTYPE),
                (AppConstant.iZ_KEY_DTYPE, AppConstant.IZ_DTYPE),
                (AppConstant.iZ_KEY_TIME_ZONE, "\(Utils.currentTimeInMilliSeconds())"),
                (AppConstant.iZ_KEY_SDK_VERSION, "\(Utils.getAppVersion())"),
                (AppConstant.iZ_KEY_OS, AppConstant.IZ_OS_TYPE),
                (AppConstant.iZ_KEY_DEVICE_TOKEN, token),
                (AppConstant.iZ_KEY_APP_SDK_VERSION, SDKVERSION),
                (AppConstant.iZ_KEY_ADID, identifierForAdvertising()),
                (AppConstant.iZ_DEVICE_OS_VERSION, "\(Utils.getVersion())"),
                (AppConstant.iZ_DEVICE_NAME, "\(Utils.getDeviceName())"),
                (AppConstant.iZ_KEY_CHECK_VERSION, "\(Utils.getAppVersion())"),
                (AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, "\(pluginVersion)")
            ]

            requestBodyComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.0, value: $0.1) }
            
            guard let url = URL(string: RestAPI.BASEURL) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
                            
                            let currentUnixTimestamp: TimeInterval = TimeInterval(Int(Date().timeIntervalSince1970 * 1000))
                            if let userDefaults = UserDefaults(suiteName: Utils.getGroupName(bundleName: bundleName)){//used in addMacros
                                userDefaults.setValue(currentUnixTimestamp, forKey: "unixTS")
                            }
                            let date = Date()
                            let format = DateFormatter()
                            format.dateFormat = AppConstant.iZ_KEY_DATE_FORMAT
                            let formattedDate = format.string(from: date)
                            if(formattedDate != (sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_LAST_VISIT)))
                            {
                                RestAPI.lastVisit(bundleName: bundleName, pid: pid, token:token)
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
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: nil, cid: nil, userInfo: nil)
                            print(AppConstant.IZ_TAG,AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR)
                            
                        }
                    }
                } catch {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: nil, cid: nil, userInfo: nil)
                }
            }.resume()
        }
        else
        {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "pid or token is not generated", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: nil, cid: nil, userInfo: nil)
        }
    }
    
    @objc static func sendExceptionToServer(bundleName:String, exceptionName: String, className: String, methodName: String, rid: String?, cid: String?, appId: String, userInfo: [AnyHashable: Any]?) {
        // Retrieve app and device details
        let appDetails = AppManager.shared.appDetails
        let deviceDetails = AppManager.shared.deviceInfo
        let pid = Utils.getUserId(bundleName: bundleName) ?? ""
        let token = Utils.getUserDeviceToken(bundleName: bundleName) ?? ""
        let pluginVersion = sharedUserDefault?.string(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE) ?? ""
        let currentDate = Date()
        let currentTimeStamp = Int(currentDate.timeIntervalSince1970)
        
        // Create the JSON payload
        let exceptionDetails: [String: Any?] = [
            "name": exceptionName,
            "className": className,
            "method": methodName,
            "createdTime": "\(currentTimeStamp)",
            "cid": cid,
            "rid": rid,
            "notification": userInfo
        ]

        let filteredExceptionDetails = exceptionDetails.compactMapValues { $0 }

        let requestBody: [String: Any] = [
            "deviceDetails": [
                "os": deviceDetails.os,
                "name": deviceDetails.name,
                "build": deviceDetails.build,
                "version": deviceDetails.version,
                "deviceID": deviceDetails.deviceID
            ],
            "appDetails": [
                "name": appDetails.name,
                "version": appDetails.version,
                "bundleID": appDetails.bundleId,
            ],
            "sdkDetails": [
                "pid": pid,
                "version": SDKVERSION,
                "appId": appId,
                "bKey": token,
                "pv": pluginVersion
            ],
            "exceptionDetails": filteredExceptionDetails
        ]

        // Convert the dictionary to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
            print("Error: Could not serialize JSON request body")
            return
        }
        
        // Prepare the URL and request headers
        guard let url = URL(string: RestAPI.EXCEPTION_URL) else {
            print("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = AppConstant.iZ_POST_REQUEST
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        // Create the URL session configuration
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        // Send the request
        URLSession(configuration: config).dataTask(with: request) { data, response, error in
            do {
                if let error = error {
                    throw error
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("Exception sent successfully to server")
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
    @objc static func callAdMediationImpressionApi(finalDict: NSDictionary, bundleName: String, userInfo: [AnyHashable : Any]?){
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
            request.setValue(bundleName, forHTTPHeaderField: "Referer")
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
//                            print("mediation medi success")
                        }
                    }
                } catch {
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "CallAdMediationImpressionApi", rid: rid, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
                }
            }.resume()
        }else{
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "key's are blank in request parameter,\(finalDict) ", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Impression API",  rid: finalDict.value(forKey: "rid") as? String, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
        }
    }
    
    //Ad-Mediation ClickAPI
    @objc static func callAdMediationClickApi(bundleName:String, finalDict: NSDictionary, userInfo: [AnyHashable : Any]?){
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
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
//                            print("Mediation Click Success")
                        }else{
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 1", rid: rid, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
                        }
                    }
                } catch {
                    
                    if let data = finalDict as? [String : Any] {
                        self.mediationClickStoreData.append(data)
                    }
                    UserDefaults.standard.set(self.mediationClickStoreData, forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
                    
                    Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 2", rid: rid, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
                }
            }.resume()
        }else{
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "key's are blank in request parameter, \(finalDict)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "Ad-Mediation Click API 3",  rid: finalDict.value(forKey: "rid") as? String, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
        }
    }
    
    static func callRV_RC_Request(bundleName:String, urlString : String)
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
//                                print("RV and RC api hits successfully.")
                            }
                        }
                    } catch {
                        Utils.handleOnceException(bundleName:bundleName, exceptionName: "\(error.localizedDescription)", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "callRV_RC_Request", rid: nil, cid: nil, userInfo: nil)
                    }
                }.resume()
            }
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
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
        
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
    @objc static func addEmailDetails(bundleName: String, token:String,pid : String,email : String,fName:String,lName:String)
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
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = AppConstant.iZ_POST_REQUEST
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "Referer")
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
                    }
                }
            } catch {
                Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription, className: "RestAPI", methodName: "addEmailDetails", rid: nil, cid: nil, userInfo: nil)
            }
        }.resume()
    }
    
    // get App version
    static func getAppVersion() -> String {
        if let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String{
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





