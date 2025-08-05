//
//  AppStorage.swift
//  Pods
//
//  Created by Rambali Kumar on 06/05/25.
//

import Foundation

final class AppStorage {
    
    static let shared = AppStorage()
    
    private var defaults: UserDefaults = .standard
    
    private init() {}
    
    /// Configure to use shared app group container
    func configureAppGroup(_ suiteName: String) {
        if let sharedDefaults = UserDefaults(suiteName: suiteName) {
            self.defaults = sharedDefaults
        }
    }
    
    // MARK: - Setters
    func set(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func setAnyValue(_ value: Any, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: Double, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: Float, forKey key: String) {
        defaults.set(value, forKey: key)
    }
    
    func set(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    // MARK: - Getters
    func getAnyValue(forKey key: String) -> Any? {
        return defaults.object(forKey: key)
    }
    
    func getString(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    func getInt(forKey key: String) -> Int {
        return defaults.integer(forKey: key)
    }
    
    func getDouble(forKey key: String) -> Double {
        return defaults.double(forKey: key)
    }
    
    func getFloat(forKey key: String) -> Float {
        return defaults.float(forKey: key)
    }
    
    func getBool(forKey key: String) -> Bool {
        return defaults.bool(forKey: key)
    }

    // MARK: - Remove & Clear
    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    func clearAll() {
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
    }
}
