//======================================================================
// MARK: - PostService.swift（投稿データ取得サービス）
// Path: foodai/Core/Services/PostService.swift
//======================================================================
import Foundation
import Supabase

// Supabaseから取得するデータ構造
struct PostResponse: Codable {
    let id: String
    let userId: String
    let restaurantId: String
    let mediaUrl: String
    let mediaType: String
    let thumbnailUrl: String?
    let caption: String?
    let rating: Int
    let visitDate: String?
    let createdAt: String
    
    // リレーション
    let userProfiles: UserProfile?
    let restaurants: Restaurant?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case restaurantId = "restaurant_id"
        case mediaUrl = "media_url"
        case mediaType = "media_type"
        case thumbnailUrl = "thumbnail_url"
        case caption, rating
        case visitDate = "visit_date"
        case createdAt = "created_at"
        case userProfiles = "user_profiles"
        case restaurants
    }
}

class PostService {
    private let client = SupabaseManager.shared.client
    
    // フィード用の投稿一覧を取得
    func fetchFeedPosts() async throws -> [Post] {
        print("🔵 PostService: フィード投稿を取得開始")
        
        let response: [PostResponse] = try await client
            .from("posts")
            .select("""
                *,
                user_profiles!inner(
                    id,
                    username,
                    display_name,
                    avatar_url
                ),
                restaurants!inner(
                    id,
                    name,
                    area,
                    address,
                    latitude,
                    longitude,
                    google_place_id
                )
            """)
            .eq("is_public", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        print("✅ PostService: \(response.count)件の投稿を取得")
        
        // ResponseからPostモデルに変換
        return response.map { res in
            Post(
                id: res.id,
                userId: res.userId,
                restaurantId: res.restaurantId,
                mediaUrl: res.mediaUrl,
                mediaType: Post.MediaType(rawValue: res.mediaType) ?? .photo,
                thumbnailUrl: res.thumbnailUrl,
                caption: res.caption,
                rating: res.rating,
                visitDate: nil, // TODO: 日付変換
                createdAt: Date(), // TODO: 日付変換
                user: res.userProfiles,
                restaurant: res.restaurants
            )
        }
    }
    
    // 特定ユーザーの投稿を取得
    func fetchUserPosts(userId: String) async throws -> [Post] {
        let response: [PostResponse] = try await client
            .from("posts")
            .select("""
                *,
                user_profiles!inner(*),
                restaurants!inner(*)
            """)
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response.map { res in
            Post(
                id: res.id,
                userId: res.userId,
                restaurantId: res.restaurantId,
                mediaUrl: res.mediaUrl,
                mediaType: Post.MediaType(rawValue: res.mediaType) ?? .photo,
                thumbnailUrl: res.thumbnailUrl,
                caption: res.caption,
                rating: res.rating,
                visitDate: nil,
                createdAt: Date(),
                user: res.userProfiles,
                restaurant: res.restaurants
            )
        }
    }
}
