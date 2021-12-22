//
//  SDKLog.swift
//  SDKLog
//
//  Created by Amit on 20/08/21.
//

import Foundation
import os.log

class iZootoLog
{
    static var shared = iZootoLog()
    private init() {}
    var isEnabled: Bool = true
    static func success(_ message: Any!) {
        iZootoLog.shared.debug(type: "Sucess", message: message)
       }
   
       ///
       /// - Parameter message: Logging message
       static func info(_ message: Any) {
           iZootoLog.shared.debug(type: "Information", message: message)
       }

       ///
       /// - Parameter message: Logging message
       static func warning(_ message: Any) {
           iZootoLog.shared.debug(type: "Warning", message: message)
       }

       
       static func error(_ message: Any) {
           iZootoLog.shared.debug(type: "Error", message: message)
       }
    
    private func debug(type: Any?, message: Any?) {
           guard iZootoLog.shared.isEnabled else { return }
           DispatchQueue.main.async {
               if #available(iOS 10.0, *) {
                   os_log("%@", type: .debug, "\(type ?? "") -> \(message ?? "")")
               } else {
                   debugPrint("\(type ?? "") -> \(message ?? "")")
               }
           }
       }
}
