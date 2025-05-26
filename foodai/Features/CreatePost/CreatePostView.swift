//======================================================================
// MARK: - CreatePostView（動画対応版）
// Path: foodai/Features/CreatePost/Views/CreatePostView.swift
//======================================================================
import SwiftUI
import PhotosUI
import AVKit
import UniformTypeIdentifiers

@MainActor
struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showingMediaPicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. メディア選択
                    MediaPickerSection(
                        selectedImage: $viewModel.selectedImage,
                        selectedVideoURL: $viewModel.selectedVideoURL,
                        mediaType: $viewModel.mediaType,
                        showingMediaPicker: $showingMediaPicker,
                        selectedItem: $selectedItem
                    )
                    
                    // 2. レストラン情報
                    RestaurantInputSection(
                        restaurantName: $viewModel.restaurantName,
                        restaurantArea: $viewModel.restaurantArea,
                        restaurantAddress: $viewModel.restaurantAddress
                    )
                    
                    // 3. 評価
                    RatingSection(rating: $viewModel.rating)
                    
                    // 4. コメント
                    CommentSection(caption: $viewModel.caption)
                    
                    // 5. 投稿ボタン
                    VStack(spacing: 10) {
                        if viewModel.isLoading {
                            ProgressView(value: viewModel.uploadProgress) {
                                Text("アップロード中...")
                                    .font(.caption)
                            }
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding(.horizontal)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.createPost()
                                if viewModel.isPostCreated {
                                    dismiss()
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("投稿する")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.canPost ? AppEnvironment.Colors.accentGreen : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(!viewModel.canPost || viewModel.isLoading)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .alert("エラー", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "投稿に失敗しました")
            }
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                guard let newItem = newItem else { return }
                
                // メディアタイプを判定
                let contentType = try? await newItem.loadTransferable(type: Data.self)
                
                // 一旦データとして読み込んで判定
                if let data = contentType {
                    // 動画かどうかを判定（簡易的な方法）
                    if let image = UIImage(data: data) {
                        // 画像の処理
                        viewModel.mediaType = .photo
                        viewModel.selectedImage = image
                        viewModel.selectedVideoURL = nil
                    } else {
                        // 動画として処理を試みる
                        viewModel.mediaType = .video
                        // TODO: 動画の処理
                    }
                }
            }
        }
    }
}

// メディア選択セクション
struct MediaPickerSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    @Binding var mediaType: Post.MediaType
    @Binding var showingMediaPicker: Bool
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("写真・動画を選択")
                .font(.headline)
                .padding(.horizontal)
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .any(of: [.images, .videos])
            ) {
                if let image = selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                            .cornerRadius(10)
                        
                        if mediaType == .video {
                            // 動画インジケーター
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        
                        // メディアタイプバッジ
                        Text(mediaType == .video ? "動画" : "写真")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            .padding(8)
                    }
                    .padding(.horizontal)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay(
                            VStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("タップして写真・動画を選択")
                                    .foregroundColor(.gray)
                            }
                        )
                        .padding(.horizontal)
                }
            }
        }
    }
}

// レストラン情報入力セクション
struct RestaurantInputSection: View {
    @Binding var restaurantName: String
    @Binding var restaurantArea: String
    @Binding var restaurantAddress: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("レストラン情報")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                // レストラン名
                TextField("レストラン名", text: $restaurantName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // エリア
                TextField("エリア（例：東京都渋谷区）", text: $restaurantArea)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // 住所
                TextField("住所（任意）", text: $restaurantAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
        }
    }
}

// 評価セクション
struct RatingSection: View {
    @Binding var rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("評価")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 10) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.system(size: 30))
                        .foregroundColor(star <= rating ? .yellow : .gray)
                        .onTapGesture {
                            rating = star
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

// コメントセクション
struct CommentSection: View {
    @Binding var caption: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("コメント")
                .font(.headline)
                .padding(.horizontal)
            
            TextEditor(text: $caption)
                .frame(height: 100)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
}

// 動画転送用の構造体
struct VideoTransferable: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "video_\(UUID().uuidString).mp4")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self(url: copy)
        }
    }
}
