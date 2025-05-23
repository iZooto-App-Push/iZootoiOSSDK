//
//  DeviceInfo.swift
//  iZootoiOSSDK
//
//  Created by AMIT_SDK_DEVELOPER on 06/03/25.
//  Copyright © 2025 Amit. All rights reserved.
//

import UIKit

// Existing Structs
struct DeviceInfo: Codable {
    var os: String
    var name: String
    var build: String
    var version: String
    var deviceID: String

    static var current: DeviceInfo {
        let device = UIDevice.current
        return DeviceInfo(
            os: "iOS",
            name: getDeviceModel(),    //device.model,
            build: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
            version: device.systemVersion,
            deviceID: device.identifierForVendor?.uuidString ?? ""
        )
    }
    
    static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return mapDeviceIdentifierToModel(identifier: identifier)
    }
    static func mapDeviceIdentifierToModel(identifier: String) -> String {
        switch identifier {
        // iPhones
        case "i386" : return "iPhone Simulator"
        case "x86_64" : return "iPhone Simulator"
        case "arm64" : return "iPhone Simulator"
        case "iPhone1,1" : return "iPhone"
        case "iPhone1,2" : return "iPhone 3G"
        case "iPhone2,1" : return "iPhone 3GS"
        case "iPhone3,1" : return "iPhone 4"
        case "iPhone3,2" : return "iPhone 4 GSM Rev A"
        case "iPhone3,3" : return "iPhone 4 CDMA"
        case "iPhone4,1" : return "iPhone 4S"
        case "iPhone5,1" : return "iPhone 5 (GSM)"
        case "iPhone5,2" : return "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3" : return "iPhone 5C (GSM)"
        case "iPhone5,4" : return "iPhone 5C (Global)"
        case "iPhone6,1" : return "iPhone 5S (GSM)"
        case "iPhone6,2" : return "iPhone 5S (Global)"
        case "iPhone7,1" : return "iPhone 6 Plus"
        case "iPhone7,2" : return "iPhone 6"
        case "iPhone8,1" : return "iPhone 6s"
        case "iPhone8,2" : return "iPhone 6s Plus"
        case "iPhone8,4" : return "iPhone SE (GSM)"
        case "iPhone9,1" : return "iPhone 7"
        case "iPhone9,2" : return "iPhone 7 Plus"
        case "iPhone9,3" : return "iPhone 7"
        case "iPhone9,4" : return "iPhone 7 Plus"
        case "iPhone10,1" : return "iPhone 8"
        case "iPhone10,2" : return "iPhone 8 Plus"
        case "iPhone10,3" : return "iPhone X Global"
        case "iPhone10,4" : return "iPhone 8"
        case "iPhone10,5" : return "iPhone 8 Plus"
        case "iPhone10,6" : return "iPhone X GSM"
        case "iPhone11,2" : return "iPhone XS"
        case "iPhone11,4" : return "iPhone XS Max"
        case "iPhone11,6" : return "iPhone XS Max Global"
        case "iPhone11,8" : return "iPhone XR"
        case "iPhone12,1" : return "iPhone 11"
        case "iPhone12,3" : return "iPhone 11 Pro"
        case "iPhone12,5" : return "iPhone 11 Pro Max"
        case "iPhone12,8" : return "iPhone SE 2nd Gen"
        case "iPhone13,1" : return "iPhone 12 Mini"
        case "iPhone13,2" : return "iPhone 12"
        case "iPhone13,3" : return "iPhone 12 Pro"
        case "iPhone13,4" : return "iPhone 12 Pro Max"
        case "iPhone14,2" : return "iPhone 13 Pro"
        case "iPhone14,3" : return "iPhone 13 Pro Max"
        case "iPhone14,4" : return "iPhone 13 Mini"
        case "iPhone14,5" : return "iPhone 13"
        case "iPhone14,6" : return "iPhone SE 3rd Gen"
        case "iPhone14,7" : return "iPhone 14"
        case "iPhone14,8" : return "iPhone 14 Plus"
        case "iPhone15,2" : return "iPhone 14 Pro"
        case "iPhone15,3" : return "iPhone 14 Pro Max"
        case "iPhone15,4" : return "iPhone 15"
        case "iPhone15,5" : return "iPhone 15 Plus"
        case "iPhone16,1" : return "iPhone 15 Pro"
        case "iPhone16,2" : return "iPhone 15 Pro Max"
        case "iPhone17,1" : return "iPhone 16 Pro"
        case "iPhone17,2" : return "iPhone 16 Pro Max"
        case "iPhone17,3" : return "iPhone 16"
        case "iPhone17,4" : return "iPhone 16 Plus"
        
        // iPads
        case "iPad1,1" : return "iPad"
        case "iPad1,2" : return "iPad 3G"
        case "iPad2,1" : return "2nd Gen iPad"
        case "iPad2,2" : return "2nd Gen iPad GSM"
        case "iPad2,3" : return "2nd Gen iPad CDMA"
        case "iPad2,4" : return "2nd Gen iPad New Revision"
        case "iPad3,1" : return "3rd Gen iPad"
        case "iPad3,2" : return "3rd Gen iPad CDMA"
        case "iPad3,3" : return "3rd Gen iPad GSM"
        case "iPad2,5" : return "iPad mini"
        case "iPad2,6" : return "iPad mini GSM+LTE"
        case "iPad2,7" : return "iPad mini CDMA+LTE"
        case "iPad3,4" : return "4th Gen iPad"
        case "iPad3,5" : return "4th Gen iPad GSM+LTE"
        case "iPad3,6" : return "4th Gen iPad CDMA+LTE"
        case "iPad4,1" : return "iPad Air (WiFi)"
        case "iPad4,2" : return "iPad Air (GSM+CDMA)"
        case "iPad4,3" : return "1st Gen iPad Air (China)"
        case "iPad4,4" : return "iPad mini Retina (WiFi)"
        case "iPad4,5" : return "iPad mini Retina (GSM+CDMA)"
        case "iPad4,6" : return "iPad mini Retina (China)"
        case "iPad4,7" : return "iPad mini 3 (WiFi)"
        case "iPad4,8" : return "iPad mini 3 (GSM+CDMA)"
        case "iPad4,9" : return "iPad Mini 3 (China)"
        case "iPad5,1" : return "iPad mini 4 (WiFi)"
        case "iPad5,2" : return "4th Gen iPad mini (WiFi+Cellular)"
        case "iPad5,3" : return "iPad Air 2 (WiFi)"
        case "iPad5,4" : return "iPad Air 2 (Cellular)"
        case "iPad6,3" : return "iPad Pro (9.7 inch, WiFi)"
        case "iPad6,4" : return "iPad Pro (9.7 inch, WiFi+LTE)"
        case "iPad6,7" : return "iPad Pro (12.9 inch, WiFi)"
        case "iPad6,8" : return "iPad Pro (12.9 inch, WiFi+LTE)"
        case "iPad6,11" : return "iPad (2017)"
        case "iPad6,12" : return "iPad (2017)"
        case "iPad7,1" : return "iPad Pro 2nd Gen (WiFi)"
        case "iPad7,2" : return "iPad Pro 2nd Gen (WiFi+Cellular)"
        case "iPad7,3" : return "iPad Pro 10.5-inch 2nd Gen"
        case "iPad7,4" : return "iPad Pro 10.5-inch 2nd Gen"
        case "iPad7,5" : return "iPad 6th Gen (WiFi)"
        case "iPad7,6" : return "iPad 6th Gen (WiFi+Cellular)"
        case "iPad7,11" : return "iPad 7th Gen 10.2-inch (WiFi)"
        case "iPad7,12" : return "iPad 7th Gen 10.2-inch (WiFi+Cellular)"
        case "iPad8,1" : return "iPad Pro 11 inch 3rd Gen (WiFi)"
        case "iPad8,2" : return "iPad Pro 11 inch 3rd Gen (1TB, WiFi)"
        case "iPad8,3" : return "iPad Pro 11 inch 3rd Gen (WiFi+Cellular)"
        case "iPad8,4" : return "iPad Pro 11 inch 3rd Gen (1TB, WiFi+Cellular)"
        case "iPad8,5" : return "iPad Pro 12.9 inch 3rd Gen (WiFi)"
        case "iPad8,6" : return "iPad Pro 12.9 inch 3rd Gen (1TB, WiFi)"
        case "iPad8,7" : return "iPad Pro 12.9 inch 3rd Gen (WiFi+Cellular)"
        case "iPad8,8" : return "iPad Pro 12.9 inch 3rd Gen (1TB, WiFi+Cellular)"
        case "iPad8,9" : return "iPad Pro 11 inch 4th Gen (WiFi)"
        case "iPad8,10" : return "iPad Pro 11 inch 4th Gen (WiFi+Cellular)"
        case "iPad8,11" : return "iPad Pro 12.9 inch 4th Gen (WiFi)"
        case "iPad8,12" : return "iPad Pro 12.9 inch 4th Gen (WiFi+Cellular)"
        case "iPad11,1" : return "iPad mini 5th Gen (WiFi)"
        case "iPad11,2" : return "iPad mini 5th Gen"
        case "iPad11,3" : return "iPad Air 3rd Gen (WiFi)"
        case "iPad11,4" : return "iPad Air 3rd Gen"
        case "iPad11,6" : return "iPad 8th Gen (WiFi)"
        case "iPad11,7" : return "iPad 8th Gen (WiFi+Cellular)"
        case "iPad12,1" : return "iPad 9th Gen (WiFi)"
        case "iPad12,2" : return "iPad 9th Gen (WiFi+Cellular)"
        case "iPad14,1" : return "iPad mini 6th Gen (WiFi)"
        case "iPad14,2" : return "iPad mini 6th Gen (WiFi+Cellular)"
        case "iPad13,1" : return "iPad Air 4th Gen (WiFi)"
        case "iPad13,2" : return "iPad Air 4th Gen (WiFi+Cellular)"
        case "iPad13,4" : return "iPad Pro 11 inch 5th Gen"
        case "iPad13,5" : return "iPad Pro 11 inch 5th Gen"
        case "iPad13,6" : return "iPad Pro 11 inch 5th Gen"
        case "iPad13,7" : return "iPad Pro 11 inch 5th Gen"
        case "iPad13,8" : return "iPad Pro 12.9 inch 5th Gen"
        case "iPad13,9" : return "iPad Pro 12.9 inch 5th Gen"
        case "iPad13,10" : return "iPad Pro 12.9 inch 5th Gen"
        case "iPad13,11" : return "iPad Pro 12.9 inch 5th Gen"
        case "iPad13,16" : return "iPad Air 5th Gen (WiFi)"
        case "iPad13,17" : return "iPad Air 5th Gen (WiFi+Cellular)"
        case "iPad13,18" : return "iPad 10th Gen"
        case "iPad13,19" : return "iPad 10th Gen"
        case "iPad14,3" : return "iPad Pro 11 inch 4th Gen"
        case "iPad14,4" : return "iPad Pro 11 inch 4th Gen"
        case "iPad14,5" : return "iPad Pro 12.9 inch 6th Gen"
        case "iPad14,6" : return "iPad Pro 12.9 inch 6th Gen"
        case "iPad14,8" : return "iPad Air 6th Gen"
        case "iPad14,9" : return "iPad Air 6th Gen"
        case "iPad14,10" : return "iPad Air 7th Gen"
        case "iPad14,11" : return "iPad Air 7th Gen"
        case "iPad16,3" : return "iPad Pro 11 inch 5th Gen"
        case "iPad16,4" : return "iPad Pro 11 inch 5th Gen"
        case "iPad16,5" : return "iPad Pro 12.9 inch 7th Gen"
        case "iPad16,6" : return "iPad Pro 12.9 inch 7th Gen"
        
        default:
            return identifier // Fallback to raw identifier
        }
    }
}

struct AppDetails: Codable {
    var name: String
    var version: String
    var bundleId: String
    var sdkversion: String

    static var current: AppDetails {
        let bundle = Bundle.main
        return AppDetails(
            name: bundle.infoDictionary?["CFBundleName"] as? String ?? "",
            version: bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            bundleId: bundle.bundleIdentifier ?? "",
            sdkversion: RestAPI.SDKVERSION
        )
    }
    
}

// Singleton Class Implementation
class AppManager {
    static let shared = AppManager()
    private init() {} // Prevent external instantiation

    var deviceInfo: DeviceInfo = .current
    var appDetails: AppDetails = .current

    func printDetails() {
        print("Device Info: \(deviceInfo)")
        print("App Details: \(appDetails)")
    }
    func getDeviceInfo() -> DeviceInfo {
        return deviceInfo
    }
    func getAppDetails() -> AppDetails {
        return appDetails
    }
}

