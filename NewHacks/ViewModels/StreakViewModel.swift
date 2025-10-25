import Foundation

class StreakViewModel: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastActiveDate: Date?
    
    init() {
        loadStreakData()
        checkDailyStreak()
    }
    
    func saveStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if lastActiveDate != today {
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
            lastActiveDate = today
            saveStreakData()
        }
    }
    
    func breakStreak() {
        currentStreak = 0
        lastActiveDate = nil
        saveStreakData()
    }
    
    private func checkDailyStreak() {
        guard let lastDate = lastActiveDate else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastActive = Calendar.current.startOfDay(for: lastDate)
        
        if today > lastActive {
            let daysSince = Calendar.current.dateComponents([.day], from: lastActive, to: today).day ?? 0
            if daysSince > 1 {
                breakStreak()
            }
        }
    }
    
    private func loadStreakData() {
        currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        longestStreak = UserDefaults.standard.integer(forKey: "longestStreak")
        lastActiveDate = UserDefaults.standard.object(forKey: "lastActiveDate") as? Date
    }
    
    private func saveStreakData() {
        UserDefaults.standard.set(currentStreak, forKey: "currentStreak")
        UserDefaults.standard.set(longestStreak, forKey: "longestStreak")
        UserDefaults.standard.set(lastActiveDate, forKey: "lastActiveDate")
    }
}
