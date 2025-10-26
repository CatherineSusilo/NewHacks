//
//  ReelsContainerView.swift
//  NewHacks
//

import SwiftUI

struct ReelsContainerView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var currentIndex = 0
    @StateObject private var youTubeManager = YouTubeManager()
    @State private var dragOffset: CGFloat = 0
    @State private var videos: [URL] = []
    @ObservedObject var timeTrackingManager: TimeTrackingManager
    @State private var showBlackScreen = false
    @State private var blackScreenTimer: Timer?
    @State private var breakTextOffset: CGFloat = 0
    @State private var breakTextOpacity: Double = 1.0
    @State private var videoPlayers: [Int: ReelsVideoPlayer] = [:]
    @State private var shouldPauseVideos = false
    @State private var blackScreenCountdown = 0
    @State private var sessionStartTime: Date?
    
    private var fixedTimeThreshold: TimeInterval {
        userDataManager.currentUser?.fixedTimeThreshold ?? 600 // Default fallback
    }
    private let sessionStartTimeKey = "SessionStartTime"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if youTubeManager.isLoading {
                    // Loading state
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Loading YouTube Shorts...")
                            .foregroundColor(.white)
                            .padding(.top)
                        Text("This may take a few seconds")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                } else if let error = youTubeManager.error {
                    // Error state
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Error Loading Shorts")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text(error)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Retry") {
                            loadYouTubeShorts()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        // Add option to load sample videos if API fails
                        Button("Load Sample Videos") {
                            loadSampleShorts()
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else if !youTubeManager.videoIDs.isEmpty {
                    // Success state - show videos
                    ZStack {
                        TabView(selection: $currentIndex) {
                            ForEach(0..<youTubeManager.videoIDs.count, id: \.self) { index in
                                ReelsVideoPlayer(videoID: youTubeManager.videoIDs[index], timeTrackingManager: timeTrackingManager, shouldPause: $shouldPauseVideos)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .ignoresSafeArea()
                        .onChange(of: currentIndex) { _, newIndex in
                            print("Switched to Short index: \(newIndex)")
                            
                            // Pause all other videos when switching
                            pauseAllVideosExcept(current: newIndex)
                            
                            // Check if we need to preload more videos
                            youTubeManager.checkAndPreloadIfNeeded(currentIndex: newIndex)
                            
                            // Ensure tracking continues when switching videos
                            if !timeTrackingManager.isCurrentlyTracking {
                                timeTrackingManager.startTracking()
                            }
                            
                            // Check for black screen on video switch
                            checkTimeAndShowBlackScreen()
                        }
                        
                        // Black Screen Overlay
                        if showBlackScreen {
                            Color.black
                                .ignoresSafeArea()
                                .overlay(
                                    VStack {
                                        Spacer()
                                        
                                        Text("Take a break!")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .opacity(breakTextOpacity)
                                            .offset(y: breakTextOffset)
                                            .onAppear {
                                                // Start the animation when black screen appears
                                                withAnimation(.easeInOut(duration: 2.0)) {
                                                    breakTextOffset = 200 // Move downwards
                                                    breakTextOpacity = 0.3 // Fade near bottom
                                                }
                                            }
                                        
                                        Spacer()
                                    }
                                )
                                .allowsHitTesting(false) // Prevent interaction during black screen
                        }
                        
                        // Debug indicator and time tracking display
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    // Debug info for session time
                                    Text("Session: \(formatTimeInterval(getSessionDuration()))")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(4)
                                }
                                Spacer()
                                Text(timeTrackingManager.formattedCurrentTime)
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(8)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "film")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No Shorts Available")
                            .foregroundColor(.white)
                            .font(.title2)
                        Text("Pull to refresh or check your API key")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Button("Load Sample Videos") {
                            loadSampleShorts()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            loadYouTubeShorts()
            timeTrackingManager.startTracking()
            startSession()
            checkTimeAndShowBlackScreen()
        }
        .onDisappear {
            timeTrackingManager.stopTracking()
            blackScreenTimer?.invalidate()
            // Pause all videos when leaving the view
            pauseAllVideos()
        }
        .refreshable {
            loadDifferentShorts()
        }
    }
    
    private func startSession() {
        let now = Date()
        sessionStartTime = now
        UserDefaults.standard.set(now, forKey: sessionStartTimeKey)
        print("🕒 Session started at: \(now)")
    }
    
    private func getSessionDuration() -> TimeInterval {
        if let startTime = sessionStartTime ?? UserDefaults.standard.object(forKey: sessionStartTimeKey) as? Date {
            let duration = Date().timeIntervalSince(startTime)
            print("⏱️ Session duration: \(duration) seconds")
            return duration
        }
        return 0
    }
    
    private func calculateRandomizedCountdown() -> Int {
        let sessionDuration = getSessionDuration()
        let ratio = sessionDuration / fixedTimeThreshold
        
        print("📊 Ratio calculation: \(sessionDuration)s / \(fixedTimeThreshold)s = \(ratio)")
        
        let countdownRange: ClosedRange<Double>
        
        if ratio <= 0.6 {
            // 0.6 of fixed number -> 0.8 to 1.0 seconds
            countdownRange = 0.8...1
        } else if ratio <= 0.8 {
            // 0.8 of fixed number -> 1 to 3 seconds
            countdownRange = 1.0...3.0
        } else {
            // Fixed number reached -> 3 to 10 seconds
            countdownRange = 3.0...10.0
        }
        
        let randomCountdown = Double.random(in: countdownRange)
        print("🎲 Randomized countdown: \(randomCountdown)s (from range: \(countdownRange))")
        
        return Int(randomCountdown * 1000) // Convert to milliseconds for timer precision
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func loadVideos() {
        // Load local video files
        let videoFiles = ["IMG_2537.MOV", "IMG_2540.MOV", "IMG_2541.MOV", "IMG_2542.MOV", "IMG_2543.MOV"]
        videos = videoFiles.compactMap { fileName in
            Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".MOV", with: ""), withExtension: "MOV")
        }
    }
    
    private func loadYouTubeShorts() {
        let userCategories = userDataManager.currentUser?.preferredCategories ?? []
        let searchTerms = userCategories.isEmpty ?
            ["funny shorts", "dance shorts", "comedy shorts"] :
            userCategories.map { "\($0.lowercased()) shorts" }
        
        let randomTerm = searchTerms.randomElement() ?? "shorts"
        youTubeManager.fetchShortsVideos(query: randomTerm, maxResults: 50)
    }
    
    private func loadDifferentShorts() {
        // Load different content each time
        let searchTerms = [
            "viral shorts", "trending shorts", "funny shorts", "dance shorts",
            "comedy shorts", "gaming shorts", "music shorts", "art shorts",
            "cooking shorts", "sports shorts", "travel shorts", "animal shorts"
        ]
        let randomTerm = searchTerms.randomElement() ?? "shorts"
        
        print("🔄 Loading new shorts with term: \(randomTerm)")
        youTubeManager.fetchShortsVideos(query: randomTerm, maxResults: 50)
    }
    
    private func loadSampleShorts() {
        // Only use sample videos as fallback
        let sampleVideoIDs = [
            "dQw4w9WgXcQ", // Rick Astley - Never Gonna Give You Up
            "jNQXAC9IVRw", // Me at the zoo
            "9bZkp7q19f0", // Gangnam Style
            "kJQP7kiw5Fk", // Despacito
            "L_jWHffIx5E", // All Star
            "fJ9rUzIMcZQ", // Bohemian Rhapsody
            "Ow3WtR5zZcE", // Waka Waka
            "JGwWNGJdvx8"  // Shape of You
        ]
        youTubeManager.videoIDs = sampleVideoIDs
        print("📱 Loaded sample videos")
    }
    
    private func checkTimeAndShowBlackScreen() {
        // Check if total watch time exceeds 20 seconds
        print("🔍 Checking time: \(timeTrackingManager.currentDayWatchTime) seconds")
        if timeTrackingManager.currentDayWatchTime > 20 {
            print("⏰ Time exceeded 20 seconds, starting black screen")
            startBlackScreenTimer()
        } else {
            print("✅ Time is under 20 seconds, no black screen needed")
        }
    }
    
    private func startBlackScreenTimer() {
        print("🖤 Starting black screen timer")
        
        // Calculate randomized countdown
        let countdownMilliseconds = calculateRandomizedCountdown()
        let countdownSeconds = Double(countdownMilliseconds) / 1000.0
        
        print("⏱️ Final countdown duration: \(countdownSeconds) seconds")
        
        // Pause all videos immediately
        shouldPauseVideos = true
        
        // Reset animation values before showing
        breakTextOffset = 0
        breakTextOpacity = 1.0
        blackScreenCountdown = Int(countdownSeconds.rounded())
        
        // Show black screen
        withAnimation(.easeInOut(duration: 0.3)) {
            showBlackScreen = true
        }
        
        // Start countdown timer
        startCountdownTimer(totalMilliseconds: countdownMilliseconds)
    }
    
    private func startCountdownTimer(totalMilliseconds: Int) {
        var remainingMilliseconds = totalMilliseconds
        
        blackScreenTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            remainingMilliseconds -= 100
            
            // Update the countdown display every second
            if remainingMilliseconds % 1000 == 0 {
                let remainingSeconds = remainingMilliseconds / 1000
                self.blackScreenCountdown = max(0, remainingSeconds)
                print("⏱️ Countdown: \(self.blackScreenCountdown)s remaining")
            }
            
            if remainingMilliseconds <= 0 {
                print("✅ Black screen timer finished, resuming video")
                timer.invalidate()
                self.blackScreenTimer = nil
                
                // Resume videos
                self.shouldPauseVideos = false
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showBlackScreen = false
                }
                
                // Reset animation values for next time
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.breakTextOffset = 0
                    self.breakTextOpacity = 1.0
                }
            }
        }
    }
    
    private func pauseAllVideosExcept(current: Int) {
        // This function will be called when switching videos
        // The individual ReelsVideoPlayer's onDisappear will handle pausing
        print("🎬 Pausing all videos except index: \(current)")
    }
    
    private func pauseAllVideos() {
        // This function will be called when leaving the videos tab
        print("🎬 Pausing all videos - leaving videos tab")
    }
}

#Preview {
    ReelsContainerView(timeTrackingManager: TimeTrackingManager())
}
