import Foundation

class LagManager: ObservableObject {
    @Published var isLagging = false
    @Published var lagProgress: Double = 0.0
    
    private var lagTimer: Timer?
    
    func shouldApplyLag(timeUsed: TimeInterval, dailyLimit: TimeInterval) -> Bool {
        let percentage = timeUsed / dailyLimit
        return percentage >= 1.0 // Apply lag only after exceeding limit
    }
    
    func applyLag(completion: @escaping () -> Void) {
        isLagging = true
        lagProgress = 0.0
        
        let lagDuration = calculateLagDuration()
        let updateInterval = 0.1
        
        lagTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.lagProgress += updateInterval / lagDuration
            
            if self.lagProgress >= 1.0 {
                timer.invalidate()
                self.isLagging = false
                self.lagProgress = 0.0
                completion()
            }
        }
    }
    
    private func calculateLagDuration() -> TimeInterval {
        // Progressive lag based on how far over limit
        return 3.0 // 3 seconds for demo
    }
    
    func cancelLag() {
        lagTimer?.invalidate()
        lagTimer = nil
        isLagging = false
        lagProgress = 0.0
    }
}
