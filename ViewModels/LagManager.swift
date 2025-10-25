import Foundation
import SwiftUI

class LagManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isLagging = false
    @Published var lagProgress: Double = 0.0
    @Published var currentLagPhase: LagPhase = .none
    @Published var lagMessage: String = ""
    @Published var showLagIntervention = false
    
    // MARK: - Private Properties
    private var lagTimer: Timer?
    private var lagStartTime: Date?
    private var lagCompletionHandler: (() -> Void)?
    private var settings: AppSettings
    private var timeTracker: TimeTracker?
    
    // MARK: - Lag Statistics
    private var lagStatistics = LagStatistics()
    
    // MARK: - Initialization
    init(settings: AppSettings = AppSettings.default) {
        self.settings = settings
        setupNotifications()
    }
    
    deinit {
        lagTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// Main method to check if lag should be applied and execute it
    func shouldApplyLag(timeUsed: TimeInterval, dailyLimit: TimeInterval) -> Bool {
        guard settings.isLagEnabled else { return false }
        
        let percentage = timeUsed / dailyLimit
        let phase = determineLagPhase(percentage: percentage)
        
        return phase != .none
    }
    
    /// Apply lag with completion handler
    func applyLag(completion: @escaping () -> Void) {
        guard !isLagging else { return }
        
        let phase = determineLagPhase(percentage: getTimePercentage())
        guard phase != .none else {
            completion()
            return
        }
        
        lagCompletionHandler = completion
        currentLagPhase = phase
        isLagging = true
        lagProgress = 0.0
        lagStartTime = Date()
        showLagIntervention = phase == .intervention
        
        // Update statistics
        lagStatistics.totalLagEvents += 1
        lagStatistics.lastLagDate = Date()
        
        startLagTimer(for: phase)
        triggerHapticFeedback(for: phase)
    }
    
    /// Cancel ongoing lag
    func cancelLag() {
        lagTimer?.invalidate()
        lagTimer = nil
        resetLagState()
        lagCompletionHandler?()
        lagCompletionHandler = nil
    }
    
    /// Force skip lag (user choice during intervention)
    func skipLag() {
        guard currentLagPhase == .intervention else { return }
        
        lagStatistics.skippedInterventions += 1
        cancelLag()
    }
    
    /// Update settings
    func updateSettings(_ newSettings: AppSettings) {
        self.settings = newSettings
    }
    
    /// Set time tracker reference for percentage calculations
    func setTimeTracker(_ tracker: TimeTracker) {
        self.timeTracker = tracker
    }
    
    // MARK: - Lag Information
    
    func getCurrentLagDuration() -> TimeInterval {
        return calculateLagDuration(for: currentLagPhase)
    }
    
    func getLagStatistics() -> LagStatistics {
        return lagStatistics
    }
    
    func getNextLagPhase() -> LagPhase {
        let percentage = getTimePercentage()
        return determineLagPhase(percentage: percentage)
    }
    
    // MARK: - Private Methods
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    private func determineLagPhase(percentage: Double) -> LagPhase {
        guard settings.isLagEnabled else { return .none }
        
        switch percentage {
        case 1.0..<1.1:
            return .warning
        case 1.1..<1.3:
            return .light
        case 1.3..<1.5:
            return .medium
        case 1.5...:
            return .intervention
        default:
            return .none
        }
    }
    
    private func calculateLagDuration(for phase: LagPhase) -> TimeInterval {
        if !settings.progressiveLag {
            return settings.effectiveLagDuration
        }
        
        switch phase {
        case .none:
            return 0.0
        case .warning:
            return settings.minimumLagDuration
        case .light:
            return settings.minimumLagDuration + 1.0
        case .medium:
            return (settings.minimumLagDuration + settings.maximumLagDuration) / 2
        case .intervention:
            return settings.maximumLagDuration
        }
    }
    
    private func startLagTimer(for phase: LagPhase) {
        let duration = calculateLagDuration(for: phase)
        let updateInterval = 0.05 // 20 times per second for smooth progress
        
        updateLagMessage(for: phase)
        
        lagTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.lagStartTime else {
                timer.invalidate()
                return
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            self.lagProgress = min(elapsed / duration, 1.0)
            
            // Update dynamic message for intervention phase
            if phase == .intervention {
                self.updateInterventionMessage(elapsed: elapsed, total: duration)
            }
            
            if elapsed >= duration {
                timer.invalidate()
                self.completeLag()
            }
        }
    }
    
    private func completeLag() {
        lagStatistics.totalLagTime += Date().timeIntervalSince(lagStartTime ?? Date())
        resetLagState()
        lagCompletionHandler?()
        lagCompletionHandler = nil
    }
    
    private func resetLagState() {
        isLagging = false
        lagProgress = 0.0
        currentLagPhase = .none
        showLagIntervention = false
        lagMessage = ""
        lagStartTime = nil
        lagTimer?.invalidate()
        lagTimer = nil
    }
    
    private func updateLagMessage(for phase: LagPhase) {
        switch phase {
        case .none:
            lagMessage = ""
        case .warning:
            lagMessage = "Approaching your time limit..."
        case .light:
            lagMessage = "Time for a quick break?"
        case .medium:
            lagMessage = "Your focus time is up!"
        case .intervention:
            lagMessage = "Protecting your productivity..."
        }
    }
    
    private func updateInterventionMessage(elapsed: TimeInterval, total: TimeInterval) {
        let remaining = total - elapsed
        let remainingInt = Int(ceil(remaining))
        
        if remainingInt > 0 {
            lagMessage = "Think about it... \(remainingInt)s"
        } else {
            lagMessage = "Ready to make a choice?"
        }
    }
    
    private func triggerHapticFeedback(for phase: LagPhase) {
        guard settings.hapticFeedback else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        switch phase {
        case .warning:
            generator.impactOccurred(intensity: 0.3)
        case .light:
            generator.impactOccurred(intensity: 0.5)
        case .medium:
            generator.impactOccurred(intensity: 0.7)
        case .intervention:
            generator.impactOccurred(intensity: 1.0)
        case .none:
            break
        }
    }
    
    private func getTimePercentage() -> Double {
        guard let tracker = timeTracker else { return 0.0 }
        return tracker.totalTimeUsed / tracker.dailyLimit
    }
    
    @objc private func appWillResignActive() {
        if isLagging {
            cancelLag()
        }
    }
}

// MARK: - Supporting Types

enum LagPhase: String, CaseIterable {
    case none = "None"
    case warning = "Warning"
    case light = "Light"
    case medium = "Medium"
    case intervention = "Intervention"
    
    var description: String {
        switch self {
        case .none: return "No lag"
        case .warning: return "Warning lag"
        case .light: return "Light lag"
        case .medium: return "Medium lag"
        case .intervention: return "Full intervention"
        }
    }
    
    var severity: Int {
        switch self {
        case .none: return 0
        case .warning: return 1
        case .light: return 2
        case .medium: return 3
        case .intervention: return 4
        }
    }
}

struct LagStatistics {
    var totalLagEvents: Int = 0
    var totalLagTime: TimeInterval = 0
    var skippedInterventions: Int = 0
    var lastLagDate: Date?
    var phaseDistribution: [LagPhase: Int] = {
        var dict: [LagPhase: Int] = [:]
        LagPhase.allCases.forEach { dict[$0] = 0 }
        return dict
    }()
    
    var averageLagDuration: TimeInterval {
        guard totalLagEvents > 0 else { return 0.0 }
        return totalLagTime / Double(totalLagEvents)
    }
    
    var interventionResistanceRate: Double {
        guard totalLagEvents > 0 else { return 0.0 }
        return Double(skippedInterventions) / Double(totalLagEvents)
    }
    
    mutating func recordLagEvent(phase: LagPhase) {
        totalLagEvents += 1
        phaseDistribution[phase] = (phaseDistribution[phase] ?? 0) + 1
    }
}

// MARK: - Lag View Components

struct LagOverlayView: View {
    @ObservedObject var lagManager: LagManager
    
    var body: some View {
        if lagManager.isLagging {
            ZStack {
                // Background overlay
                Color.black.opacity(backgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                
                // Lag content
                VStack(spacing: 20) {
                    if lagManager.currentLagPhase == .intervention {
                        interventionView
                    } else {
                        progressView
                    }
                }
                .padding(30)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(40)
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: lagManager.isLagging)
        }
    }
    
    private var backgroundOpacity: Double {
        switch lagManager.currentLagPhase {
        case .warning: return 0.3
        case .light: return 0.5
        case .medium: return 0.7
        case .intervention: return 0.9
        case .none: return 0.0
        }
    }
    
    private var progressView: some View {
        VStack(spacing: 15) {
            ProgressView(value: lagManager.lagProgress)
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            Text(lagManager.lagMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("\(Int(lagManager.getCurrentLagDuration()))s")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var interventionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "hourglass")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Scroll Jail Activated")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(lagManager.lagMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            ProgressView(value: lagManager.lagProgress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 8)
            
            HStack(spacing: 15) {
                Button("Skip") {
                    lagManager.skipLag()
                }
                .buttonStyle(.bordered)
                
                Button("Save Streak") {
                    // This would trigger the streak saving logic
                    lagManager.cancelLag()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Preview Provider

#if DEBUG
struct LagManager_Previews: PreviewProvider {
    static var previews: some View {
        LagOverlayView(lagManager: LagManager())
    }
}
#endif
