import Foundation

class ContentService {
    static let shared = ContentService()
    
    private var allReels: [Reel] = []
    
    private init() {
        loadMockReels()
    }
    
    private func loadMockReels() {
        // Generate mock reels for demo
        var reels: [Reel] = []
        
        for i in 0..<50 {
            let category = ContentCategory.allCases.randomElement()!
            let platform: Platform = Bool.random() ? .tiktok : .instagram
            
            reels.append(Reel(
                id: "reel_\(i)",
                videoURL: "mock_video_\(i)",
                platform: platform,
                category: category,
                duration: Double.random(in: 15...60),
                isTrending: Bool.random()
            ))
        }
        
        allReels = reels
    }
    
    func getReels(for categories: [ContentCategory]) -> [Reel] {
        guard !categories.isEmpty else { return allReels.shuffled() }
        
        return allReels
            .filter { categories.contains($0.category) }
            .shuffled()
    }
    
    func getTrendingReels() -> [Reel] {
        return allReels.filter { $0.isTrending }
    }
}
