import Foundation

class TimeTracker: ObservableObject {
    @Published var totalTimeUsed: TimeInterval = 0
    @Published var dailyLimit: TimeInterval = 30 * 60 // 30 minutes
    @Published var reelsWatched: Int = 0
    
    private var startTime: Date?
    private var timer: Timer?
    
    init() {
        loadTimeData()
        startTracking()
    }
    
    func startTracking() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeUsed()
        }
    }
    
    func recordReelWatch() {
        reelsWatched += 1
        saveTimeData()
    }
    
    private func updateTimeUsed() {
        if startTime == nil {
            startTime = Date()
        }
        
        if let start = startTime {
            totalTimeUsed = Date().timeIntervalSince(start)
            objectWillChange.send()
        }
    }
    
    func resetDailyTime() {
        totalTimeUsed = 0
        reelsWatched = 0
        startTime = Date()
        saveTimeData()
    }
    
    func getTimeSaved() -> TimeInterval {
        return max(0, totalTimeUsed - dailyLimit)
    }
    
    private func loadTimeData() {
        totalTimeUsed = UserDefaults.standard.double(forKey: "totalTimeUsed")
        reelsWatched = UserDefaults.standard.integer(forKey: "reelsWatched")
    }
    
    private func saveTimeData() {
        UserDefaults.standard.set(totalTimeUsed, forKey: "totalTimeUsed")
        UserDefaults.standard.set(reelsWatched, forKey: "reelsWatched")
    }
}
