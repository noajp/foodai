//======================================================================
// MARK: - CreatePostViewModel.swift（完全版）
// Path: foodai/Features/CreatePost/ViewModels/CreatePostViewModel.swift
//======================================================================
import SwiftUI
import Supabase

@MainActor
class CreatePostViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var restaurantName = ""
    @Published var restaurantArea = ""
    @Published var restaurantAddress = ""
    @Published var rating = 0
    @Published var caption = ""
    
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var isPostCreated = false
    
    private let postService = PostService()
    private let supabase = SupabaseManager.shared.client
    
    var canPost: Bool {
        selectedImage != nil &&
        !restaurantName.isEmpty &&
        !restaurantArea.isEmpty &&
        rating > 0
    }
    
    func createPost() async {
        guard canPost else { return }
        guard let image = selectedImage else { return }
        guard let userId = AuthManager.shared.currentUser?.id else {
            errorMessage = "ログインが必要です"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            // 1. 画像をSupabase Storageにアップロード
            let imageUrl = try await uploadImage(image)
            
            // 2. レストランを作成または取得
            let restaurantId = try await createOrGetRestaurant()
            
            // 3. 投稿を作成
            try await createPostRecord(
                userId: userId,
                restaurantId: restaurantId,
                imageUrl: imageUrl
            )
            
            isPostCreated = true
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw PostError.imageProcessingFailed
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let filePath = "posts/\(fileName)"
        
        // Supabase Storageにアップロード
        _ = try await supabase.storage
            .from("user-uploads")
            .upload(
                filePath,
                data: imageData
            )
        
        // 公開URLを構築
        let projectUrl = Config.supabaseURL
        let publicUrl = "\(projectUrl)/storage/v1/object/public/user-uploads/\(filePath)"
        
        return publicUrl
    }
    
    private func createOrGetRestaurant() async throws -> String {
        // 既存のレストランを検索
        let existingRestaurants: [Restaurant] = try await supabase
            .from("restaurants")
            .select("*")
            .eq("name", value: restaurantName)
            .eq("area", value: restaurantArea)
            .execute()
            .value
        
        if let existing = existingRestaurants.first {
            return existing.id
        }
        
        // 新規作成
        struct NewRestaurant: Encodable {
            let name: String
            let area: String
            let address: String?
        }
        
        let newRestaurant = NewRestaurant(
            name: restaurantName,
            area: restaurantArea,
            address: restaurantAddress.isEmpty ? nil : restaurantAddress
        )
        
        let response: Restaurant = try await supabase
            .from("restaurants")
            .insert(newRestaurant)
            .select()
            .single()
            .execute()
            .value
        
        return response.id
    }
    
    private func createPostRecord(userId: String, restaurantId: String, imageUrl: String) async throws {
        struct NewPost: Encodable {
            let user_id: String
            let restaurant_id: String
            let media_url: String
            let media_type: String
            let caption: String?
            let rating: Int
        }
        
        let newPost = NewPost(
            user_id: userId,
            restaurant_id: restaurantId,
            media_url: imageUrl,
            media_type: "photo",
            caption: caption.isEmpty ? nil : caption,
            rating: rating
        )
        
        try await supabase
            .from("posts")
            .insert(newPost)
            .execute()
    }
}

enum PostError: LocalizedError {
    case imageProcessingFailed
    case uploadFailed
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "画像の処理に失敗しました"
        case .uploadFailed:
            return "アップロードに失敗しました"
        }
    }
}
