import Foundation
import SwiftUI

struct Constants {
    
    // MARK: - App Information
    struct App {
        static let name = "Scroll Jail"
        static let version = "1.0.0"
        static let buildNumber = "1"
        static let bundleIdentifier = "com.scrolljail.app"
        static let appStoreURL = "https://apps.apple.com/app/scroll-jail/id"
    }
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let userData = "userData"
        static let appSettings = "appSettings"
        static let currentStreak = "currentStreak"
        static let longestStreak = "longestStreak"
        static let lastActiveDate = "lastActiveDate"
        static let totalTimeUsed = "totalTimeUsed"
        static let reelsWatched = "reelsWatched"
        static let totalTimeSaved = "totalTimeSaved"
        static let firstLaunchDate = "firstLaunchDate"
        static let appLaunchCount = "appLaunchCount"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    // MARK: - Time Constants
    struct Time {
        static let defaultDailyLimit: TimeInterval = 30 * 60 // 30 minutes
        static let defaultWeeklyLimit: TimeInterval = 3.5 * 60 * 60 // 3.5 hours
        static let dayInSeconds: TimeInterval = 24 * 60 * 60
        static let weekInSeconds: TimeInterval = 7 * 24 * 60 * 60
        static let minimumDailyLimit: TimeInterval = 5 * 60 // 5 minutes
        static let maximumDailyLimit: TimeInterval = 120 * 60 // 2 hours
    }
    
    // MARK: - Lag System Constants
    struct Lag {
        static let minimumLagDuration: TimeInterval = 0.5
        static let maximumLagDuration: TimeInterval = 10.0
        static let defaultLagDuration: TimeInterval = 2.0
        static let lagUpdateInterval: TimeInterval = 0.05 // 20 FPS
        static let controlsAutoHideDelay: TimeInterval = 3.0
        
        // Warning thresholds (percentage of daily limit)
        static let warningThresholds: [Double] = [0.5, 0.8, 0.95]
        static let lagPhaseThresholds: [Double] = [1.0, 1.1, 1.3, 1.5]
    }
    
    // MARK: - Streak Constants
    struct Streak {
        static let maximumFreezes = 3
        static let freezeCooldown: TimeInterval = 24 * 60 * 60 // 24 hours
        static let milestoneLevels: [Int] = [5, 10, 21, 30, 60, 100, 182, 365]
        static let achievementThresholds: [StreakAchievement: Int] = [
            .oneWeek: 7,
            .oneMonth: 30,
            .oneHundredDays: 100,
            .oneYear: 365
        ]
    }
    
    // MARK: - Content Constants
    struct Content {
        static let defaultCategories: [ContentCategory] = ContentCategory.allCases
        static let minimumCategories = 3
        static let maximumCategories = ContentCategory.allCases.count
        static let mockReelCount = 50
        static let reelCacheSize = 100
        static let videoAspectRatio: CGFloat = 9/16
    }
    
    // MARK: - Mascot Constants
    struct Mascot {
        static let defaultMascot = MascotType.owl
        static let appearanceChances: [MascotFrequency: Double] = [
            .rare: 0.1,
            .normal: 0.3,
            .frequent: 0.6,
            .never: 0.0
        ]
        static let messageCooldown: TimeInterval = 60 * 5 // 5 minutes
    }
    
    // MARK: - Notification Constants
    struct Notifications {
        static let streakReminderIdentifier = "streakReminder"
        static let timeWarningIdentifier = "timeWarning"
        static let weeklyRecapIdentifier = "weeklyRecap"
        static let achievementIdentifier = "achievementUnlocked"
        
        static let reminderHour = 20 // 8 PM
        static let reminderMinute = 0
    }
    
    // MARK: - Layout & UI Constants
    struct Layout {
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 16
        
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        
        static let shadowRadius: CGFloat = 8
        static let smallShadowRadius: CGFloat = 4
        
        static let buttonHeight: CGFloat = 44
        static let segmentedControlHeight: CGFloat = 32
    }
    
    // MARK: - Animation Constants
    struct Animation {
        static let shortDuration: Double = 0.2
        static let mediumDuration: Double = 0.3
        static let longDuration: Double = 0.5
        
        static let easeInOut = Animation.timingCurve(0.4, 0.0, 0.2, 1.0, duration: mediumDuration)
        static let springResponse = 0.6
        static let springDampingFraction = 0.8
    }
    
    // MARK: - Color Constants
    struct Colors {
        // Primary Colors
        static let primary = Color.blue
        static let secondary = Color.purple
        static let accent = Color.orange
        
        // Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
        
        // Background Colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let groupedBackground = Color(.systemGroupedBackground)
        
        // Text Colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary
        static let disabledText = Color.gray
        
        // Streak Colors
        static let streakLevel1 = Color.gray      // 0 days
        static let streakLevel2 = Color.green     // 1-6 days
        static let streakLevel3 = Color.blue      // 7-29 days
        static let streakLevel4 = Color.purple    // 30-99 days
        static let streakLevel5 = Color.orange    // 100+ days
    }
    
    // MARK: - Typography Constants
    struct Typography {
        static let largeTitle: Font = .largeTitle
        static let title: Font = .title
        static let title2: Font = .title2
        static let title3: Font = .title3
        static let headline: Font = .headline
        static let subheadline: Font = .subheadline
        static let body: Font = .body
        static let callout: Font = .callout
        static let caption: Font = .caption
        static let caption2: Font = .caption2
        
        // Custom fonts for streaks
        static let streakNumber: Font = .system(size: 72, weight: .bold, design: .rounded)
        static let milestoneTitle: Font = .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    // MARK: - Localization Keys
    struct Localization {
        static let appName = "Scroll Jail"
        static let tagline = "Serve your time. Reclaim your mind."
        
        struct Onboarding {
            static let welcomeTitle = "Welcome to Scroll Jail"
            static let welcomeSubtitle = "Take control of your scrolling habits"
            static let selectCategories = "Select your interests"
            static let categoriesFooter = "Choose at least 3 categories for better personalization"
        }
        
        struct Streak {
            static let currentStreak = "Current Streak"
            static let longestStreak = "Longest Streak"
            static let days = "days"
            static let streakFreezes = "Streak Freezes"
            static let nextMilestone = "Next Milestone"
            static let achievements = "Achievements"
        }
        
        struct Mascot {
            static let defaultMessages: [MascotType: [String]] = [
                .owl: [
                    "Time to focus, wise one!",
                    "Your future self will thank you!",
                    "Knowledge over endless scrolling!",
                    "Be present in the moment!",
                    "Your mind is your greatest asset!"
                ],
                .sloth: [
                    "Slow down... and take a break!",
                    "Everything in moderation!",
                    "Rest is productive too!",
                    "One step at a time!",
                    "Chill out and close the app!"
                ],
                .fox: [
                    "You're too clever to waste time!",
                    "Outsmart the algorithm!",
                    "Be sly with your time!",
                    "Don't get tricked into scrolling!",
                    "Use your wits wisely!"
                ],
                .bear: [
                    "Be strong and close the app!",
                    "You've got the willpower!",
                    "Stand strong against distraction!",
                    "Your focus is your strength!",
                    "Be the master of your time!"
                ],
                .rabbit: [
                    "Hop to something productive!",
                    "Energy for what matters!",
                    "Quick! Close before you get stuck!",
                    "Be nimble with your choices!",
                    "Jump into real life!"
                ]
            ]
        }
        
        struct Settings {
            static let timeManagement = "Time Management"
            static let lagIntervention = "Lag Intervention"
            static let notifications = "Notifications & Feedback"
            static let contentPreferences = "Content Preferences"
            static let streakSettings = "Streak Settings"
            static let privacy = "Privacy"
        }
    }
    
    // MARK: - Feature Flags
    struct FeatureFlags {
        static let enableLagSystem = true
        static let enableMascot = true
        static let enableStreaks = true
        static let enableAnalytics = true
        static let enableInAppPurchases = false
        static let enableSocialFeatures = false
    }
    
    // MARK: - API Constants
    struct API {
        static let baseURL = "https://api.scrolljail.com/v1"
        static let timeoutInterval: TimeInterval = 30
        static let maxRetryAttempts = 3
        
        struct Endpoints {
            static let analytics = "/analytics"
            static let content = "/content"
            static let trends = "/trends"
            static let user = "/user"
        }
        
        struct Headers {
            static let contentType = "Content-Type"
            static let applicationJSON = "application/json"
            static let userAgent = "User-Agent"
        }
    }
    
    // MARK: - In-App Purchase Identifiers
    struct IAP {
        static let premiumMonthly = "com.scrolljail.premium.monthly"
        static let premiumYearly = "com.scrolljail.premium.yearly"
        static let freezePack = "com.scrolljail.freezes.pack"
        
        static let allProductIdentifiers: Set<String> = [
            premiumMonthly,
            premiumYearly,
            freezePack
        ]
    }
    
    // MARK: - Debug Constants
    struct Debug {
        static let isDebugMode: Bool = {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }()
        
        static let skipOnboarding = false
        static let unlimitedTime = false
        static let instantLag = false
        static let logNetworkRequests = true
        static let mockAPICalls = true
    }
}

// MARK: - Helper Extensions

extension Color {
    static func streakColor(for days: Int) -> Color {
        switch days {
        case 0:
            return Constants.Colors.streakLevel1
        case 1...6:
            return Constants.Colors.streakLevel2
        case 7...29:
            return Constants.Colors.streakLevel3
        case 30...99:
            return Constants.Colors.streakLevel4
        default:
            return Constants.Colors.streakLevel5
        }
    }
}

extension TimeInterval {
    func formattedTime() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func formattedHoursMinutes() -> String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

extension Date {
    func isSameDay(as other: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
}
