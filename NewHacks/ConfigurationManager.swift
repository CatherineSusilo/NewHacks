//
//  ConfigurationManager.swift
//  NewHacks
//

import Foundation

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    var youTubeAPIKey: String {
        // First try to get from environment variable (for CI/CD or production)
        if let envKey = ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"] {
            return envKey
        }
        
        // Then try to get from Config.plist
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let apiKey = plist["YouTubeAPIKey"] as? String,
              apiKey != "YOUR_YOUTUBE_API_KEY_HERE" else {
            print("⚠️ YouTube API key not found in Config.plist or environment variables")
            return ""
        }
        
        return apiKey
    }
    
    var hasValidAPIKey: Bool {
        let key = youTubeAPIKey
        return !key.isEmpty && key != "YOUR_YOUTUBE_API_KEY_HERE"
    }
}
