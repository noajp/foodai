//======================================================================
// MARK: - CreatePostView.swift（投稿作成画面）
// Path: foodai/Features/CreatePost/Views/CreatePostView.swift
//======================================================================
import SwiftUI
import PhotosUI

@MainActor
struct CreatePostView: View {
    @StateObject private var viewModel = CreatePostViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. 写真選択
                    PhotoPickerSection(selectedImage: $viewModel.selectedImage)
                    
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
                    .background(viewModel.canPost ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!viewModel.canPost || viewModel.isLoading)
                    .padding(.horizontal)
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
    }
}

// 写真選択セクション
struct PhotoPickerSection: View {
    @Binding var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("写真を選択")
                .font(.headline)
                .padding(.horizontal)
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .onTapGesture {
                        showingImagePicker = true
                    }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("タップして写真を選択")
                                .foregroundColor(.gray)
                        }
                    )
                    .padding(.horizontal)
                    .onTapGesture {
                        showingImagePicker = true
                    }
            }
        }
        .photosPicker(
            isPresented: $showingImagePicker,
            selection: $selectedItem,
            matching: .images
        )
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
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
