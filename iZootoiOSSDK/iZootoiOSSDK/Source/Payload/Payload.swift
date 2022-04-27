//
//  Payload.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
@objc
public class Payload  : NSObject{
    public var alert : Alert?
    public var key : Int?
    public var id : String? // int
    public var sound : String?
    public var category : String?
    public var badge : Int?
    public var rid : String?
    public var ttl : Int?
    public var tag : String?
    public var created_on : Int?
    public var reqInt : Int?
    public var mutablecontent : Int?
    public var url : String?
    public var icon : String?
    public var act1id : String?
    public var act1name : String?
    public var act1link : String?
    public var act2id : String?
    public var act2name : String?
    public var act2link : String?
    public var ap : String?
    public var fetchurl : String?
    public var cfg : String?
    public var inApp : String?
    public var relevence_score : Double?
    public var interrutipn_level : Int?


    public class func modelsFromDictionaryArray(array:NSArray) -> [Payload]
    {
        var models:[Payload] = []
        for item in array
        {
            models.append(Payload(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    required public init?(dictionary: NSDictionary) {
        if (dictionary["alert"] != nil) { alert = Alert(dictionary: dictionary["alert"] as! NSDictionary) }
        key = dictionary["k"] as? Int    // key
        id = dictionary["id"] as? String   // id
        sound = dictionary["su"] as? String //sound
        category = dictionary["category"] as? String  // category
        badge = dictionary["badge"] as? Int   //badge
        rid = dictionary["r"] as? String  // rid
        ttl = dictionary["tl"] as? Int  // ttl
        tag = dictionary["tg"] as? String   //tag
        created_on = dictionary["ct"] as? Int  // created_on
        reqInt = dictionary["ri"] as? Int   //required Int
        mutablecontent = dictionary["mutable-content"] as? Int
        url = dictionary["ln"] as? String   // link
      //  icon = dictionary["icon"] as? String
        act1name = dictionary["b1"] as? String  // button1 name
        act1link = dictionary["l1"] as? String  // button 1link
        act2name = dictionary["b2"] as? String   // button 2 name
        act2link = dictionary["l2"] as? String    // button 2 link
        ap = dictionary["ap"] as? String          // additional parameeter
        cfg = dictionary["cfg"] as? String           // cfg
        fetchurl = dictionary["fu"] as? String    // fetch_url
        inApp = dictionary["ia"] as? String          // inApp
        act1id = dictionary["d1"] as? String //action1 id
        act2id = dictionary["d2"] as? String // action2 id
        relevence_score = dictionary["rs"] as? Double // relevance score
        interrutipn_level = dictionary["il"] as? Int // interruption level
    }
public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.alert?.dictionaryRepresentation(), forKey: "alert")
        dictionary.setValue(self.key, forKey: "k")
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.sound, forKey: "su")
        dictionary.setValue(self.category, forKey: "category")
        dictionary.setValue(self.badge, forKey: "badge")
        dictionary.setValue(self.rid, forKey: "r")
        dictionary.setValue(self.ttl, forKey: "tl")
        dictionary.setValue(self.tag, forKey: "tg")
        dictionary.setValue(self.created_on, forKey: "ct")
        dictionary.setValue(self.reqInt, forKey: "ri")
        dictionary.setValue(self.mutablecontent, forKey: "mutable-content")
        dictionary.setValue(self.url, forKey: "ln")
     //   dictionary.setValue(self.icon, forKey: "icon")
        dictionary.setValue(self.act1name, forKey: "b1")
        dictionary.setValue(self.act1link, forKey: "l1")
        dictionary.setValue(self.act2name, forKey: "b2")
        dictionary.setValue(self.act2link, forKey: "l2")
        dictionary.setValue(self.ap, forKey: "ap")
        dictionary.setValue(self.cfg, forKey: "cfg")
        dictionary.setValue(self.fetchurl, forKey: "fu")
        dictionary.setValue(self.inApp, forKey: "ia")
        dictionary.setValue(self.act1id, forKey: "d1")
        dictionary.setValue(self.act2id, forKey: "d2")
        dictionary.setValue(self.relevence_score, forKey:"rs")
        dictionary.setValue(self.interrutipn_level, forKey: "il")


        return dictionary
    }

}
public class Alert {
    public var title : String?
    public var subtitle : String?
    public var body : String?
    public var attachment_url : String?
    public class func modelsFromDictionaryArray(array:NSArray) -> [Alert]
    {
        var models:[Alert] = []
        for item in array
        {
            models.append(Alert(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    required public init?(dictionary: NSDictionary) {

        title = dictionary["title"] as? String //title
        subtitle = dictionary["subtitle"] as? String//subtitle
        body = dictionary["body"] as? String//body
        attachment_url = dictionary["attachment-url"] as? String//attachment-url
    }
public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.title, forKey: "title")  //title
        dictionary.setValue(self.subtitle, forKey: "subtitle")  //subtitle
        dictionary.setValue(self.body, forKey: "body")  //body
        dictionary.setValue(self.attachment_url, forKey: "attachment_url") // attachment_url
        return dictionary
    }

}

public class iZootoBase {
    public var aps : Payload?
    public class func modelsFromDictionaryArray(array:NSArray) -> [iZootoBase]
    {
        var models:[iZootoBase] = []
        for item in array
        {
            models.append(iZootoBase(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    required public init?(dictionary: NSDictionary) {

        if (dictionary["aps"] != nil) { aps = Payload(dictionary: dictionary["aps"] as! NSDictionary) }
    }
   public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.aps?.dictionaryRepresentation(), forKey: "aps")

        return dictionary
    }

}





