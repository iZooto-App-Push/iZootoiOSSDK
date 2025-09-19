//
//  RestAPI.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//
import Foundation
import UIKit
import AdSupport
import AppTrackingTransparency
import UserNotifications


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
    static var index = 0
    static var stopCalling = false
    static var lessData = 0
    
    static var tag_name = "RestAPI"
    
    static func callEvents(bundleName: String, eventName : String, data : NSString,pid : String,token : String)
    {
        guard !token.isEmpty, !pid.isEmpty else { return }
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "act", value: "\(eventName)"),
            URLQueryItem(name: "et", value: "evt"),
            URLQueryItem(name: "val", value: "\(data)")
        ]
        let bodyData = requestBodyComponents.query?.data(using: .utf8)
        guard let url = URL(string: ApiConfig.eventUrl) else {
            debugPrint("Error: Invalid URL")
            return
        }
        
        let request = APIRequest(
            url: url,
            method: .POST,
            contentType: .formURLEncoded,
            body: bodyData
        )
        NetworkManager.shared.sendRequest(request) { result in
            switch result {
            case .success:
                AppStorage.shared.removeValue(forKey: AppConstant.KEY_EVENT)
                AppStorage.shared.removeValue(forKey: AppConstant.KEY_EVENT_NAME)
            case .failure(let error):
                Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription, className: "RestAPI", methodName: "callEvents", rid: nil, cid: nil, userInfo: nil)
            }
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
                URLQueryItem(name: AppConstant.iZ_CID_KEY, value: cid),
                URLQueryItem(name: AppConstant.iZ_RID_KEY, value: rid),
                URLQueryItem(name: "op", value: "view"),
                URLQueryItem(name: "ver", value: ApiConfig.SDK_VERSION)
            ]
            if isSilentPush {
                requestBodyComponents.queryItems?.append(URLQueryItem(name: "sn", value: "1"))
            }
            
            guard let url = URL(string: ApiConfig.impressionUrl) else {
                // Handle the case where the URL is nil
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.allHTTPHeaderFields = requestHeaders
            request.setValue(bundleName, forHTTPHeaderField: AppConstant.IZ_REFERER)
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
                URLQueryItem(name: AppConstant.iZ_CID_KEY, value: "\(notificationData.id ?? "")"),
                URLQueryItem(name: AppConstant.iZ_RID_KEY, value: notificationData.rid),
                URLQueryItem(name: AppConstant.iZ_TITLE_KEY, value: "\(notificationData.alert?.title)"),
                URLQueryItem(name: "op", value: "click"),
                URLQueryItem(name: "ver", value: ApiConfig.SDK_VERSION),
                URLQueryItem(name: AppConstant.iZ_LNKEY, value: "\(clickLn)"),
                URLQueryItem(name: "ap", value: "\(notificationData.ap)"),
            ]
            
            if type != "0"{
                queryItems.append(URLQueryItem(name: "btn", value: type))
            }
            requestBodyComponents.queryItems = queryItems
            
            let dict = [AppConstant.iZ_KEY_PID: pid, AppConstant.iZ_KEY_DEVICE_TOKEN: token, AppConstant.iZ_CID_KEY:"\(notificationData.id ?? "")" , AppConstant.iZ_RID_KEY:notificationData.rid, AppConstant.iZ_TITLE_KEY:notificationData.alert?.title, "op":"click", "ver": ApiConfig.SDK_VERSION, "btn": type]
            guard let url = URL(string: ApiConfig.clickUrl) else {
                // Handle the case where the URL is nil
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: AppConstant.IZ_REFERER)
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
//                            print("click success")
                        }else{
                            Utils.handleOnceException(bundleName: bundleName, exceptionName: "\(error?.localizedDescription ?? "Error code \(httpResponse.statusCode)")", className: tag_name, methodName: "clickTrack", rid: notificationData.rid, cid: notificationData.id, userInfo: userInfo)
                        }
                    }
                } catch let error{
                    var storedData = UserDefaults.standard.array(forKey: AppConstant.iZ_CLICK_OFFLINE_DATA) as? [[String: Any]] ?? []
                    storedData.append(dict)
                    UserDefaults.standard.set(storedData, forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
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
                
                self.clickOfflineTrack(bundleName: bundleName, pid: data?.value(forKey: AppConstant.iZ_KEY_PID) as? String ?? "", cid: data?.value(forKey: AppConstant.iZ_CID_KEY) as? String, rid: data?.value(forKey: AppConstant.iZ_RID_KEY) as? String, ver: data?.value(forKey: "ver") as? String ?? "", btn: data?.value(forKey: "btn") as? String ?? "", token: data?.value(forKey: AppConstant.iZ_KEY_DEVICE_TOKEN) as? String ?? "", title: data?.value(forKey: AppConstant.iZ_TITLE_KEY) as? String ?? "",ln: data?.value(forKey: AppConstant.iZ_LNKEY) as? String ?? "", userInfo: nil)
            }
            tempArray.removeAll()
        }
    }
    
    static func mediationOfflineClickTrackCall(bundleName: String){
        if let dd = UserDefaults.standard.value(forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA) as? [[String : Any]]{
            for dict in dd{
                if let data = dict as? NSDictionary {
                    RestAPI.offlineMedcTrack(finalDict: data, bundleName: bundleName, userInfo: nil)
                }
            }
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
                URLQueryItem(name: AppConstant.iZ_CID_KEY, value: cid),
                URLQueryItem(name: AppConstant.iZ_RID_KEY, value: rid),
                URLQueryItem(name: AppConstant.iZ_TITLE_KEY, value: "\(title)"),
                URLQueryItem(name: AppConstant.iZ_LNKEY, value: "\(ln)"),
                URLQueryItem(name: "op", value: "click"),
                URLQueryItem(name: "ver", value: ver),
                URLQueryItem(name: "btn", value: "\(btn)")
            ]
            guard let url = URL(string: ApiConfig.clickUrl) else {
                // Handle the case where the URL is nil
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: AppConstant.IZ_REFERER)
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
                            UserDefaults.standard.removeObject(forKey: AppConstant.iZ_CLICK_OFFLINE_DATA)
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
    
    @objc static func offlineMedcTrack(finalDict: NSDictionary, bundleName: String, userInfo: [AnyHashable : Any]?) {
        guard finalDict.count != 0 else {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "key's are blank in request parameter,\(finalDict)", className: AppConstant.iZ_REST_API_CLASS_NAME,
                methodName: "offlineMedcTrack", rid: finalDict.value(forKey: AppConstant.iZ_RID_KEY) as? String, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
            return
        }

        guard let finalUrl = URL(string: ApiConfig.mediationClickUrl) else {
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: finalDict as? [String: Any] ?? [:]) else {
            return
        }

        let request = APIRequest(
            url: finalUrl,
            method: .POST,
            contentType: .json,
            body: jsonData
        )

        NetworkManager.shared.sendRequest(request) { result in
            switch result {
            case .success(let data):
                // Optional: Handle response body
                UserDefaults.standard.removeObject(forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
                break
            case .failure(let error):
                let rid = finalDict.value(forKey: AppConstant.iZ_RID_KEY) as? String
                let cid = finalDict.value(forKey: "id") as? String
                Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "offlineMedcTrack", rid: rid, cid: cid, userInfo: userInfo)
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
                
                guard let url = URL(string: ApiConfig.lastVisitUrl) else {
                    // Handle the case where the URL is nil
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = AppConstant.iZ_POST_REQUEST
                request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: AppConstant.IZ_REFERER)
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
                                AppStorage.shared.set(Date().getFormattedDate(), forKey: AppConstant.iZ_KEY_LAST_VISIT)
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
                URLQueryItem(name: AppConstant.iZ_CID_KEY, value: cid),
                URLQueryItem(name: AppConstant.iZ_RID_KEY, value: rid),
                URLQueryItem(name: "op", value: "view")
            ]
            guard let url = URL(string: url) else {
                // Handle the case where the URL is nil
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(bundleName, forHTTPHeaderField: AppConstant.IZ_REFERER)
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
                URLQueryItem(name: AppConstant.iZ_CID_KEY, value: notificationData.id),
                URLQueryItem(name: AppConstant.iZ_RID_KEY, value: notificationData.rid),
                URLQueryItem(name: "op", value: "click")
            ]
            
            guard let url = URL(string: url) else {
                // Handle the case where the URL is nil
                print("Error: Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = AppConstant.iZ_POST_REQUEST
            request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: AppConstant.IZ_REFERER)
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
                "bundleID": bundleName,
            ],
            "sdkDetails": [
                "pid": pid,
                "version": ApiConfig.SDK_VERSION,
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
        guard let url = URL(string: ApiConfig.exceptionUrl) else {
            print("Error: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = AppConstant.iZ_POST_REQUEST
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: AppConstant.IZ_REFERER)
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
                       // debprint("Exception sent successfully to server\(requestBody)")
                    } else {
                        throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: nil)
                    }
                }
            } catch {
                print("Failed to send exception to server: \(error)")
            }
        }.resume()
    }

    @objc static func callAdMediationImpressionApi(finalDict: NSDictionary, bundleName: String, userInfo: [AnyHashable : Any]?,url:String) {
        guard finalDict.count != 0 else {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "key's are blank in request parameter,\(finalDict)", className: AppConstant.iZ_REST_API_CLASS_NAME,
                methodName: "Ad-Mediation Impression API", rid: finalDict.value(forKey: AppConstant.iZ_RID_KEY) as? String, cid: finalDict.value(forKey: "id") as? String, userInfo: userInfo)
            return
        }

        guard let finalUrl = URL(string: url) else {
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: finalDict as? [String: Any] ?? [:]) else {
            print("Error: Unable to convert dictionary to JSON")
            return
        }

        let request = APIRequest(
            url: finalUrl,
            method: .POST,
            contentType: .json,
            body: jsonData
        )

        NetworkManager.shared.sendRequest(request) { result in
            switch result {
            case .success(let data):
                // Optional: Handle response body
                
                break
            case .failure(let error):
                let rid = finalDict.value(forKey: AppConstant.iZ_RID_KEY) as? String
                let cid = finalDict.value(forKey: "id") as? String
                if let data = finalDict as? [String : Any] {
                    var storedData = UserDefaults.standard.array(forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA) as? [[String: Any]] ?? []
                    storedData.append(data)
                    UserDefaults.standard.set(storedData, forKey: AppConstant.iZ_MED_CLICK_OFFLINE_DATA)
                }
                
                Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: "CallAdMediationImpressionApi", rid: rid, cid: cid, userInfo: userInfo)
            }
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
        let url = URL(string: ApiConfig.newsHubFeedUrl+"\(sID)/\(index).json")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: AppConstant.IZ_REFERER)
        
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
}



extension RestAPI {
    @objc static func registerToken(bundleName: String, token: String, pid: String) {
        guard !token.isEmpty, !pid.isEmpty else {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "Pid or Token is not generated", className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: nil, cid: nil, userInfo: nil)
            return
        }

        let pluginVersion = AppStorage.shared.getString(forKey: AppConstant.iZ_KEY_PLUGIN_VERSION_VALUE)
        let queryParameters: [(String, String?)] = [
            (AppConstant.iZ_KEY_PID, pid),
            (AppConstant.iZ_KEY_BTYPE, AppConstant.IZ_BTYPE),
            (AppConstant.iZ_KEY_DTYPE, AppConstant.IZ_DTYPE),
            (AppConstant.iZ_KEY_TIME_ZONE, "\(Utils.currentTimeInMilliSeconds())"),
            (AppConstant.iZ_KEY_SDK_VERSION, Utils.getAppVersion()),
            (AppConstant.iZ_KEY_OS, AppConstant.IZ_OS_TYPE),
            (AppConstant.iZ_KEY_DEVICE_TOKEN, token),
            (AppConstant.iZ_KEY_APP_SDK_VERSION, ApiConfig.SDK_VERSION),
            (AppConstant.iZ_KEY_ADID, ASIdentifierManager.shared().advertisingIdentifier.uuidString),
            (AppConstant.iZ_DEVICE_OS_VERSION, Utils.getVersion()),
            (AppConstant.iZ_DEVICE_NAME, Utils.getDeviceName()),
            (AppConstant.iZ_KEY_CHECK_VERSION, Utils.getAppVersion()),
            (AppConstant.iZ_KEY_PLUGIN_VRSION_NAME, pluginVersion),
            (AppConstant.IZ_MOBILE_PACKAGE_NAME, bundleName),
            (AppConstant.IZ_SDK_NAME_KEY, AppConstant.IZ_SDK_NAME_VALUE)
        ]

        var urlComponents = URLComponents()
        urlComponents.queryItems = queryParameters.map { URLQueryItem(name: $0.0, value: $0.1) }

        guard let url = URL(string: ApiConfig.subscriptiponUrl) else {
            return
        }
        let bodyData = urlComponents.query?.data(using: .utf8)

        let apiRequest = APIRequest(
            url: url,
            method: .POST,
            contentType: .formURLEncoded,
            body: bodyData
        )

        NetworkManager.shared.sendRequest(apiRequest) { result in
            switch result {
            case .success(_):
                print(AppConstant.DEVICE_TOKEN, token)
                UserDefaults.isRegistered(isRegister: true)
                print(AppConstant.SUCESSFULLY)
                
                AppStorage.shared.set(token, forKey: AppConstant.IZ_DEVICE_TOKEN)
                AppStorage.shared.set(Utils.getAppVersion(), forKey: AppConstant.iZ_APP_VERSION)
                AppStorage.shared.set(ApiConfig.SDK_VERSION, forKey: AppConstant.iZ_SDK_VERSION)
                let timestamp: TimeInterval = Date().timeIntervalSince1970 * 1000
                AppStorage.shared.set(Int(timestamp), forKey: "unixTS")

                let formattedDate = Date().getFormattedDate()
                if formattedDate != AppStorage.shared.getString(forKey: AppConstant.iZ_KEY_LAST_VISIT) {
                    RestAPI.lastVisit(bundleName: bundleName, pid: pid, token: token)
                    if let props = sharedUserDefault?.dictionary(forKey: AppConstant.iZ_USERPROPERTIES_KEY) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            iZooto.addUserProperties(data: props)
                        }
                    }
                }

            case .failure(let error):
                Utils.handleOnceException(bundleName: bundleName, exceptionName: error.localizedDescription, className: AppConstant.iZ_REST_API_CLASS_NAME, methodName: AppConstant.iZ_REGISTER_TOKEN_METHOD, rid: nil, cid: nil, userInfo: nil)
                print(AppConstant.IZ_TAG, AppConstant.iZ_KEY_DEVICE_TOKEN_ERROR)
            }
        }
    }
}





