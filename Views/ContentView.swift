import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            if viewModel.user.selectedCategories.isEmpty {
                OnboardingView(viewModel: viewModel)
            } else {
                mainAppView
            }
            
            // Mascot Overlay
            if viewModel.mascotManager.showMascotMessage {
                mascotOverlay
            }
            
            // Lag Overlay
            if viewModel.lagManager.isLagging {
                lagOverlay
            }
        }
        .onAppear {
            if viewModel.user.selectedCategories.isEmpty {
                showOnboarding = true
            }
        }
    }
    
    private var mainAppView: some View {
        VStack {
            // Header with stats
            HStack {
                VStack(alignment: .leading) {
                    Text("Streak: \(viewModel.streakManager.currentStreak) days")
                        .font(.headline)
                    Text("Time Saved: \(formatTime(viewModel.user.totalTimeSaved))")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(formatTime(viewModel.timeTracker.totalTimeUsed)) / \(formatTime(viewModel.user.dailyTimeLimit))")
                        .font(.headline)
                    ProgressView(value: min(viewModel.timeTracker.totalTimeUsed / viewModel.user.dailyTimeLimit, 1.0))
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(width: 100)
                }
            }
            .padding()
            
            // Video Player Area
            VideoPlayerView(viewModel: viewModel)
            
            // Controls
            HStack {
                Button("Save Streak") {
                    viewModel.saveStreak()
                    viewModel.mascotManager.celebrateStreak()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Break Streak") {
                    viewModel.breakStreak()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    
    private var mascotOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Image("mascot_warning")
                    .resizable()
                    .frame(width: 60, height: 60)
                Text(viewModel.mascotManager.currentMessage)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                Spacer()
            }
            .padding()
        }
    }
    
    private var lagOverlay: some View {
        Color.black.opacity(0.7)
            .overlay(
                VStack {
                    Text("Scroll Jail Activated")
                        .font(.title2)
                        .foregroundColor(.white)
                    ProgressView(value: viewModel.lagManager.lagProgress)
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                    Text("Protecting your focus...")
                        .foregroundColor(.white)
                }
            )
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
