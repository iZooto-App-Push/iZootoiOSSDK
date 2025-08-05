//
//  ForegrounNotificationHelper.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 23/06/25.
//

import UIKit

class ForegrounNotificationHelper {
    
    static func showCustomAlertIfNeeded(payload: Payload?) {
        guard let title = payload?.alert?.title else {
            print("Alert title/body missing")
            return
        }
        let body = payload?.alert?.body ?? ""
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        
        if let act1Name = payload?.act1name, !act1Name.isEmpty,
           let act1Link = payload?.act1link,
           let encoded1 = act1Link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url1 = URL(string: encoded1) {
            alert.addAction(UIAlertAction(title: act1Name, style: .default, handler: { _ in
                DispatchQueue.main.async {
                    UIApplication.shared.open(url1)
                }
            }))
        }
        
        if let act2Name = payload?.act2name, !act2Name.isEmpty,
           let act2Link = payload?.act2link,
           let encoded2 = act2Link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url2 = URL(string: encoded2) {
            alert.addAction(UIAlertAction(title: act2Name, style: .default, handler: { _ in
                DispatchQueue.main.async {
                    UIApplication.shared.open(url2)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: AppConstant.iZ_KEY_ALERT_DISMISS, style: .default, handler: nil))
        
        DispatchQueue.main.async {
            UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController?.present(alert, animated: true)
        }
    }
    
}
