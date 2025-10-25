//
//  ReelsVideoPlayer.swift
//  NewHacks
//

import SwiftUI
import WebKit

struct ReelsVideoPlayer: View {
    let videoID: String
    @State private var isLiked = false
    @State private var likeCount = Int.random(in: 100...5000)
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                
                if let error = errorMessage {
                    // Error state
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        
                        Text("Video Not Available")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text(error)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            isLoading = true
                            errorMessage = nil
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else {
                    // Direct YouTube Shorts URL with audio always on
                    YouTubeShortsView(videoID: videoID, isLoading: $isLoading, errorMessage: $errorMessage)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    
                    if isLoading {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                            Text("Loading Short...")
                                .foregroundColor(.white)
                                .font(.caption)
                                .padding(.top, 8)
                        }
                    }
                }
                
                // Right Side Action Buttons
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 20) {
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
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000.0)
        } else if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000.0)
        } else {
            return "\(count)"
        }
    }
}

// Direct YouTube Shorts URL with audio always on
struct YouTubeShortsView: UIViewRepresentable {
    let videoID: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        
        loadYouTubeShorts(in: webView)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No updates needed - audio is always on
    }
    
    private func loadYouTubeShorts(in webView: WKWebView) {
        // Use Direct YouTube Shorts URL
        let shortsURL = "https://www.youtube.com/shorts/\(videoID)"
        
        guard let url = URL(string: shortsURL) else {
            errorMessage = "Invalid video URL"
            isLoading = false
            return
        }
        
        print("🔗 Loading YouTube Short: \(shortsURL)")
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: YouTubeShortsView
        
        init(_ parent: YouTubeShortsView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            
            // Ensure audio is always on and video plays automatically
            let audioScript = """
            // Ensure audio is unmuted and video plays
            setTimeout(function() {
                var video = document.querySelector('video');
                if (video) {
                    // Unmute the video
                    video.muted = false;
                    // Play the video if paused
                    if (video.paused) {
                        video.play().catch(function(e) {
                            console.log('Auto-play failed:', e);
                        });
                    }
                }
                
                // Try clicking play button if video doesn't play
                var playButton = document.querySelector('.ytp-play-button');
                if (playButton && playButton.getAttribute('data-title-no-tooltip') === 'Play') {
                    playButton.click();
                }
            }, 1000);
            """
            
            webView.evaluateJavaScript(audioScript, completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = "Failed to load: \(error.localizedDescription)"
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = "Network error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ReelsVideoPlayer(videoID: "NdjT8oatAYA")
}
