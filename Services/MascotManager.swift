import Foundation

class MascotManager: ObservableObject {
    @Published var currentMascotState: MascotState = .normal
    @Published var showMascotMessage: Bool = false
    @Published var currentMessage: String = ""
    
    func showWarning(message: String) {
        currentMascotState = .warning
        currentMessage = message
        showMascotMessage = true
        
        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showMascotMessage = false
        }
    }
    
    func showIntervention(message: String) {
        currentMascotState = .intervention
        currentMessage = message
        showMascotMessage = true
    }
    
    func hideMessage() {
        showMascotMessage = false
        currentMascotState = .normal
    }
    
    func celebrateStreak() {
        currentMascotState = .celebrating
        currentMessage = "Amazing! Streak saved! 🎉"
        showMascotMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showMascotMessage = false
        }
    }
}

enum MascotState {
    case normal
    case warning
    case intervention
    case celebrating
}
