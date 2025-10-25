import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var currentReels: [Reel] = []
    @Published var currentReelIndex = 0
    @Published var user: User
    @Published var settings: AppSettings
    
    // Initialize dependencies directly instead of referencing self
    var timeTracker: TimeTracker
    var lagManager: LagManager
    var streakManager: StreakViewModel
    var mascotManager: MascotManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize properties first
        self.user = User(
            selectedCategories: [],
            dailyTimeLimit: User.defaultTimeLimit,
            currentStreak: 0,
            totalTimeSaved: 0
        )
        self.settings = AppSettings.default
        self.timeTracker = TimeTracker()
        self.lagManager = LagManager()
        self.streakManager = StreakViewModel()
        self.mascotManager = MascotManager()
        
        // Now setup bindings
        setupBindings()
        loadUserData()
    }
    
    private func setupBindings() {
        timeTracker.$totalTimeUsed
            .sink { [weak self] timeUsed in
                self?.checkTimeLimits(timeUsed: timeUsed)
            }
            .store(in: &cancellables)
    }
    
    func loadContent() {
        // Load mock content based on user categories
        currentReels = ContentService.shared.getReels(for: user.selectedCategories)
    }
    
    func swipeToNextReel() {
        guard currentReelIndex < currentReels.count - 1 else { return }
        
        if lagManager.shouldApplyLag(timeUsed: timeTracker.totalTimeUsed, dailyLimit: user.dailyTimeLimit) {
            lagManager.applyLag { [weak self] in
                self?.currentReelIndex += 1
            }
        } else {
            currentReelIndex += 1
        }
        
        timeTracker.recordReelWatch()
    }
    
    private func checkTimeLimits(timeUsed: TimeInterval) {
        let percentage = timeUsed / user.dailyTimeLimit
        
        if settings.smartWarnings {
            if percentage >= 0.8 && percentage < 1.0 {
                mascotManager.showWarning(message: "Almost at your limit! Your streak is at risk.")
            } else if percentage >= 1.0 {
                mascotManager.showIntervention(message: "Time's up! Save your \(streakManager.currentStreak)-day streak?")
            }
        }
    }
    
    func saveStreak() {
        streakManager.saveStreak()
        user.totalTimeSaved += timeTracker.totalTimeUsed
        saveUserData()
    }
    
    func breakStreak() {
        streakManager.breakStreak()
        saveUserData()
    }
    
    private func loadUserData() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "userData"),
           let savedUser = try? JSONDecoder().decode(User.self, from: data) {
            user = savedUser
        }
    }
    
    private func saveUserData() {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "userData")
        }
    }
}
