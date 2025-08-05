//
//  BadgeManager.swift
//  Pods
//
//  Created by Rambali Kumar on 06/05/25.
//

import Foundation

final class BadgeManager {
    
    static let shared = BadgeManager()
    
    private init() {}
    
    func handleBadgeStatus(_ status: String?, bundleName: String) {
        guard let status = status,
              let groupName = Utils.getGroupName(bundleName: bundleName) else {
            return
        }
        
        AppStorage.shared.configureAppGroup(groupName)
        
        switch status {
        case "1":
            enableDynamicBadge()
        case "2":
            enableStaticBadge()
        case "0":
            disableBadge()
        default:
            print("Unknown badge status: \(status)")
        }
        
    }
    
    private func enableDynamicBadge() {
        AppStorage.shared.set(false, forKey: "badgeViaFunction")
        AppStorage.shared.set("enableBadge", forKey: "isBadgeEnabled")
        
        let count = AppStorage.shared.getInt(forKey: "Badge")
        AppStorage.shared.set(max(count, 0), forKey: "Badge")
    }
    
    private func enableStaticBadge() {
        AppStorage.shared.set(false, forKey: "badgeViaFunction")
        AppStorage.shared.set("staticBadge", forKey: "isBadgeEnabled")
    }
    
    private func disableBadge() {
        AppStorage.shared.set(false, forKey: "badgeViaFunction")
        AppStorage.shared.set("disableBadge", forKey: "isBadgeEnabled")
        AppStorage.shared.set(0, forKey: "Badge")
    }
    
    //notification handler: on notification click
    func handleBadgeCount(bundleName: String) {
        let isBadgeEnabled = AppStorage.shared.getBool(forKey: "isBadge")
        var badgeCount = AppStorage.shared.getInt(forKey: "Badge")
        var notificationCount: Int = 0
        
        if isBadgeEnabled {
            let badgeLimit = AppStorage.shared.getInt(forKey: "BADGECOUNT")
            if badgeLimit == 2 {
                badgeCount = 0
                notificationCount = 0
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            }else if badgeLimit == 1 {
                badgeCount = 0
                notificationCount = 0
            }else{
                badgeCount = max(badgeCount - 1, 0)
                notificationCount = badgeCount
            }
        } else {
            badgeCount = 0
        }
        AppStorage.shared.set(badgeCount, forKey: "Badge")
        updateBadge(to: notificationCount)
    }
    
    func updateBadge(to count: Int) {
      if #available(iOS 16.0, *) {
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
          if let error = error {
            print("Error updating badge: \(error.localizedDescription)")
          }
        }
      } else {
        UIApplication.shared.applicationIconBadgeNumber = count
      }
    }
}
