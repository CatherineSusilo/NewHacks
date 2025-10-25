//
//  ReelsContainerView.swift
//  NewHacks
//

import SwiftUI

struct ReelsContainerView: View {
    @State private var currentIndex = 0
    @StateObject private var youTubeManager = YouTubeManager()
    @State private var dragOffset: CGFloat = 0
    @State private var videos: [URL] = []
    @ObservedObject var timeTrackingManager: TimeTrackingManager
    @State private var showBlackScreen = false
    @State private var blackScreenTimer: Timer?
    @State private var blackScreenCountdown = 3
    @State private var videoPlayers: [Int: ReelsVideoPlayer] = [:]
    @State private var shouldPauseVideos = false
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
                                            .padding()
                                        
                                        Text("\(blackScreenCountdown)")
                                            .font(.system(size: 60, weight: .bold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding()
                                        
                                        Text("seconds remaining")
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding(.bottom, 50)
                                        
                                        Spacer()
                                    }
                                )
                                .allowsHitTesting(false) // Prevent interaction during black screen
                        }
                        
                        // Debug indicator and time tracking display
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Short \(currentIndex + 1) of \(youTubeManager.videoIDs.count)")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(8)
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
    
    private func loadVideos() {
        // Load local video files
        let videoFiles = ["IMG_2537.MOV", "IMG_2540.MOV", "IMG_2541.MOV", "IMG_2542.MOV", "IMG_2543.MOV"]
        videos = videoFiles.compactMap { fileName in
            Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".MOV", with: ""), withExtension: "MOV")
        }
    }
    
    private func loadYouTubeShorts() {
        // Search for various Shorts content
        let searchTerms = ["funny shorts", "dance shorts", "comedy shorts", "gaming shorts", "music shorts"]
        let randomTerm = searchTerms.randomElement() ?? "shorts"
        
        youTubeManager.fetchShortsVideos(query: randomTerm, maxResults: 15)
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
        youTubeManager.fetchShortsVideos(query: randomTerm, maxResults: 15)
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
        
        // Pause all videos immediately
        shouldPauseVideos = true
        
        // Show black screen
        withAnimation(.easeInOut(duration: 0.3)) {
            showBlackScreen = true
        }
        
        // Reset countdown
        blackScreenCountdown = 3
        
        // Start timer
        blackScreenTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            print("⏱️ Black screen countdown: \(self.blackScreenCountdown)")
            self.blackScreenCountdown -= 1
            
            if self.blackScreenCountdown <= 0 {
                print("✅ Black screen timer finished, resuming video")
                // Timer finished, hide black screen
                timer.invalidate()
                self.blackScreenTimer = nil
                
                // Resume videos
                self.shouldPauseVideos = false
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showBlackScreen = false
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
