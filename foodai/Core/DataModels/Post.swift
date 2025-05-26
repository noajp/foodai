import Foundation

struct Post: Identifiable {
    let id: String
    let userId: String
    let restaurantId: String
    let mediaUrl: String
    let mediaType: MediaType
    let thumbnailUrl: String?
    let caption: String?
    let rating: Int
    let visitDate: Date?
    let createdAt: Date
    
    // リレーション
    var user: UserProfile?
    var restaurant: Restaurant?
    var likeCount: Int = 0
    var saveCount: Int = 0
    var isLikedByMe: Bool = false
    var isSavedByMe: Bool = false
    
    enum MediaType: String, Codable {
        case photo = "photo"
        case video = "video"
    }
}
