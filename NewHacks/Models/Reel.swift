import Foundation

struct Reel: Identifiable, Codable {
    let id: String
    let videoURL: String
    let platform: Platform
    let category: ContentCategory
    let duration: TimeInterval
    let isTrending: Bool
}

enum Platform: String, CaseIterable {
    case tiktok = "TikTok"
    case instagram = "Instagram Reels"
}
