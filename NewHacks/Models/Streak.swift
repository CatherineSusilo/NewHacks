import Foundation

struct Streak: Codable, Identifiable {
    let id = UUID()
    var currentCount: Int
    var lastUpdated: Date
    var longestStreak: Int
    var totalDaysTracked: Int
    var streakHistory: [Date]
    var streakFreezes: Int
    var lastFreezeUsed: Date?
    
    // Computed properties
    var isActiveToday: Bool {
        guard let lastActive = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return false }
        return lastUpdated >= lastActive
    }
    
    var daysUntilNextMilestone: Int {
        let nextMilestone = ((currentCount / 5) + 1) * 5
        return nextMilestone - currentCount
    }
    
    var currentMilestone: StreakMilestone {
        return StreakMilestone.milestoneForStreak(currentCount)
    }
    
    var nextMilestone: StreakMilestone {
        return StreakMilestone.milestoneForStreak(((currentCount / 5) + 1) * 5)
    }
    
    // Initializer
    init(currentCount: Int = 0, lastUpdated: Date = Date(), longestStreak: Int = 0, totalDaysTracked: Int = 0) {
        self.currentCount = currentCount
        self.lastUpdated = lastUpdated
        self.longestStreak = longestStreak
        self.totalDaysTracked = totalDaysTracked
        self.streakHistory = []
        self.streakFreezes = 1 // Start with 1 freeze
    }
    
    // MARK: - Streak Management
    
    mutating func incrementStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if we already updated today
        if !isActiveToday {
            currentCount += 1
            lastUpdated = today
            totalDaysTracked += 1
            streakHistory.append(today)
            
            // Update longest streak if needed
            if currentCount > longestStreak {
                longestStreak = currentCount
            }
        }
    }
    
    mutating func breakStreak() {
        currentCount = 0
        lastUpdated = Date()
        streakFreezes = min(streakFreezes + 1, 3) // Max 3 freezes
    }
    
    mutating func useFreeze() -> Bool {
        guard streakFreezes > 0 else { return false }
        streakFreezes -= 1
        lastFreezeUsed = Date()
        return true
    }
    
    mutating func addFreeze() {
        streakFreezes = min(streakFreezes + 1, 3)
    }
    
    // MARK: - Achievement Checks
    
    var hasPerfectWeek: Bool {
        return currentCount >= 7
    }
    
    var hasPerfectMonth: Bool {
        return currentCount >= 30
    }
    
    var achievements: [StreakAchievement] {
        var achievements: [StreakAchievement] = []
        
        if currentCount >= 7 { achievements.append(.oneWeek) }
        if currentCount >= 30 { achievements.append(.oneMonth) }
        if currentCount >= 100 { achievements.append(.oneHundredDays) }
        if longestStreak >= 365 { achievements.append(.oneYear) }
        if streakFreezes >= 3 { achievements.append(.freezeMaster) }
        
        return achievements
    }
    
    // MARK: - Statistics
    
    var successRate: Double {
        guard totalDaysTracked > 0 else { return 0.0 }
        return Double(currentCount) / Double(totalDaysTracked)
    }
    
    var averageStreakLength: Double {
        guard !streakHistory.isEmpty else { return 0.0 }
        
        var totalDays = 0
        var currentStreakLength = 1
        
        for i in 1..<streakHistory.count {
            let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: streakHistory[i])!
            if streakHistory[i-1] >= previousDay {
                currentStreakLength += 1
            } else {
                totalDays += currentStreakLength
                currentStreakLength = 1
            }
        }
        
        totalDays += currentStreakLength
        return Double(totalDays) / Double(streakHistory.count)
    }
}

// MARK: - Supporting Types

enum StreakMilestone: Int, CaseIterable {
    case fiveDays = 5
    case tenDays = 10
    case threeWeeks = 21
    case oneMonth = 30
    case twoMonths = 60
    case oneHundredDays = 100
    case halfYear = 182
    case oneYear = 365
    
    var title: String {
        switch self {
        case .fiveDays: return "5-Day Streak"
        case .tenDays: return "10-Day Streak"
        case .threeWeeks: return "3-Week Streak"
        case .oneMonth: return "1-Month Streak"
        case .twoMonths: return "2-Month Streak"
        case .oneHundredDays: return "100 Days!"
        case .halfYear: return "Half Year!"
        case .oneYear: return "1 Year Legend!"
        }
    }
    
    var description: String {
        switch self {
        case .fiveDays: return "You're building a habit!"
        case .tenDays: return "Double digits! Amazing!"
        case .threeWeeks: return "Three weeks strong!"
        case .oneMonth: return "A full month of focus!"
        case .twoMonths: return "Incredible dedication!"
        case .oneHundredDays: return "Century streak achieved!"
        case .halfYear: return "Half a year of mindfulness!"
        case .oneYear: return "You're a focus legend!"
        }
    }
    
    static func milestoneForStreak(_ streak: Int) -> StreakMilestone {
        return StreakMilestone.allCases
            .filter { $0.rawValue <= streak }
            .max(by: { $0.rawValue < $1.rawValue }) ?? .fiveDays
    }
}

enum StreakAchievement: String, CaseIterable {
    case oneWeek = "First Week"
    case oneMonth = "Month Master"
    case oneHundredDays = "Centurion"
    case oneYear = "Year Legend"
    case freezeMaster = "Freeze Master"
    
    var description: String {
        switch self {
        case .oneWeek: return "Maintain a 7-day streak"
        case .oneMonth: return "Reach 30 days of focus"
        case .oneHundredDays: return "Achieve 100 days straight"
        case .oneYear: return "Complete a full year"
        case .freezeMaster: return "Collect 3 streak freezes"
        }
    }
    
    var iconName: String {
        switch self {
        case .oneWeek: return "7.circle"
        case .oneMonth: return "calendar"
        case .oneHundredDays: return "100.circle"
        case .oneYear: return "star"
        case .freezeMaster: return "snowflake"
        }
    }
}
