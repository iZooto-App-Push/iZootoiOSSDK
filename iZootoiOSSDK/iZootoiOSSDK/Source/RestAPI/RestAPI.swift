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
   public static func registerToken(token : String, izootoid : Int)
    {
        var request = URLRequest(url: URL(string: "https://aevents.izooto.com/app.php?s=2&pid=\(izootoid)&btype=8&dtype=3&tz=1575457865071&bver=12&os=5&allowed=1&bKey=\(token)&check=1")!)
                request.httpMethod = "GET"

                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    do {
                       print("Token",token)
                      print(RestAPI.LOG,"Registration Successfull")

                    }
                }).resume()

                 
             }
    public static func callImpression(notificationData : Aps,userid : Int,token : String)
    {
        var request = URLRequest(url: URL(string: "https://impr.izooto.com/imp?pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=\(token)&op=view")!)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                 print("StatusCode","Track\(token)")
                }
            }).resume()

        
    }
    public static func clickTrack(notificationData : Aps,type : String, userid : Int,token : String)
    {
        var request = URLRequest(url: URL(string: "https://clk.izooto.com/clk?pid=\(userid)&cid=\(notificationData.id!)&rid=\(notificationData.rid!)&bKey=7e7ec936e7cde9b3b0e2381ef018392891f8c8e35919f1fe6dd76d20ff54c8b&op=click&btn=\(type)&ver=\(UIDevice.current.systemVersion)")!)
                   request.httpMethod = "GET"
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



