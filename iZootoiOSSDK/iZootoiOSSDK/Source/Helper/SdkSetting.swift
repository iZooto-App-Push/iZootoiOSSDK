import Foundation
import UserNotifications

final class SettingsManager {
    
    // Singleton instance
    static let shared = SettingsManager()
    
    private init() {}
    
    // MARK: - Handle Key Settings
    func handleKeySettingDetails(bundleName: String,
                                 keySettingDetails: [String: Any],
                                 appDelegate: UIApplicationDelegate?) {
        
        // Configure AppStorage with group name
        if let groupName = Utils.getGroupName(bundleName: bundleName) {
            AppStorage.shared.configureAppGroup(groupName)
        }
        
        guard !keySettingDetails.isEmpty else {
            // Fallback if no settings available
            SettingsManager.registerForPushNotifications(appDelegate)
            configureNotificationDelegate(appDelegate)
            return
        }
        
        // Handle custome webView
        if let webViewSetting = keySettingDetails[AppConstant.iZ_KEY_WEBVIEW] as? Bool {
            AppStorage.shared.set(webViewSetting, forKey: AppConstant.ISWEBVIEW)
        }else{
            logMissingKey(exception: "\(AppConstant.IZ_TAG)\(AppConstant.iZ_KEY_WEBVIEW_ERROR)", bundle: bundleName, method: "handleKeySettingDetails")
            Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_WEBVIEW_ERROR, className: "SettingsManager", methodName: "handleKeySettingDetails",  rid: nil, cid: nil, userInfo: nil)
        }

        // Handle Provisional Authorization
        if let isProvisional = keySettingDetails[AppConstant.iZ_KEY_PROVISIONAL] as? Bool {
            if isProvisional {
                SettingsManager.registerForPushNotificationsProvisional()
            }
        } else {
            logMissingKey(exception: AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND,
                          bundle: bundleName, method: "handleKeySettingDetails")
            debugPrint(AppConstant.IZ_TAG,AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND)
            Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_PROVISIONAL_NOT_FOUND, className: "SettingsManager", methodName: "handleKeySettingDetails",  rid: nil, cid: nil, userInfo: nil)
        }

        // Handle Auto Prompt
        if let autoPromptEnabled = keySettingDetails[AppConstant.iZ_KEY_AUTO_PROMPT] as? Bool {
            if autoPromptEnabled {
                SettingsManager.registerForPushNotifications(appDelegate)
            }
        } else {
            logMissingKey(exception: AppConstant.iZ_KEY_AUTO_PROMPT_NOT_FOUND,
                          bundle: bundleName, method: AppConstant.iZ_KEY_INITIALISE)
            Utils.handleOnceException(bundleName: bundleName, exceptionName: AppConstant.iZ_KEY_AUTO_PROMPT_NOT_FOUND, className: "SettingsManager", methodName: "handleKeySettingDetails",  rid: nil, cid: nil, userInfo: nil)
        }

        // Set Notification Delegate
        configureNotificationDelegate(appDelegate)
    }
    
    // MARK: - Log Missing Key
    private func logMissingKey(exception: String, bundle: String, method: String) {
        debugPrint(AppConstant.IZ_TAG, exception)
        Utils.handleOnceException(bundleName: bundle,
                                   exceptionName: exception,
                                   className: "SettingsManager",
                                   methodName: "logMissingKey",
                                   rid: nil,
                                   cid: nil,
                                   userInfo: nil)
    }
    
    // MARK: - Configure Notification Delegate
    private func configureNotificationDelegate(_ appDelegate: UIApplicationDelegate?) {
        if #available(iOS 11.0, *) {
            // Ensure the app delegate is assigned on the main thread
            DispatchQueue.main.async {
                if #available(iOS 11.0, *) {
                    UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
                }
            }
        }
    }
    
    // MARK: - Push Notification Methods
    
    /// Requests permission to register for push notifications.
    @objc public static func registerForPushNotifications(_ appDelegate: UIApplicationDelegate?) {
        // Ensure the OS version supports UNUserNotificationCenter (iOS 11+)
        if #available(iOS 11.0, *) {
            // Set the current notification center's delegate to the app delegate
            // Ensure the app delegate is assigned on the main thread
            DispatchQueue.main.async {
                if #available(iOS 11.0, *) {
                    UNUserNotificationCenter.current().delegate = appDelegate as? UNUserNotificationCenterDelegate
                }
            }
        }
        
        // Ensure the device is running iOS 11+ before requesting authorization
        if #available(iOS 11.0, *) {
            // Request authorization for alert, sound, and badge notifications
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Log whether permission was granted
                debugPrint(AppConstant.PERMISSION_GRANTED, "\(granted)")
                
                // If permission is not granted, exit early
                guard granted else { return }
                
                // Proceed to fetch the current notification settings
                SettingsManager.shared.getNotificationSettings()
            }
        }
    }
    
    /// Requests provisional authorization for push notifications.
    @objc private static func registerForPushNotificationsProvisional() {
        // Ensure the iOS version is 12.0 or later, as provisional authorization is only supported from iOS 12 onwards
        if #available(iOS 12.0, *) {
            // Request authorization with provisional option (notifications are delivered silently without alerting the user initially)
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { (granted, error) in
                // Log whether the user provisionally granted permission
                debugPrint(AppConstant.PERMISSION_GRANTED, "\(granted)")
                
                // If permission not granted, exit
                guard granted else { return }
                
                // Fetch and handle the user's notification settings
                getNotificationSettingsProvisional()
            }
        }
    }

    /// Handles notification prompt settings by checking if the user has granted authorization,
    /// and if so, registers the app for remote notifications.
    @objc func getNotificationSettings() {
        // Ensure the iOS version supports UNUserNotificationCenter (iOS 11+)
        if #available(iOS 11.0, *) {
            // Fetch the current notification settings
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                // Exit early if the user has not authorized notifications
                guard settings.authorizationStatus == .authorized else { return }
                
                // Register the app for remote (push) notifications on the main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /// Handles notification settings specifically for provisional authorization.
    /// If the user has provisionally allowed notifications, this registers the app for remote notifications.
    @objc private static func getNotificationSettingsProvisional() {
        // Ensure iOS version is 11.0 or later to use UNUserNotificationCenter
        if #available(iOS 11.0, *) {
            // Retrieve the current notification settings
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                // Check if the authorization status is 'provisional' (iOS 12+ feature)
                if #available(iOS 12.0, *) {
                    guard settings.authorizationStatus == .provisional else {
                        // Exit if the user hasn't provisionally allowed notifications
                        return
                    }
                }
                
                // Register the app for remote notifications on the main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
