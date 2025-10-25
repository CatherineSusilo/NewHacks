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
    let timeTrackingManager: TimeTrackingManager
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var isMuted = false
    @State private var isLiked = false
    @State private var likeCount = 0
    @State private var showMuteAnimation = false
    @State private var isPressed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Video Player
                if let player = player {
                    VideoPlayer(player: player)
                        .aspectRatio(9/16, contentMode: .fit)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .onAppear {
                            setupPlayer()
                        }
                }
                
                // Gesture Overlay for Press and Tap
                Color.clear
                    .contentShape(Rectangle())
                    .onLongPressGesture(minimumDuration: 0) { pressing in
                        isPressed = pressing
                        if pressing {
                            // Pause when pressed
                            player?.pause()
                            isPlaying = false
                        } else {
                            // Resume when released
                            player?.play()
                            isPlaying = true
                        }
                    } perform: {
                        // This closure is called when the long press gesture completes
                    }
                    .onTapGesture {
                        // Toggle mute/unmute on tap
                        toggleMute()
                    }
                
                // Mute/Unmute Animation Overlay
                if showMuteAnimation {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.6))
                                            .frame(width: 80, height: 80)
                                    )
                                
                                Text(isMuted ? "Muted" : "Unmuted")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.top, 4)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showMuteAnimation)
                }
                
                // Right Side Action Buttons
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 20) {
                            // Like Button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
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
                                        .scaleEffect(isLiked ? 1.3 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
                                    
                                    Text("\(likeCount)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
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
    }
    
    private func toggleMute() {
        guard let player = player else { return }
        
        isMuted.toggle()
        player.isMuted = isMuted
        
        // Show animation
        withAnimation {
            showMuteAnimation = true
        }
        
        // Hide animation after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showMuteAnimation = false
            }
        }
    }
}

#Preview {
    ReelsVideoPlayer(videoURL: URL(fileURLWithPath: "sample_video.mp4"), timeTrackingManager: TimeTrackingManager())
}