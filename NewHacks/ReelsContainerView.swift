//
//  ReelsContainerView.swift
//  NewHacks
//

import SwiftUI

struct ReelsContainerView: View {
    @State private var currentIndex = 0
    @StateObject private var youTubeManager = YouTubeManager()
    
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
                                ReelsVideoPlayer(videoID: youTubeManager.videoIDs[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .ignoresSafeArea()
                        .onChange(of: currentIndex) { newIndex in
                            print("Switched to Short index: \(newIndex)")
                        }
                        
                        // Debug indicator with refresh button
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Short \(currentIndex + 1) of \(youTubeManager.videoIDs.count)")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(8)
                                    
//                                    Button("Refresh") {
//                                        loadDifferentShorts()
//                                    }
//                                    .padding(8)
//                                    .background(Color.blue)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(8)
//                                    .font(.caption)
                                }
                                Spacer()
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
        }
        .refreshable {
            loadDifferentShorts()
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
}

#Preview {
    ReelsContainerView()
}
