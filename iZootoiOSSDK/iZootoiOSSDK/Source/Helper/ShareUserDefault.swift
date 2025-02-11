//
//  ShareUserDefault.swift
//  iZootoiOSSDK
//
//  Created by Amit on 07/02/20.
//  Copyright © 2020 Amit. All rights reserved.
//

import Foundation
struct SharedUserDefault {
    static let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
    static let suitName = Utils.getGroupName(bundleName: bundleName)
    struct Key {
      static let token = "saveToken"
      static let registerID = "izootoid"
    }
    
}
