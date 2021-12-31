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
    public static var   BASEURL = "https://aevents.izooto.com/app.php"
    public static var   ENCRPTIONURL="https://cdn.izooto.com/app/app_"
    private static var  IMPRESSION_URL="https://impr.izooto.com/imp";
    public static var   LOG = "iZooto :"
    private static var EVENT_URL = "https://et.izooto.com/evt";
    private static var  PROPERTIES_URL="https://prp.izooto.com/prp";
    private static var  CLICK_URL="https://clk.izooto.com/clk";
    private static var  REGISTRATION_URL="https://aevents.izooto.com/app.php";
    private static  var LASTNOTIFICATIONCLICKURL="https://lci.izooto.com/lci";
    private static  var LASTNOTIFICATIONVIEWURL="https://lim.izooto.com/lim";
    private static  var LASTVISITURL="https://lvi.izooto.com/lvi";
    private static var EXCEPTION_URL="https://aerr.izooto.com/aer";
    private static let  SDKVERSION = "1.1.10"

    static func callSubscription(isSubscribe : Int,token : String,userid : Int)
    {
        if(isSubscribe != -1)
        {
        let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
         var requestBodyComponents = URLComponents()
         requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(userid)"),
                                             URLQueryItem(name: "btype", value: "8"),
                                             URLQueryItem(name: "dtype", value: "3"),
                                             URLQueryItem(name: "bver", value: SDKVERSION),
                                             URLQueryItem(name: "ge", value: "1"),
                                             URLQueryItem(name: "action", value: "\(isSubscribe)"),
                                             URLQueryItem(name: "pte", value: "3"),
                                             URLQueryItem(name:"bKey", value: token),
                                             URLQueryItem(name: "os", value: "5"),
                                             URLQueryItem(name: "pt", value: "0")]
         var request = URLRequest(url: URL(string: "https://usub.izooto.com/sunsub")!)
         request.httpMethod = "POST"
         request.allHTTPHeaderFields = requestHeaders
         request.httpBody = requestBodyComponents.query?.data(using: .utf8)
         URLSession.shared.dataTask(with: request){(data,response,error) in
             
            do {
                print("Subscribe","sucess")
            }
         }.resume()
        }
        else
        {
            sendExceptionToServer(exceptionName: "isSubscribe\(isSubscribe)", className: "Rest API", methodName: "callSubscription", accoundID: userid, token: token , rid: "",cid : "")

        }
        
    }
    static  public func getRequest(uuid: String, completionBlock: @escaping (String) -> Void) -> Void
    {
    let requestURL = URL(string: "https://cdn.izooto.com/app/app_\(uuid).dat")
        let request = URLRequest(url: requestURL!)
        let requestTask = URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
           
            if(error != nil) {
                sendExceptionToServer(exceptionName: error?.localizedDescription ?? "not found", className: "Rest API", methodName: "getRequest", accoundID: 0, token: "" , rid: "",cid : "")
                
            }else
            {
                let outputStr  = String(data: data!, encoding: String.Encoding.utf8)!
                completionBlock(outputStr);
            }
        }
        requestTask.resume()
    }
        
    
    static func currentTimeInMilliSeconds()-> Int
      {
          let currentDate = Date()
          let since1970 = currentDate.timeIntervalSince1970
          return Int(since1970 * 1000)
      }

     static func getDeviceName()->String
     {
        let name = UIDevice.current.model
        return name
       
    }
    static func getUUID()->String
    {
        let device_id = UIDevice.current.identifierForVendor!.uuidString
        
        return device_id

    }
      
       static func  getVersion() -> String {
        return UIDevice.current.systemVersion

      }
    
   static func getAppInfo()->String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
       return version
    }
    static func getAppName()->String {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        return appName
    }
    static func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    static func getAppVersion() -> String {
           let dictionary = Bundle.main.infoDictionary!
           let version = dictionary["CFBundleShortVersionString"] as! String
           return "\(version)"
       }

    
     static func callEvents(eventName : String, data : NSString,userid : Int,token : String)
      {
        if( eventName != " "  && data != nil){
            let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(userid)"),
                                                URLQueryItem(name: "act", value: "\(eventName)"),
                                                URLQueryItem(name: "et", value: "evt"),
                                                URLQueryItem(name: "val", value: "\(data)"),
                                                URLQueryItem(name:"bKey", value: token)]
            var request = URLRequest(url: URL(string: RestAPI.EVENT_URL)!)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
               do {
                   print(AppConstant.ADD_EVENT)
                   sharedUserDefault?.set("", forKey:"AddEvents")
                   sharedUserDefault?.set("", forKey: "EventName")
               }
            }.resume()
        
        }
        else{
            print(AppConstant.ERROR_EVENT)
                sendExceptionToServer(exceptionName: "User Event name and  data are blank", className: "Rest API", methodName: "callEvents", accoundID: userid, token: token , rid: "",cid : "")
        }
          
      }
     static func callUserProperties( data : NSString,userid : Int,token : String)
         {
        if( data != "" ){
            let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(userid)"),
                                                URLQueryItem(name: "act", value: "add"),
                                                URLQueryItem(name: "et", value: "userp"),
                                                URLQueryItem(name: "val", value: "\(data)"),
                                                URLQueryItem(name:"bKey", value: token)]
            var request = URLRequest(url: URL(string: RestAPI.PROPERTIES_URL)!)
            request.httpMethod = "POST"
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
                 sendExceptionToServer(exceptionName: "User Properties data are blank", className: "Rest API", methodName: "callUserProperties", accoundID: userid, token: token , rid: "",cid : "")
             }
         }
     static func callImpression(notificationData : Payload,userid : Int,token : String)
    {
        if(notificationData != nil && userid != 0 && token != nil)
         {
        let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(userid)"),
                                            URLQueryItem(name: "cid", value: "\(notificationData.id!)"),
                                            URLQueryItem(name: "rid", value: "\(notificationData.rid!)"),
                                            URLQueryItem(name: "op", value: "view"),
                                            URLQueryItem(name: "ver", value: SDKVERSION),
                                            URLQueryItem(name:"bKey", value: token)]
        var request = URLRequest(url: URL(string: "https://impr.izooto.com/imp")!)
        request.httpMethod = "POST"
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
         sendExceptionToServer(exceptionName: "Notification payload is not loading", className: "Rest API", methodName: "clickTrack", accoundID: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")
           
        }
        
    }
     static func clickTrack(notificationData : Payload,type : String, userid : Int,token : String)
    {
       if(notificationData != nil && userid != 0 && token != nil)
        {
        let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(userid)"),
                                            URLQueryItem(name: "cid", value: "\(notificationData.id!)"),
                                            URLQueryItem(name: "rid", value: "\(notificationData.rid!)"),
                                            URLQueryItem(name: "op", value: "click"),
                                            URLQueryItem(name: "ver", value: SDKVERSION),
                                            URLQueryItem(name: "btn", value: "\(type)"),
                                            URLQueryItem(name:"bKey", value: token)]
        var request = URLRequest(url: URL(string: RestAPI.CLICK_URL)!)
        request.httpMethod = "POST"
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
           
            sendExceptionToServer(exceptionName: "Notification payload is not loading", className: "Rest API", methodName: "clickTrack", accoundID: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")

           
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
    
    @objc public static func identifierForAdvertising() -> String? {
        if #available(iOS 14, *) {
            
            guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
                return "0000-0000-0000-0000"
            }
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString

            
        }
        else {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    }
    @objc static func lastVisit(userid : Int,token : String)
    {
        if(token != nil && userid != 0)
        {
        let data = ["last_website_visit":"true","lang":"en"] as [String:String]
        if let theJSONData = try?  JSONSerialization.data(withJSONObject: data,options: .fragmentsAllowed),
           let validationData = NSString(data: theJSONData,encoding: String.Encoding.utf8.rawValue) {
            let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(userid)"),
                                                URLQueryItem(name: "act", value: "add"),
                                                URLQueryItem(name: "isid", value: "1"),
                                                URLQueryItem(name: "et", value: "userp"),
                                                URLQueryItem(name: "val", value: "\(validationData)"),
                                                URLQueryItem(name:"bKey", value: token)]
            var request = URLRequest(url: URL(string: RestAPI.LASTVISITURL)!)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = requestHeaders
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            URLSession.shared.dataTask(with: request){(data,response,error) in
                
               do {
                print("l","v")
                
               }
            }.resume()
            
            
          
          }
        }
        else
        {
                sendExceptionToServer(exceptionName: "Token or  pid or missing", className: "Rest API", methodName: "lastImpression", accoundID: userid, token: token , rid: "",cid :"")
        }
        
    }
  @objc   static func lastImpression(notificationData : Payload,userid : Int,token : String)
    {
       if(notificationData != nil && userid != 0 && token != nil)
        {
        let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(userid)"),
                                        URLQueryItem(name: "cid", value: "\(notificationData.id!)"),
                                        URLQueryItem(name: "rid", value: "\(notificationData.rid!)"),
                                        URLQueryItem(name: "op", value: "view"),
                                        URLQueryItem(name:"bKey", value: token)]
    var request = URLRequest(url: URL(string: RestAPI.LASTNOTIFICATIONVIEWURL)!)
    request.httpMethod = "POST"
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
           
            sendExceptionToServer(exceptionName: "Notification payload is not loading", className: "Rest API", methodName: "lastImpression", accoundID: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")

           
        }
    

        
    }
   @objc   static func lastClick(notificationData : Payload,userid : Int,token : String)
    {
    if(userid != 0 && token != nil && notificationData != nil)
        {
    let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
    var requestBodyComponents = URLComponents()
    requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(userid)"),
                                        URLQueryItem(name: "cid", value: "\(notificationData.id!)"),
                                        URLQueryItem(name: "rid", value: "\(notificationData.rid!)"),
                                        URLQueryItem(name: "op", value: "view"),
                                        URLQueryItem(name:"bKey", value: token)]
    var request = URLRequest(url: URL(string: RestAPI.LASTNOTIFICATIONCLICKURL)!)
    request.httpMethod = "POST"
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
            sendExceptionToServer(exceptionName: "Notification payload is not loading", className: "Rest API", methodName: "lastClick", accoundID: userid, token: token , rid: notificationData.rid ?? "no rid value here",cid : notificationData.id ?? "no cid value here")

        }
   
    }
    @objc  static func registerToken(token : String, izootoid : Int)
    {
        if(token != nil && izootoid != 0)
       {
        let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(izootoid)"),
                                            URLQueryItem(name: "btype", value: "8"),
                                            URLQueryItem(name: "dtype", value: "3"),
                                            URLQueryItem(name: "tz", value:"\(currentTimeInMilliSeconds())"),
                                            URLQueryItem(name: "bver", value:"\(getAppVersion())"),
                                            URLQueryItem(name: "os", value: "5"),
                                            URLQueryItem(name:"bKey", value: token),
                                            URLQueryItem(name: "av", value: SDKVERSION),
                                            URLQueryItem(name: "adid", value: identifierForAdvertising()!),
                                            URLQueryItem(name: "osVersion", value: "\(getVersion())"),
                                            URLQueryItem(name: "deviceName", value: "\(getDeviceName())"),
                                            URLQueryItem(name: "check", value: "\(getAppVersion())")]
        var request = URLRequest(url: URL(string: RestAPI.BASEURL)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        URLSession.shared.dataTask(with: request){(data,response,error) in
            
            do {
                print(AppConstant.DEVICE_TOKEN,token)
                UserDefaults.isRegistered(isRegister: true)
                 print(AppConstant.SUCESSFULLY)
                let date = Date()
                let format = DateFormatter()
                format.dateFormat = "yyyy-MM-dd"
                let formattedDate = format.string(from: date)
                if(formattedDate != (sharedUserDefault?.string(forKey: "LastVisit")))
                {
                    RestAPI.lastVisit(userid: izootoid, token:token)
                    sharedUserDefault?.set(formattedDate, forKey: "LastVisit")
                    let dicData = sharedUserDefault?.dictionary(forKey:"UserPropertiesData")
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
        print("Device Token is not generating from this device")
           sendExceptionToServer(exceptionName: "Device Token or pid is not generating properly", className: "Rest API", methodName: "registerToken", accoundID: 0, token: "", rid: "", cid: "")
           
       }
      
    
    }
    @objc static func registerToken(token : String, izootoid : Int ,adid : NSString)
    {
        if(token != nil && izootoid != 0)
        {
         let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
         var requestBodyComponents = URLComponents()
         requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(izootoid)"),
                                             URLQueryItem(name: "btype", value: "8"),
                                             URLQueryItem(name: "dtype", value: "3"),
                                             URLQueryItem(name: "tz", value:"\(currentTimeInMilliSeconds())"),
                                             URLQueryItem(name: "bver", value:"\(getAppVersion())"),
                                             URLQueryItem(name: "os", value: "5"),
                                             URLQueryItem(name:"bKey", value: token),
                                             URLQueryItem(name: "av", value:SDKVERSION),
                                             URLQueryItem(name: "adid", value: adid as String),
                                             URLQueryItem(name: "osVersion", value: "\(getVersion())"),
                                             URLQueryItem(name: "deviceName", value: "\(getDeviceName())"),
                                             URLQueryItem(name: "check", value: "\(getAppVersion())")]
         var request = URLRequest(url: URL(string: RestAPI.BASEURL)!)
         request.httpMethod = "POST"
         request.allHTTPHeaderFields = requestHeaders
         request.httpBody = requestBodyComponents.query?.data(using: .utf8)
         URLSession.shared.dataTask(with: request){(data,response,error) in
             
             do {
                 sharedUserDefault?.set(true,forKey: "AdvertisementID")
                 sharedUserDefault?.set("", forKey: "ADID")
                 print("Successfully added ",adid as String)



             }
         }.resume()
        }
         else
        {
            sharedUserDefault?.set(false,forKey: "AdvertisementID")
         sendExceptionToServer(exceptionName: "Device Token or pid is not generating properly", className: "Rest API", methodName: "registerToken", accoundID: 0, token: "", rid: "", cid: "")

        }
    }
    static func sendExceptionToServer(exceptionName : String ,className : String ,methodName: String,accoundID :Int ,token : String,rid : String,cid : String)
    
    {
        let requestHeaders:[String:String] = ["Content-Type":"application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [URLQueryItem(name: "pid", value: "\(accoundID)"),
                                            URLQueryItem(name: "exceptionName", value: "\(exceptionName)"),
                                            URLQueryItem(name: "methodName", value: "\(methodName)"),
                                            URLQueryItem(name: "className", value:"\(className))"),
                                            URLQueryItem(name: "bKey", value: token),
                                            URLQueryItem(name: "av", value: SDKVERSION),
                                            URLQueryItem(name: "rid", value: "\(rid)"),
                                            URLQueryItem(name: "cid", value: "\(cid)"),
                                            URLQueryItem(name: "osVersion", value: "\(getVersion())"),
                                            URLQueryItem(name: "deviceName", value: "\(getDeviceName())"),
                                            URLQueryItem(name: "check", value: "\(getAppVersion())")]
        var request = URLRequest(url: URL(string: RestAPI.EXCEPTION_URL)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        URLSession.shared.dataTask(with: request){(data,response,error) in
            
            do {
               // print("Send Exception successfully on server" )



            }
        }.resume()
       }
      
    }
   




