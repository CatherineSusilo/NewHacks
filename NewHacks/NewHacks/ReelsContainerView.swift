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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                if !videos.isEmpty {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<videos.count, id: \.self) { index in
                            ReelsVideoPlayer(videoURL: videos[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .ignoresSafeArea()
                } else {
                    // Loading or empty state
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Loading videos...")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
            }
        }
        .onAppear {
            loadVideos()
        }
    }
    
    private func loadVideos() {
        // For now, we'll just use the one video file
        // In a real app, you'd load multiple videos
        if let videoURL = Bundle.main.url(forResource: "IMG_2537", withExtension: "MOV") {
            videos = [videoURL, videoURL, videoURL] // Duplicate for demo purposes
        }
    }
}

#Preview {
    ReelsContainerView()
}
