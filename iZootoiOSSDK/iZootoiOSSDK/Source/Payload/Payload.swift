//
//  Payload.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
public class Aps {
    public var alert : Alert?
    public var key : Int?
    public var id : Int?
    public var sound : String?
    public var category : String?
    public var badge : Int?
    public var rid : Int?
    public var ttl : Int?
    public var tag : String?
    public var created_on : Int?
    public var reqInt : Int?
    public var mutablecontent : Int?
    public var url : String?
    public var icon : String?
    public var act1name : String?
    public var act1link : String?
    public var act2name : String?
    public var act2link : String?


    public class func modelsFromDictionaryArray(array:NSArray) -> [Aps]
    {
        var models:[Aps] = []
        for item in array
        {
            models.append(Aps(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    required public init?(dictionary: NSDictionary) {
        if (dictionary["alert"] != nil) { alert = Alert(dictionary: dictionary["alert"] as! NSDictionary) }
        key = dictionary["key"] as? Int
        id = dictionary["id"] as? Int
        sound = dictionary["sound"] as? String
        category = dictionary["category"] as? String
        badge = dictionary["badge"] as? Int
        rid = dictionary["rid"] as? Int
        ttl = dictionary["ttl"] as? Int
        tag = dictionary["tag"] as? String
        created_on = dictionary["created_on"] as? Int
        reqInt = dictionary["reqInt"] as? Int
        mutablecontent = dictionary["mutable-content"] as? Int
        url = dictionary["url"] as? String
        icon = dictionary["icon"] as? String
        act1name = dictionary["act1name"] as? String
        act1link = dictionary["act1link"] as? String
        act2name = dictionary["act2name"] as? String
        act2link = dictionary["act2link"] as? String
    }
public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.alert?.dictionaryRepresentation(), forKey: "alert")
        dictionary.setValue(self.key, forKey: "key")
        dictionary.setValue(self.id, forKey: "id")
        dictionary.setValue(self.sound, forKey: "sound")
        dictionary.setValue(self.category, forKey: "category")
        dictionary.setValue(self.badge, forKey: "badge")
        dictionary.setValue(self.rid, forKey: "rid")
        dictionary.setValue(self.ttl, forKey: "ttl")
        dictionary.setValue(self.tag, forKey: "tag")
        dictionary.setValue(self.created_on, forKey: "created_on")
        dictionary.setValue(self.reqInt, forKey: "reqInt")
        dictionary.setValue(self.mutablecontent, forKey: "mutable-content")
        dictionary.setValue(self.url, forKey: "url")
        dictionary.setValue(self.icon, forKey: "icon")
        dictionary.setValue(self.act1name, forKey: "act1name")
        dictionary.setValue(self.act1link, forKey: "act1link")
        dictionary.setValue(self.act2name, forKey: "act2name")
        dictionary.setValue(self.act2link, forKey: "act2link")

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

        title = dictionary["title"] as? String
        subtitle = dictionary["subtitle"] as? String
        body = dictionary["body"] as? String
        attachment_url = dictionary["attachment-url"] as? String
    }
public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.title, forKey: "title")
        dictionary.setValue(self.subtitle, forKey: "subtitle")
        dictionary.setValue(self.body, forKey: "body")
        dictionary.setValue(self.attachment_url, forKey: "attachment_url")
        return dictionary
    }

}

public class iZootoBase {
    public var aps : Aps?
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

        if (dictionary["aps"] != nil) { aps = Aps(dictionary: dictionary["aps"] as! NSDictionary) }
    }
   public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()

        dictionary.setValue(self.aps?.dictionaryRepresentation(), forKey: "aps")

        return dictionary
    }

}





