import Foundation

struct User: Codable {
    var selectedCategories: [ContentCategory]
    var dailyTimeLimit: TimeInterval // in seconds
    var currentStreak: Int
    var totalTimeSaved: TimeInterval
    var lastActiveDate: Date?
    
    static let defaultTimeLimit: TimeInterval = 30 * 60 // 30 minutes
    
    // Add explicit initializer
    init(
        selectedCategories: [ContentCategory] = [],
        dailyTimeLimit: TimeInterval = User.defaultTimeLimit,
        currentStreak: Int = 0,
        totalTimeSaved: TimeInterval = 0,
        lastActiveDate: Date? = nil
    ) {
        self.selectedCategories = selectedCategories
        self.dailyTimeLimit = dailyTimeLimit
        self.currentStreak = currentStreak
        self.totalTimeSaved = totalTimeSaved
        self.lastActiveDate = lastActiveDate
    }
}

struct Streak: Codable {
    var currentCount: Int
    var lastUpdated: Date
    var longestStreak: Int
    var totalDaysTracked: Int
    var streakHistory: [Date]
    var streakFreezes: Int
    var lastFreezeUsed: Date?
    
    // Add explicit initializer
    init(
        currentCount: Int = 0,
        lastUpdated: Date = Date(),
        longestStreak: Int = 0,
        totalDaysTracked: Int = 0,
        streakHistory: [Date] = [],
        streakFreezes: Int = 1,
        lastFreezeUsed: Date? = nil
    ) {
        self.currentCount = currentCount
        self.lastUpdated = lastUpdated
        self.longestStreak = longestStreak
        self.totalDaysTracked = totalDaysTracked
        self.streakHistory = streakHistory
        self.streakFreezes = streakFreezes
        self.lastFreezeUsed = lastFreezeUsed
    }
}

struct AppSettings: Codable {
    var isLagEnabled: Bool
    var mascotEnabled: Bool
    var smartWarnings: Bool
    
    // Add explicit initializer with default values
    init(
        isLagEnabled: Bool = true,
        mascotEnabled: Bool = true,
        smartWarnings: Bool = true
    ) {
        self.isLagEnabled = isLagEnabled
        self.mascotEnabled = mascotEnabled
        self.smartWarnings = smartWarnings
    }
    
    // Add static default instance
    static let `default` = AppSettings()
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

// MARK: - Supporting Types for Streak (if needed elsewhere)

enum StreakMilestone: Int, CaseIterable {
    case fiveDays = 5
    case tenDays = 10
    case threeWeeks = 21
    case oneMonth = 30
    case twoMonths = 60
    case oneHundredDays = 100
    case halfYear = 182
    case oneYear = 365
}

enum StreakAchievement: String, CaseIterable {
    case oneWeek = "First Week"
    case oneMonth = "Month Master"
    case oneHundredDays = "Centurion"
    case oneYear = "Year Legend"
    case freezeMaster = "Freeze Master"
}
