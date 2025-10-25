import Foundation

#if DEBUG
struct MockData {
    static let sampleReels: [Reel] = [
        Reel(
            id: "reel_1",
            videoURL: "mock_video_1",
            platform: .tiktok,
            category: .gaming,
            duration: 30,
            isTrending: true
        ),
        Reel(
            id: "reel_2", 
            videoURL: "mock_video_2",
            platform: .instagram,
            category: .comedy,
            duration: 45,
            isTrending: false
        )
    ]
    
    static let sampleUser: User = User(
        selectedCategories: [.gaming, .comedy],
        dailyTimeLimit: 30 * 60,
        currentStreak: 5,
        totalTimeSaved: 120 * 60
    )
}
#endif
