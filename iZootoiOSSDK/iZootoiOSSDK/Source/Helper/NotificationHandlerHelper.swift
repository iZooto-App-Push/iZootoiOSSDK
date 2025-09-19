import Foundation
import UserNotifications
import UIKit

class NotificationHandlerHelper {
    
    // MARK: - Singleton Instance
    static let shared = NotificationHandlerHelper()
    
    // MARK: - Private Initializer
    private init() {}
    
    // MARK: - Handle Mediation clicks
    func handleMediation(notificationData: Payload, userInfo: [String: Any], response: UNNotificationResponse, finalBids: [String: Any], bundleName: String) {
        guard let rid = notificationData.rid else {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "Rid is missing", className: "NotificationHandlerHelper", methodName: "handleMediation", rid: "", cid: notificationData.id, userInfo: userInfo)
            return
        }
        
        let actionType = getActionType(from: response.actionIdentifier)
        let adUrl = getActionUrl(for: response.actionIdentifier, from: notificationData)
        
        iZooto.clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: actionType, userInfo: userInfo)
        //RestAPI.callAdMediationClickApi(bundleName: bundleName, finalDict: finalBids as NSDictionary, userInfo: userInfo)
        RestAPI.callAdMediationImpressionApi(finalDict: finalBids as NSDictionary, bundleName: bundleName, userInfo: userInfo, url: ApiConfig.mediationClickUrl)
        
        notificationData.furc?.forEach {
            RestAPI.callRV_RC_Request(bundleName: bundleName, urlString: $0)
        }
        
        guard !adUrl.isEmpty else {
            Utils.handleOnceException(bundleName: bundleName, exceptionName: "Mediation LandingUrl is blank",  className: "NotificationHandlerHelper", methodName: "handleMediation", rid: rid, cid: notificationData.id, userInfo: userInfo)
            return
        }
        
        if let inApp = notificationData.inApp, inApp.contains("1") {
            iZooto.handleBroserNotification(url: adUrl)
        } else {
            iZooto.handleBroserNotification(url: adUrl)
        }
    }
    
    //MARK: handle Content-Push clicks
    func handleStandard(notificationData: Payload, userInfo: [String: Any], response: UNNotificationResponse, bundleName: String) {
        guard let rid = notificationData.rid, notificationData.created_on != nil else {
            return
        }
        
        let firstChar = rid.prefix(1)
        if firstChar != "6" && firstChar != "7" {
            iZooto.notificationReceivedDelegate?.onNotificationReceived(payload: notificationData)
        }
        
        let actionType = getActionType(from: response.actionIdentifier)
        iZooto.clickTrack(bundleName: bundleName, notificationData: notificationData, actionType: actionType, userInfo: userInfo)
        
        if let ap = notificationData.ap, !ap.isEmpty {
            iZooto.handleClicks(response: response, actionType: actionType)
        } else {
            handleLinkAction(notificationData: notificationData, actionType: actionType)
        }
    }
    
    // MARK: - Private Utilities
    
    private func getActionType(from identifier: String) -> String {
        switch identifier {
        case AppConstant.FIRST_BUTTON: return "1"
        case AppConstant.SECOND_BUTTON: return "2"
        default: return "0"
        }
    }
    
    private func getActionUrl(for identifier: String, from data: Payload) -> String {
        let urlString: String? = {
            switch identifier {
            case AppConstant.FIRST_BUTTON: return data.act1link
            case AppConstant.SECOND_BUTTON: return data.act2link
            default: return data.url
            }
        }()
        
        guard var unwrapped = urlString else { return "" }
        
        if unwrapped.contains("~") {
            unwrapped = unwrapped.replacingOccurrences(of: "~", with: "")
        }
        
        if let decoded = unwrapped.removingPercentEncoding,
           let encoded = decoded.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return encoded
        }
        
        return unwrapped.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
    
    //MARK: handle web View if ia = 1
    private func presentViewController(with url: String) {
        var urlString = url
        // Always enforce HTTPS
        if url.hasPrefix("http://") {
            urlString = url.replacingOccurrences(of: "http://", with: "https://")
        } else if !url.hasPrefix("https://") {
            urlString = "https://" + url
        }
        if let url = MediationManager.getDecodedUrl(from: urlString){
            ViewController.serviceURL = urlString
            if #available(iOS 13.0, *) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    window.rootViewController?.present(ViewController(), animated: true)
                }
            }
        }else {
            debugPrint("Wrong url only launch the app.")
        }
    }
    
    private func handleLinkAction(notificationData: Payload, actionType: String) {
        var url: String?
        
        switch actionType {
        case "1": url = notificationData.act1link
        case "2": url = notificationData.act2link
        default:  url = notificationData.url
        }
        
        guard let finalURL = url, !finalURL.isEmpty else { return }
        
        if let inApp = notificationData.inApp, inApp.contains("1") {
            if AppStorage.shared.getBool(forKey: AppConstant.ISWEBVIEW) == true {
                iZooto.landingURLDelegate?.onHandleLandingURL(url: finalURL)
            } else {
                presentViewController(with: finalURL)
            }
        } else {
            iZooto.handleBroserNotification(url: finalURL)
        }
    }
}

