//
//  AdsFilterKey.swift
//  iZootoiOSSDK
//
//  Created by Rambali Kumar on 03/11/25.
//

import Foundation

final class AdsFilterKey {
    static let shared = AdsFilterKey()
    private init() {}
    
    func loadKeywordsCache() {
        UserDefaults.standard.removeObject(forKey: "cached_keywords")
        let urlString = ApiConfig.adsKeyUrl
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]] {
                let keywords = jsonDict?.values.flatMap { $0 }
                UserDefaults.standard.set(keywords, forKey: "cached_keywords")
            }
        }.resume()
    }
    
    func checkKeywordsMatchInstant(from title: String) -> Bool {
        guard let allKeywords = UserDefaults.standard.array(forKey: "cached_keywords") as? [String] else { return false }
        let lowercased = title.lowercased()
        for keyword in allKeywords {
            let escaped = NSRegularExpression.escapedPattern(for: keyword.lowercased())
            let pattern = "\\b\(escaped)\\b"
            if let _ = lowercased.range(of: pattern, options: .regularExpression) {
                return true
            }
        }
        return false
    }
    
}
