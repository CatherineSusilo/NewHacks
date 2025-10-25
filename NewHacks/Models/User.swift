import Foundation

struct User: Codable {
    var selectedCategories: [ContentCategory]
    var dailyTimeLimit: TimeInterval // in seconds
    var currentStreak: Int
    var totalTimeSaved: TimeInterval
    var lastActiveDate: Date?
    
    static let defaultTimeLimit: TimeInterval = 30 * 60 // 30 minutes
}

struct Streak: Codable {
    var currentCount: Int
    var lastUpdated: Date
    var longestStreak: Int
}

struct AppSettings: Codable {
    var isLagEnabled: Bool
    var mascotEnabled: Bool
    var smartWarnings: Bool
}

enum ContentCategory: String, CaseIterable, Codable {
    case gaming = "Gaming"
    case comedy = "Comedy"
    case sports = "Sports"
    case cooking = "Cooking"
    case tech = "Technology"
    case dance = "Dance"
    case education = "Education"
    case animals = "Animals"
}
