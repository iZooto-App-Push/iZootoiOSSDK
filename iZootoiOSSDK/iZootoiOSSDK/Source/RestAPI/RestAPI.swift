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
protocol ResponseHandler  : AnyObject{
    func onSuccess()
    func onFailure()
}
public class RestAPI
{
    public static var BASEURL = "https://aevents.izooto.com/"
    public static var ENCRPTIONURL="https://cdn.izooto.com/app/app_"
    public static var  IMPRESSION_URL="https://impr.izooto.com/imp?";
    public static var LOG = "iZooto :"
    public static  var EVENT_URL = "https://et.izooto.com/evt";
    public static var  PROPERTIES_URL="https://prp.izooto.com/prp";


   public static func registerToken(token : String, izootoid : Int)
    {
       
        var request = URLRequest(url: URL(string: "https://aevents.izooto.com/app.php?s=2&pid=\(izootoid)&btype=8&dtype=3&tz=\(currentTimeInMilliSeconds())&bver=\(getVersion())&os=5&allowed=1&bKey=\(token)&check=\(getAppVersion())&deviceName=\(getDeviceName())&osVersion=\(getVersion())")!)
        
                request.httpMethod = "GET"

                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    do {
                       print("Token",token)
                     UserDefaults.isRegistered(isRegister: true)

                      print(RestAPI.LOG,"Registration Successfull")

                    }
                }).resume()

                 
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
        if name != nil{
            return name}
        else{
         return "iOS"
        }
    }
      
       static func  getVersion() -> String {
          return UIDevice.current.systemVersion

      }
    static func getAppVersion() -> String {
           let dictionary = Bundle.main.infoDictionary!
           let version = dictionary["CFBundleShortVersionString"] as! String
           return "\(version)"
       }

    
    public static func callEvents(eventName : String, data : NSString,userid : Int,token : String)
      {
              if(eventName != nil && data != nil ){
        let escapedString = data.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)
                var request = URLRequest(url: URL(string: RestAPI.EVENT_URL+"?pid=\(userid)&act=\(eventName)&et=evt&bKey=\(token)&val=\(escapedString!)")!)
                           request.httpMethod = "POST"
                           URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                               do {
                                print("Add Event","Sucessfully")
                               }
                            }).resume()

        
        }
        else{
            print("Event : Some error occured")
        }
        

          
      }
    public static func callUserProperties( data : NSString,userid : Int,token : String)
         {
        if( data != nil ){
           
              let userpropertiesData = data.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)

            var request = URLRequest(url: URL(string: RestAPI.PROPERTIES_URL+"?pid=\(userid)&act=add&et=userp&bKey=\(token)&val=\(userpropertiesData!)")!)
                              request.httpMethod = "POST"
                              URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                                  do {
                                   print("Add User Properties","Sucessfully")
                                  }
                               }).resume()
                        }
            else{
               print("User Properties : Some error occured")
                }
         }
    public static func callImpression(notificationData : Payload,userid : Int,token : String)
    {
       
        
        var request = URLRequest(url: URL(string: "https://impr.izooto.com/imp?pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=\(token)&op=view")!)

            request.httpMethod = "POST"
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                 print("Recevied","Notification Recevied")
                }
            }).resume()

        
    }
    public static func clickTrack(notificationData : Payload,type : String, userid : Int,token : String)
    {
        var request = URLRequest(url: URL(string: "https://clk.izooto.com/clk?pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=\(token)&op=click&btn=\(type)&ver=\(getVersion())")!)
         print("Data","https://clk.izooto.com/clk?pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=\(token)&op=click&btn=\(type)&ver=\(getAppVersion())")
                   request.httpMethod = "POST"
                   URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                       do {
                        print("StatusCode","Clicks")
                        
                       }
                   }).resume()

    }
    public static func performRequest(with urlString : String)
    {
        if let url = URL(string: urlString)
        {
            let session = URLSession(configuration: .default)
            let task  = session.dataTask(with: url)
            {(data,response,error)in
                if error != nil
                {
                    print("Error")
                    return
                }
                if data != nil{
                    print("Success")
                }
                
            }
            task.resume()
        }
    }
    
         
}



