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
    
    func fetchShortsVideos(channelId: String? = nil, query: String? = "shorts", maxResults: Int = 15) {
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
        fetchShortsVideos(query: "trending shorts", maxResults: 15)
    }
    
    func fetchPopularShorts() {
        fetchShortsVideos(query: "popular shorts", maxResults: 15)
    }
}

// MARK: - YouTube API Response Models

struct YouTubeSearchResponse: Codable {
    let items: [YouTubeSearchItem]
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
