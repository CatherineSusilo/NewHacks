//
//  ReelsContainerView.swift
//  NewHacks
//
//  Created by Hassan Ibrahim on 2025-10-25.
//

import SwiftUI

struct ReelsContainerView: View {
    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0
    @State private var videos: [URL] = []
    @StateObject private var timeTrackingManager = TimeTrackingManager()
    @State private var showBlackScreen = false
    @State private var blackScreenTimer: Timer?
    @State private var blackScreenCountdown = 3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                if !videos.isEmpty {
                    ZStack {
                        TabView(selection: $currentIndex) {
                            ForEach(0..<videos.count, id: \.self) { index in
                                ReelsVideoPlayer(videoURL: videos[index], timeTrackingManager: timeTrackingManager)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .ignoresSafeArea()
                        .onChange(of: currentIndex) { newIndex in
                            print("Switched to video index: \(newIndex)")
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
                        
                        // Time tracking display in upper right corner
                        VStack {
                            HStack {
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
                    // Loading or empty state
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Loading videos...")
                            .foregroundColor(.white)
                            .padding(.top)
                        Text("Found \(videos.count) videos")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .onAppear {
            loadVideos()
            timeTrackingManager.startTracking()
            checkTimeAndShowBlackScreen()
        }
        .onDisappear {
            timeTrackingManager.stopTracking()
            blackScreenTimer?.invalidate()
        }
    }

    private func loadVideos() {
        // Load all videos from the main bundle
        let videoFiles = ["IMG_2537.MOV", "IMG_2540.MOV", "IMG_2541.MOV", "IMG_2542.MOV", "IMG_2543.MOV"]
        var loadedVideos: [URL] = []
        
        for videoFile in videoFiles {
            let fileName = videoFile.replacingOccurrences(of: ".MOV", with: "")
            
            // Try to load from main bundle
            if let videoURL = Bundle.main.url(forResource: fileName, withExtension: "MOV") {
                loadedVideos.append(videoURL)
                print("✅ Loaded: \(fileName)")
            } else {
                print("❌ Could not find: \(fileName)")
            }
        }
        
        // If we have at least one video, duplicate it to create multiple videos for testing
        if !loadedVideos.isEmpty && loadedVideos.count < 5 {
            let firstVideo = loadedVideos.first!
            while loadedVideos.count < 5 {
                loadedVideos.append(firstVideo)
            }
            print("🔄 Duplicated first video to create \(loadedVideos.count) total videos")
        }
        
        videos = loadedVideos
        
        // Debug: Print loaded videos
        print("📱 Total loaded videos: \(loadedVideos.count)")
        for (index, url) in loadedVideos.enumerated() {
            print("Video \(index): \(url.lastPathComponent)")
        }
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
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showBlackScreen = false
                }
            }
        }
    }
}

#Preview {
    ReelsContainerView()
}
