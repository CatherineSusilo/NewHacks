import Foundation

struct AppSettings: Codable {
    // MARK: - Lag Settings
    var isLagEnabled: Bool
    var lagIntensity: LagIntensity
    var progressiveLag: Bool
    var minimumLagDuration: TimeInterval
    var maximumLagDuration: TimeInterval
    
    // MARK: - Notification Settings
    var smartWarnings: Bool
    var warningThresholds: [Double] // Percentages for warnings (0.5, 0.8, 0.9, etc.)
    var notificationStyle: NotificationStyle
    var hapticFeedback: Bool
    
    // MARK: - Mascot Settings
    var mascotEnabled: Bool
    var selectedMascot: MascotType
    var mascotFrequency: MascotFrequency
    var mascotAnimations: Bool
    
    // MARK: - Time Tracking Settings
    var dailyTimeLimit: TimeInterval
    var weeklyTimeLimit: TimeInterval
    var trackingPrecision: TrackingPrecision
    var autoResetDaily: Bool
    var showTimeSaved: Bool
    
    // MARK: - Content Settings
    var defaultPlatform: Platform
    var contentCategories: [ContentCategory]
    var contentQuality: ContentQuality
    var autoPlay: Bool
    var safeMode: Bool
    
    // MARK: - Streak Settings
    var streakReminders: Bool
    var streakFreezeEnabled: Bool
    var achievementNotifications: Bool
    var weeklyRecap: Bool
    
    // MARK: - Privacy Settings
    var collectAnalytics: Bool
    var crashReporting: Bool
    var saveWatchHistory: Bool
    
    // Initializer with default values
    init(
        isLagEnabled: Bool = true,
        lagIntensity: LagIntensity = .medium,
        progressiveLag: Bool = true,
        minimumLagDuration: TimeInterval = 1.0,
        maximumLagDuration: TimeInterval = 5.0,
        smartWarnings: Bool = true,
        warningThresholds: [Double] = [0.5, 0.8, 0.95],
        notificationStyle: NotificationStyle = .subtle,
        hapticFeedback: Bool = true,
        mascotEnabled: Bool = true,
        selectedMascot: MascotType = .owl,
        mascotFrequency: MascotFrequency = .normal,
        mascotAnimations: Bool = true,
        dailyTimeLimit: TimeInterval = 30 * 60, // 30 minutes
        weeklyTimeLimit: TimeInterval = 3.5 * 60 * 60, // 3.5 hours
        trackingPrecision: TrackingPrecision = .precise,
        autoResetDaily: Bool = true,
        showTimeSaved: Bool = true,
        defaultPlatform: Platform = .tiktok,
        contentCategories: [ContentCategory] = ContentCategory.allCases,
        contentQuality: ContentQuality = .standard,
        autoPlay: Bool = true,
        safeMode: Bool = false,
        streakReminders: Bool = true,
        streakFreezeEnabled: Bool = true,
        achievementNotifications: Bool = true,
        weeklyRecap: Bool = true,
        collectAnalytics: Bool = true,
        crashReporting: Bool = true,
        saveWatchHistory: Bool = true
    ) {
        self.isLagEnabled = isLagEnabled
        self.lagIntensity = lagIntensity
        self.progressiveLag = progressiveLag
        self.minimumLagDuration = minimumLagDuration
        self.maximumLagDuration = maximumLagDuration
        self.smartWarnings = smartWarnings
        self.warningThresholds = warningThresholds
        self.notificationStyle = notificationStyle
        self.hapticFeedback = hapticFeedback
        self.mascotEnabled = mascotEnabled
        self.selectedMascot = selectedMascot
        self.mascotFrequency = mascotFrequency
        self.mascotAnimations = mascotAnimations
        self.dailyTimeLimit = dailyTimeLimit
        self.weeklyTimeLimit = weeklyTimeLimit
        self.trackingPrecision = trackingPrecision
        self.autoResetDaily = autoResetDaily
        self.showTimeSaved = showTimeSaved
        self.defaultPlatform = defaultPlatform
        self.contentCategories = contentCategories
        self.contentQuality = contentQuality
        self.autoPlay = autoPlay
        self.safeMode = safeMode
        self.streakReminders = streakReminders
        self.streakFreezeEnabled = streakFreezeEnabled
        self.achievementNotifications = achievementNotifications
        self.weeklyRecap = weeklyRecap
        self.collectAnalytics = collectAnalytics
        self.crashReporting = crashReporting
        self.saveWatchHistory = saveWatchHistory
    }
    
    // MARK: - Computed Properties
    
    var effectiveLagDuration: TimeInterval {
        switch lagIntensity {
        case .light: return 1.0
        case .medium: return 2.0
        case .heavy: return 3.0
        case .custom: return minimumLagDuration
        }
    }
    
    var shouldShowMascot: Bool {
        return mascotEnabled && mascotFrequency != .never
    }
    
    var mascotAppearanceChance: Double {
        switch mascotFrequency {
        case .rare: return 0.1
        case .normal: return 0.3
        case .frequent: return 0.6
        case .never: return 0.0
        }
    }
    
    // MARK: - Validation
    
    func validate() -> Bool {
        guard dailyTimeLimit > 0 else { return false }
        guard weeklyTimeLimit >= dailyTimeLimit else { return false }
        guard minimumLagDuration <= maximumLagDuration else { return false }
        guard warningThresholds.allSatisfy({ $0 >= 0 && $0 <= 1 }) else { return false }
        return true
    }
}

// MARK: - Supporting Enums

enum LagIntensity: String, CaseIterable, Codable {
    case light = "Light"
    case medium = "Medium"
    case heavy = "Heavy"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .light: return "Brief pauses (1-2 seconds)"
        case .medium: return "Noticeable delays (2-3 seconds)"
        case .heavy: return "Significant breaks (3-5 seconds)"
        case .custom: return "Custom duration"
        }
    }
}

enum NotificationStyle: String, CaseIterable, Codable {
    case subtle = "Subtle"
    case moderate = "Moderate"
    case assertive = "Assertive"
    
    var description: String {
        switch self {
        case .subtle: return "Gentle reminders"
        case .moderate: return "Clear notifications"
        case .assertive: return "Strong interventions"
        }
    }
}

enum MascotType: String, CaseIterable, Codable {
    case owl = "Wise Owl"
    case sloth = "Sleepy Sloth"
    case fox = "Clever Fox"
    case bear = "Strong Bear"
    case rabbit = "Energetic Rabbit"
    
    var defaultMessage: String {
        switch self {
        case .owl: return "Time to focus, wise one!"
        case .sloth: return "Slow down... and take a break!"
        case .fox: return "You're too clever to waste time!"
        case .bear: return "Be strong and close the app!"
        case .rabbit: return "Hop to something productive!"
        }
    }
    
    var imageName: String {
        switch self {
        case .owl: return "mascot_owl"
        case .sloth: return "mascot_sloth"
        case .fox: return "mascot_fox"
        case .bear: return "mascot_bear"
        case .rabbit: return "mascot_rabbit"
        }
    }
}

enum MascotFrequency: String, CaseIterable, Codable {
    case rare = "Rare"
    case normal = "Normal"
    case frequent = "Frequent"
    case never = "Never"
    
    var description: String {
        switch self {
        case .rare: return "Only during important moments"
        case .normal: return "Regular check-ins"
        case .frequent: return "Frequent encouragement"
        case .never: return "No mascot appearances"
        }
    }
}

enum TrackingPrecision: String, CaseIterable, Codable {
    case basic = "Basic"
    case precise = "Precise"
    case detailed = "Detailed"
    
    var updateInterval: TimeInterval {
        switch self {
        case .basic: return 30.0 // Every 30 seconds
        case .precise: return 5.0 // Every 5 seconds
        case .detailed: return 1.0 // Every second
        }
    }
}

enum ContentQuality: String, CaseIterable, Codable {
    case low = "Data Saver"
    case standard = "Standard"
    case high = "High Quality"
    
    var description: String {
        switch self {
        case .low: return "Lower quality, less engaging"
        case .standard: return "Balanced quality"
        case .high: return "Best experience"
        }
    }
}

// MARK: - Settings Management Extension

extension AppSettings {
    static var `default`: AppSettings {
        return AppSettings()
    }
    
    mutating func resetToDefaults() {
        self = AppSettings.default
    }
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "appSettings")
        }
    }
    
    static func loadFromUserDefaults() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: "appSettings"),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings.default
        }
        return settings
    }
}
