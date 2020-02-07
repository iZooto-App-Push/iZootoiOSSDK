//
//  UserDefaults.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
struct Constant
{
     let userID = "isUserID"
     let userToken = "userToken"
    let isRegister = "isRegister"
    let userDefault = UserDefaults.standard

}
extension UserDefaults
{
    public static func saveUserID(userID : Int)
    {
      // print(userID)
        Constant().userDefault.set(userID, forKey: Constant().userID)
       // UserDefaults.standard.synchronize()
    }
    public  static func getUserID()->Int
    {
        if  Constant().userDefault.integer(forKey:  Constant().userID) != 0{
            return  Constant().userDefault.integer(forKey: Constant().userID)
        }
        else{
            return 404
        }
    }
    public static func saveUserToken(token: NSString)
    {
         Constant().userDefault.set(token, forKey: Constant().userToken)
       // UserDefaults.standard.synchronize()
    }
    public  static func getUserToken()->NSString
    {
        if  Constant().userDefault.string(forKey: Constant().userToken) != nil{
            return  Constant().userDefault.string(forKey: Constant().userToken)! as NSString
        }
        else
        {
            return "Retry Again"
        }
    }
    public static func isRegistered(isRegister : Bool)
    {
         Constant().userDefault.set(isRegister, forKey:Constant().isRegister)
        //UserDefaults.standard.synchronize()
    }
    public static func getRegistered()->Bool
    {
        if  Constant().userDefault.bool(forKey: Constant().isRegister) != false
        {
            return  Constant().userDefault.bool(forKey: Constant().isRegister)
        }
        else
        {
            return false
        }
    }
}


