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
    public var ankey : AnKey?
    public var global : Global?
    public var key : Int?
    public var id : String? // int
    public var sound : String?
    public var category : String?
    public var badge : Int?
    public var rid : String?
    public var ttl : Int?
    public var tag : String?
    public var created_on : String?
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
    public var relevance_score : Double?
    public var interrutipn_level : Int?
    public var furv : [String]?
    public var furc : [String]?
    public var finalBids: [String: Any]?
    
    internal class func modelsFromDictionaryArray(array:NSArray) -> [Payload]
    {
        var models:[Payload] = []
        for item in array {
            if let dictionary = item as? NSDictionary {
                if let payload = Payload(dictionary: dictionary) {
                    models.append(payload)
                }
            }
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        if let dicti = dictionary["an"] as? NSArray, dicti.count > 0, let dictt = dicti[0] as? NSDictionary {
            ankey = AnKey(dictionary: dictt)
        }
        
        if let dictionary = dictionary["alert"] as? NSDictionary {
            alert = Alert(dictionary: dictionary)
        }
        if let gData = dictionary["g"] as? NSDictionary {
            global = Global(dictionary: gData)
        }
        
        key = dictionary["k"] as? Int    // key
        id = dictionary["id"] as? String   // id
        sound = dictionary["su"] as? String //sound
        category = dictionary["category"] as? String  // category
        badge = dictionary["badge"] as? Int   //badge
        rid = dictionary["r"] as? String  // rid
        ttl = dictionary["tl"] as? Int  // ttl
        tag = dictionary["tg"] as? String   //tag
        created_on = dictionary["ct"] as? String   // created_on
        reqInt = dictionary["ri"] as? Int   //required Int
        mutablecontent = dictionary["mutable-content"] as? Int
        url = dictionary["ln"] as? String   // link
        if let url0 = dictionary["ln"] as? String {
            self.url = Utils.addMacros(url: url0)
        }
        //  icon = dictionary["icon"] as? String
        act1name = dictionary["b1"] as? String  // button1 name
        act1link = dictionary["l1"] as? String  // button 1link
        if let url1 = dictionary["l1"] as? String {
            act1link = Utils.addMacros(url: url1)
        }
        act2name = dictionary["b2"] as? String   // button 2 name
        act2link = dictionary["l2"] as? String    // button 2 link
        if let url2 = dictionary["l2"] as? String {
            act2link = Utils.addMacros(url: url2)
        }
        ap = dictionary["ap"] as? String          // additional parameeter
        cfg = dictionary["cfg"] as? String           // cfg
        fetchurl = dictionary["fu"] as? String    // fetch_url
        if let fetch = dictionary["fu"] as? String {
            fetchurl = Utils.addMacros(url: fetch)
        }
        inApp = dictionary["ia"] as? String          // inApp
        act1id = dictionary["d1"] as? String //action1 id
        act2id = dictionary["d2"] as? String // action2 id
        relevance_score = dictionary["rs"] as? Double // relevance score
        interrutipn_level = dictionary["il"] as? Int // interruption level
        
        if let rcDict = dictionary["rc"] as? [String]{
            if rcDict.count > 0 {
                furc = rcDict
            }
        }
        
        if let rvDict = dictionary["rv"] as? [String]{
            if rvDict.count > 0 {
                furv = rvDict
            }
        }
        finalBids = dictionary["fb"] as? [String: Any]
    }
    
    
    internal func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.alert?.dictionaryRepresentation(), forKey: "alert")
        dictionary.setValue(self.ankey?.dictionaryRepresentation(), forKey: "an")
        dictionary.setValue(self.global?.dictionaryRepresentation(), forKey: "g")
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
        dictionary.setValue(self.relevance_score, forKey:"rs")
        dictionary.setValue(self.interrutipn_level, forKey: "il")
        dictionary.setValue(self.furc, forKey: "rc")
        dictionary.setValue(self.furv, forKey: "rv")
        dictionary.setValue(self.finalBids, forKey: "fb")
        
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
            if let dictionary = item as? NSDictionary {
                if let alert = Alert(dictionary: dictionary) {
                    models.append(alert)
                }
            }
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

public class AnKey {
    public var bannerImageAd : String?
    public var cpmAd : String?
    public var fetchUrlAd : String?
    public var idAd : String?
    public var landingUrlAd : String?
    public var messageAd : String?
    public var titleAd : String?
    public var adrv : [String]?
    public var adrc : [String]?
    public var act1link: String?
    public var act2link: String?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [AnKey]
    {
        var models:[AnKey] = []
        for item in array
        {
            if let dictionary = item as? NSDictionary {
                if let anKey = AnKey(dictionary: dictionary) {
                    models.append(anKey)
                }
            }
        }
        return models
    }
    required public init?(dictionary: NSDictionary) {
        
        bannerImageAd = dictionary["bi"] as? String//attachment-url
        cpmAd = dictionary["cpm"] as? String //CPMValue
        fetchUrlAd = dictionary["fu"] as? String // Ad- FetchUrl
        idAd = dictionary["id"] as? String // Ad- id
        messageAd = dictionary["m"] as? String // Ad-Message
        titleAd = dictionary["t"] as? String //title-Ad
        landingUrlAd = dictionary["ln"] as? String //landingUrl - Ad
        act1link = dictionary["l1"] as? String
        act2link = dictionary["l2"] as? String
        
        if let rcDict = dictionary["rc"] as? [String]{
            if rcDict.count > 0 {
                adrc = rcDict
            }
        }
        
        if let rvDict = dictionary["rv"] as? [String]{
            if rvDict.count > 0 {
                adrv = rvDict
            }
        }
    }
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.bannerImageAd, forKey: "bi")
        dictionary.setValue(self.cpmAd, forKey: "cpm")
        dictionary.setValue(self.fetchUrlAd, forKey: "fu")
        dictionary.setValue(self.idAd, forKey: "id")
        dictionary.setValue(self.messageAd, forKey: "m")
        dictionary.setValue(self.titleAd, forKey: "t")
        dictionary.setValue(self.landingUrlAd, forKey: "ln")
        
        dictionary.setValue(self.adrc, forKey: "rc")
        dictionary.setValue(self.adrv, forKey: "rv")
        
        return dictionary
    }
}

public class Global {
    
    public var act1name : String?
    public var act1Id : String?
    public var act2name : String?
    public var act2Id : String?
    public var act1link : String?
    public var act2link : String?
    public var cfg : String?
    public var created_on : String?
    public var inApp : String?
    public var id : String? // int
    public var key : Int?
    public var rid : String?
    public var reqInt : Int?
    public var tag : String?
    public var ttl : String?
    public var type : String?
    public var adCategory : String?
    
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [Global]
    {
        var models:[Global] = []
        for item in array
        {
            if let dictionary = item as? NSDictionary{
                if let global = Global(dictionary: dictionary){
                    models.append(global)
                }
            }
        }
        return models
    }
    required public init?(dictionary: NSDictionary) {
        
        act1name = dictionary["b1"] as? String  // button1 name
        act1Id = dictionary["d1"] as? String  // button1 Id
        act2name = dictionary["b2"] as? String  // button2 name
        act2Id = dictionary["d2"] as? String  // button2 Id
        act1link = dictionary["l1"] as? String
        act2link = dictionary["l2"] as? String
        cfg = dictionary["cfg"] as? String     // cfg
        created_on = dictionary["ct"] as? String // created_on
        inApp = dictionary["ia"] as? String   // inApp
        id = dictionary["id"] as? String   // id
        key = dictionary["k"] as? Int      // key
        rid = dictionary["r"] as? String   // rid
        reqInt = dictionary["ri"] as? Int   //required Int
        tag = dictionary["tg"] as? String   //tag
        ttl = dictionary["tl"] as? String   // tag
        type = dictionary["tp"] as? String //type
        adCategory = dictionary["category"] as? String //Ad-Category
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.act1name, forKey: "b1")
        dictionary.setValue(self.act1Id, forKey: "d1")
        dictionary.setValue(self.act2name, forKey: "b2")
        dictionary.setValue(self.act2Id, forKey: "d2")
        dictionary.setValue(self.act1link, forKey: "l1")
        dictionary.setValue(self.act2link, forKey: "l2")
        dictionary.setValue(self.cfg, forKey: "cfg")
        dictionary.setValue(self.created_on, forKey: "ct")
        dictionary.setValue(self.inApp, forKey: "ia")
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.key, forKey: "k")
        dictionary.setValue(self.rid, forKey: "r")
        dictionary.setValue(self.reqInt, forKey: "ri")
        dictionary.setValue(self.tag, forKey: "tg")
        dictionary.setValue(self.ttl, forKey: "tl")
        dictionary.setValue(self.type, forKey: "tp")
        dictionary.setValue(self.adCategory, forKey: "category")
        
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
            if let dictionary = item as? NSDictionary{
                if let izootoBase = iZootoBase(dictionary: dictionary) {
                    models.append(izootoBase)
                }
            }
        }
        return models
    }
    required public init?(dictionary: NSDictionary) {
        
        if (dictionary["aps"] != nil) {
            if let dictionary = dictionary["aps"] as? NSDictionary {
                aps = Payload(dictionary: dictionary)
            }
        }
    }
    public func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.aps?.dictionaryRepresentation(), forKey: "aps")
        
        return dictionary
    }
    
}





