//
//  ReelsVideoPlayer.swift
//  NewHacks
//
//  Created by Hassan Ibrahim on 2025-10-25.
//

import SwiftUI
import AVKit
import AVFoundation

struct ReelsVideoPlayer: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var showControls = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isLiked = false
    @State private var likeCount = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .aspectRatio(9/16, contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .onTapGesture {
                            togglePlayPause()
                        }
                        .onAppear {
                            setupPlayer()
                        }
                }
                
                // Controls Overlay
                VStack {
                    Spacer()
                    
                    // Bottom Controls
                    HStack {
                        // Progress Bar
                        VStack {
                            Spacer()
                            HStack {
                                ProgressView(value: currentTime, total: duration)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                    .frame(height: 2)
                                    .padding(.horizontal, 20)
                                Spacer()
                            }
                            .padding(.bottom, 10)
                        }
                    }
                }
                .opacity(showControls ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: showControls)
                
                // Right Side Action Buttons (Instagram Style)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 20) {
                            // Like Button
                            Button(action: {
                                withAnimation(.spring()) {
                                    isLiked.toggle()
                                    if isLiked {
                                        likeCount += 1
                                    } else {
                                        likeCount = max(0, likeCount - 1)
                                    }
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(isLiked ? .red : .white)
                                        .scaleEffect(isLiked ? 1.2 : 1.0)
                                    
                                    Text("\(likeCount)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // Comment Button
                            Button(action: {
                                // Add comment functionality
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "message")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    Text("0")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // Share Button
                            Button(action: {
                                // Add share functionality
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "paperplane")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    Text("0")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            // More Options
                            Button(action: {
                                // Add more options
                            }) {
                                Image(systemName: "ellipsis")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
                
                // Play/Pause Overlay
                if !isPlaying {
                    Button(action: togglePlayPause) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation {
                showControls.toggle()
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        
        // Get video duration
        let asset = AVAsset(url: videoURL)
        let duration = asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        self.duration = durationSeconds
        
        // Set up time observer
        let timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: 600), queue: .main) { time in
            self.currentTime = CMTimeGetSeconds(time)
        }
        
        // Set up notification for when video ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            // Loop the video
            self.player?.seek(to: .zero)
            self.player?.play()
        }
        
        // Auto-play
        player?.play()
        isPlaying = true
        
        // Hide controls after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showControls = false
            }
        }
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
}

#Preview {
    ReelsVideoPlayer(videoURL: URL(fileURLWithPath: "sample_video.mp4"))
}
