//
//  NotificationCategoryManager.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 09/06/25.
//

import Foundation
import UserNotifications

final class NotificationCategoryManager {
    
    static let shared = NotificationCategoryManager()
    private init() {}
    
    private var categoryArray: [[String: Any]] = []
    
    // MARK: - Store Category & Buttons
    @objc func storeCategories(notificationData: Payload, category: String) {
        categoryArray.removeAll()
        
        var categoryId = ""
        var button1Name = ""
        var button2Name = ""
        
        if !category.isEmpty {
            categoryId = category
            button1Name = "Sponsered"
        } else {
            if let globalAct1 = notificationData.global?.act1name, !globalAct1.isEmpty {
                categoryId = notificationData.category ?? ""
                button1Name = globalAct1
                button2Name = notificationData.global?.act2name ?? ""
            } else if let act1 = notificationData.act1name, !act1.isEmpty {
                categoryId = notificationData.category ?? ""
                button1Name = act1
                button2Name = notificationData.act2name ?? ""
            }
        }
        
        let catDict: [String: Any] = [
            AppConstant.iZ_catId: categoryId,
            AppConstant.iZ_b1Name: button1Name,
            AppConstant.iZ_b2Name: button2Name
        ]
        categoryArray.append(catDict)
        
        var tempArray: [[String: Any]] = []
        if let savedArray = UserDefaults.standard.value(forKey: AppConstant.iZ_CategoryArray) as? [[String: Any]] {
            tempArray = savedArray
        }
        
        tempArray.append(contentsOf: categoryArray)
        if tempArray.count > 100 {
            tempArray.removeFirst()
        }
        
        UserDefaults.standard.setValue(tempArray, forKey: AppConstant.iZ_CategoryArray)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Register CTA Buttons
    @objc func addCTAButtons() {
        let center = UNUserNotificationCenter.current()
        var notificationCategories = Set<UNNotificationCategory>()
        
        guard let catArray = UserDefaults.standard.array(forKey: AppConstant.iZ_CategoryArray) as? [[String: Any]], !catArray.isEmpty else {
            return
        }
        
        for item in catArray {
            let categoryId = item[AppConstant.iZ_catId] as? String ?? ""
            var name1 = item[AppConstant.iZ_b1Name] as? String ?? ""
            var name2 = item[AppConstant.iZ_b2Name] as? String ?? ""
            
            name1 = name1.replacingOccurrences(of: "~", with: "")
            name2 = name2.replacingOccurrences(of: "~", with: "")
            
            if name1.count > 17 { name1 = "\(name1.prefix(17))..." }
            if name2.count > 17 { name2 = "\(name2.prefix(17))..." }
            
            let name1Id = AppConstant.FIRST_BUTTON
            let name2Id = AppConstant.SECOND_BUTTON
            
            var actions: [UNNotificationAction] = []
            if !name1.isEmpty {
                actions.append(UNNotificationAction(identifier: name1Id, title: " \(name1)", options: .foreground))
            }
            if !name2.isEmpty {
                actions.append(UNNotificationAction(identifier: name2Id, title: " \(name2)", options: .foreground))
            }
            
            let category = UNNotificationCategory(identifier: categoryId, actions: actions, intentIdentifiers: [], options: [])
            notificationCategories.insert(category)
        }
        
        center.setNotificationCategories(notificationCategories)
    }
}
