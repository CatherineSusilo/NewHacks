import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var currentVideoIndex = 0
    @State private var isPlaying = true
    @State private var showControls = false
    @State private var controlsTimer: Timer?
    
    var body: some View {
        ZStack {
            // Video Content
            if viewModel.currentReels.indices.contains(currentVideoIndex) {
                let currentReel = viewModel.currentReels[currentVideoIndex]
                
                VStack {
                    // Platform Indicator
                    HStack {
                        Image(systemName: platformIcon(currentReel.platform))
                            .foregroundColor(.white)
                        Text(currentReel.platform.rawValue)
                            .font(.caption)
                            .foregroundColor(.white)
                        Spacer()
                        Text(currentReel.category.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    // Video Player Area
                    ZStack {
                        Rectangle()
                            .fill(Color.black)
                            .aspectRatio(9/16, contentMode: .fit)
                        
                        // Mock Video Player (replace with actual AVPlayer)
                        VStack {
                            Spacer()
                            Image(systemName: "play.rectangle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Video: \(currentReel.id)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 8)
                            Spacer()
                        }
                        
                        // Controls Overlay
                        if showControls {
                            VStack {
                                Spacer()
                                HStack {
                                    Button(action: previousVideo) {
                                        Image(systemName: "backward.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    .disabled(currentVideoIndex == 0)
                                    
                                    Spacer()
                                    
                                    Button(action: togglePlayPause) {
                                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: nextVideo) {
                                        Image(systemName: "forward.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.black.opacity(0.5))
                                            .clipShape(Circle())
                                    }
                                    .disabled(currentVideoIndex == viewModel.currentReels.count - 1)
                                }
                                .padding(.horizontal, 40)
                                .padding(.bottom, 30)
                            }
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .onTapGesture {
                        toggleControls()
                    }
                    
                    // Video Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Trending in \(currentReel.category.rawValue)")
                                .font(.headline)
                            Spacer()
                            Text("\(formatTime(currentReel.duration))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("This is a sample \(currentReel.platform.rawValue) video in the \(currentReel.category.rawValue) category.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding()
                }
            } else {
                // Empty State
                VStack {
                    Image(systemName: "video.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No videos available")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Select categories in settings to see content")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .onAppear {
            loadCurrentVideo()
        }
        .onChange(of: currentVideoIndex) { _ in
            loadCurrentVideo()
        }
        .onChange(of: viewModel.currentReels) { _ in
            if currentVideoIndex >= viewModel.currentReels.count {
                currentVideoIndex = max(0, viewModel.currentReels.count - 1)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadCurrentVideo() {
        // Reset playback state when video changes
        isPlaying = true
        resetControlsTimer()
    }
    
    private func togglePlayPause() {
        isPlaying.toggle()
        resetControlsTimer()
    }
    
    private func nextVideo() {
        guard currentVideoIndex < viewModel.currentReels.count - 1 else { return }
        
        // Use the lag system if needed
        viewModel.swipeToNextReel()
        currentVideoIndex += 1
        resetControlsTimer()
    }
    
    private func previousVideo() {
        guard currentVideoIndex > 0 else { return }
        currentVideoIndex -= 1
        resetControlsTimer()
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        resetControlsTimer()
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        if showControls {
            controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    showControls = false
                }
            }
        }
    }
    
    private func platformIcon(_ platform: Platform) -> String {
        switch platform {
        case .tiktok: return "music.note"
        case .instagram: return "camera.fill"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Swipe Gesture Support
extension VideoPlayerView {
    func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer.Direction) {
        switch gesture {
        case .up:
            // Like or other action
            break
        case .down:
            // Dislike or other action
            break
        case .left:
            nextVideo()
        case .right:
            previousVideo()
        default:
            break
        }
    }
}

#Preview {
    VideoPlayerView(viewModel: ContentViewModel())
}
