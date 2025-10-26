//
//  YouTubeManager.swift
//  NewHacks
//

import Foundation

class YouTubeManager: ObservableObject {
    private let apiKey = "AIzaSyCwmwIT02BK-t6G2vaqzCozWN0AL5bul9I" // Replace with your actual API key
    private let baseURL = "https://www.googleapis.com/youtube/v3"
    
    @Published var videoIDs: [String] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Preloading state
    private var currentPageToken: String?
    private var isPreloading = false
    private let preloadThreshold = 5 // Start preloading when 5 videos remain
    
    func fetchShortsVideos(channelId: String? = nil, query: String? = "shorts", maxResults: Int = 50) {
        isLoading = true
        error = nil
        
        // REMOVE THIS: Don't use hardcoded test videos
        // let testVideoIDs = ["dQw4w9WgXcQ", "jNQXAC9IVRw", ...]
        
        // UNCOMMENT AND USE THE ACTUAL API CALL:
        var urlComponents = URLComponents(string: "\(baseURL)/search")
        var queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoDuration", value: "short"),
            URLQueryItem(name: "maxResults", value: "\(maxResults)"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        if let channelId = channelId {
            queryItems.append(URLQueryItem(name: "channelId", value: channelId))
        }
        
        if let query = query {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            error = "Invalid URL"
            isLoading = false
            return
        }
        
        print("🔗 Fetching YouTube Shorts from: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = "Network error: \(error.localizedDescription)"
                    print("❌ Network error: \(error)")
                    return
                }
                
                guard let data = data else {
                    self?.error = "No data received"
                    print("❌ No data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let searchResponse = try decoder.decode(YouTubeSearchResponse.self, from: data)
                    print("✅ Found \(searchResponse.items.count) YouTube Shorts")
                    self?.processVideoItems(searchResponse.items)
                } catch {
                    self?.error = "JSON decoding error: \(error.localizedDescription)"
                    print("❌ JSON error: \(error)")
                    // Print the raw response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Raw response: \(responseString.prefix(500))...")
                    }
                }
            }
        }.resume()
    }
    
    private func processVideoItems(_ items: [YouTubeSearchItem]) {
        var ids: [String] = []
        
        for item in items {
            let videoId = item.id.videoId
            ids.append(videoId)
            print("📹 Found Short: \(item.snippet.title) - ID: \(videoId)")
        }
        
        videoIDs = ids
        
        if ids.isEmpty {
            error = "No YouTube Shorts found. Try a different search term."
        }
    }
    
    // Add this method to fetch different content
    func fetchTrendingShorts() {
        fetchShortsVideos(query: "trending shorts", maxResults: 50)
    }
    
    func fetchPopularShorts() {
        fetchShortsVideos(query: "popular shorts", maxResults: 50)
    }
    
    // MARK: - Preloading Methods
    
    func checkAndPreloadIfNeeded(currentIndex: Int) {
        let remainingVideos = videoIDs.count - currentIndex - 1
        
        if remainingVideos <= preloadThreshold && !isPreloading && currentPageToken != nil {
            print("🔄 Preloading more videos (remaining: \(remainingVideos))")
            preloadMoreVideos()
        }
    }
    
    private func preloadMoreVideos() {
        guard let pageToken = currentPageToken, !isPreloading else { return }
        
        isPreloading = true
        print("📥 Preloading next page of videos...")
        
        var urlComponents = URLComponents(string: "\(baseURL)/search")
        var queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "videoDuration", value: "short"),
            URLQueryItem(name: "maxResults", value: "25"), // Load 25 more videos
            URLQueryItem(name: "pageToken", value: pageToken),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        // Use the same search terms as the original search
        queryItems.append(URLQueryItem(name: "q", value: "shorts"))
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            isPreloading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isPreloading = false
                
                if let error = error {
                    print("❌ Preload error: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No preload data received")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let searchResponse = try decoder.decode(YouTubeSearchResponse.self, from: data)
                    let newVideoIDs = searchResponse.items.map { $0.id.videoId }
                    
                    // Append new videos to existing list
                    self?.videoIDs.append(contentsOf: newVideoIDs)
                    self?.currentPageToken = searchResponse.nextPageToken
                    
                    print("✅ Preloaded \(newVideoIDs.count) more videos (total: \(self?.videoIDs.count ?? 0))")
                } catch {
                    print("❌ Preload JSON error: \(error)")
                }
            }
        }.resume()
    }
}

// MARK: - YouTube API Response Models

struct YouTubeSearchResponse: Codable {
    let items: [YouTubeSearchItem]
    let nextPageToken: String?
}

struct YouTubeSearchItem: Codable {
    let id: YouTubeVideoId
    let snippet: YouTubeSnippet
}

struct YouTubeVideoId: Codable {
    let videoId: String
}

struct YouTubeSnippet: Codable {
    let title: String
    let description: String
    let thumbnails: YouTubeThumbnails
}

struct YouTubeThumbnails: Codable {
    let `default`: YouTubeThumbnail
    let medium: YouTubeThumbnail
    let high: YouTubeThumbnail
}

struct YouTubeThumbnail: Codable {
    let url: String
    let width: Int?
    let height: Int?
}
