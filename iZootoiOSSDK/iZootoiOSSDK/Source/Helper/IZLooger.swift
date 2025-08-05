//
//  IZLooger.swift
//  iZootoiOSSDK
//
//  Created by AMIT_SDK_DEVELOPER on 22/12/23.
//

import Foundation

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

class Logger {
    static var logLevel: LogLevel = .debug

    static func log(_ level: LogLevel, _ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        if level.rawValue.compare(logLevel.rawValue).rawValue >= 0 {
            let fileName = URL(fileURLWithPath: file).lastPathComponent
            let logMessage = "\(Date()) [\(level.rawValue)] [\(fileName):\(line) - \(function)] \(message)"
            print(logMessage)
        }
    }

    static func debug(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(.debug, message, file: file, line: line, function: function)
    }

    static func info(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(.info, message, file: file, line: line, function: function)
    }

    static func warning(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(.warning, message, file: file, line: line, function: function)
    }

    static func error(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        log(.error, message, file: file, line: line, function: function)
    }
}
