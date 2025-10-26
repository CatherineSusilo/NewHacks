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
    @State private var videoPlayers: [Int: ReelsVideoPlayer] = [:]
    @State private var shouldPauseVideos = false
    @State private var blackScreenCountdown = 0
    @State private var sessionStartTime: Date?
    @State private var blackScreenCount = 0
    @State private var showPercentageScreen = false
    @State private var dailyLimitPercentage = 0.0
    
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
                        
                        // Black Screen Overlay with Dynamic Text
                        if showBlackScreen {
                            Color.black
                                .ignoresSafeArea()
                                .overlay(
                                    VStack {
                                        Spacer()
                                        
                                        if showPercentageScreen {
                                            // Percentage screen
                                            Text("Daily Limit Update")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                            
                                            Text("You have reached")
                                                .font(.headline)
                                                .foregroundColor(.white.opacity(0.8))
                                            
                                            Text("\(Int(dailyLimitPercentage))%")
                                                .font(.system(size: 80, weight: .bold, design: .monospaced))
                                                .foregroundColor(.yellow)
                                                .padding()
                                            
                                            Text("of your daily limit")
                                                .font(.headline)
                                                .foregroundColor(.white.opacity(0.8))
                                        } else {
                                            // Regular break screen
                                            Text("Take a break")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)
                                                .padding()
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
    
    private func calculateRandomizedCountdown() -> (seconds: Int, showPercentage: Bool) {
        // Check if this is the 5th black screen (show percentage)
        let shouldShowPercentage = (blackScreenCount + 1) % 5 == 0
        
        if shouldShowPercentage {
            // Calculate percentage of daily limit reached
            let totalWatchTime = timeTrackingManager.currentDayWatchTime
            dailyLimitPercentage = (totalWatchTime / fixedTimeThreshold) * 100
            
            print("📊 Showing percentage screen: \(dailyLimitPercentage)% of daily limit")
            return (seconds: 6, showPercentage: true)
        }
        
        // Regular probability distribution
        let random = Double.random(in: 0...1)
        let waitTime: Int
        
        if random <= 0.5 {
            // 50% chance: 3 seconds
            waitTime = 3
        } else if random <= 0.7 {
            // 20% chance: 5 seconds
            waitTime = 5
        } else if random <= 0.8 {
            // 10% chance: 6 seconds
            waitTime = 6
        } else if random <= 0.9 {
            // 10% chance: 7 seconds
            waitTime = 7
        } else {
            // 10% chance: 8 seconds
            waitTime = 8
        }
        
        print("🎲 Randomized wait time: \(waitTime) seconds")
        return (seconds: waitTime, showPercentage: false)
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
        // Check if total watch time exceeds 60% of fixedTimeThreshold
        print("🔍 Checking time: \(timeTrackingManager.currentDayWatchTime) seconds")
        if timeTrackingManager.currentDayWatchTime > (0.6 * fixedTimeThreshold)/60 {
            print("⏰ Time exceeded, starting black screen")
            startBlackScreenTimer()
        } else {
            print("✅ Time is under, no black screen needed")
        }
    }
    
    private func startBlackScreenTimer() {
        print("🖤 Starting black screen timer")
        
        // Increment black screen count
        blackScreenCount += 1
        
        // Calculate randomized countdown
        let countdownResult = calculateRandomizedCountdown()
        let countdownSeconds = countdownResult.seconds
        showPercentageScreen = countdownResult.showPercentage
        
        print("⏱️ Final countdown duration: \(countdownSeconds) seconds")
        print("📊 Show percentage screen: \(showPercentageScreen)")
        
        // Pause all videos immediately
        shouldPauseVideos = true
        
        // Set initial countdown
        blackScreenCountdown = countdownSeconds
        
        // Show black screen
        withAnimation(.easeInOut(duration: 0.3)) {
            showBlackScreen = true
        }
        
        // Start countdown timer
        startCountdownTimer(totalSeconds: countdownSeconds)
    }
    
    private func startCountdownTimer(totalSeconds: Int) {
        var remainingSeconds = totalSeconds
        
        blackScreenTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            remainingSeconds -= 1
            self.blackScreenCountdown = max(0, remainingSeconds)
            print("⏱️ Countdown: \(self.blackScreenCountdown)s remaining")
            
            if remainingSeconds <= 0 {
                print("✅ Black screen timer finished, resuming video")
                timer.invalidate()
                self.blackScreenTimer = nil
                
                // Resume videos
                self.shouldPauseVideos = false
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showBlackScreen = false
                }
                
                // Give a small delay to ensure video resumes properly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("🎬 Video should now be playing")
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
