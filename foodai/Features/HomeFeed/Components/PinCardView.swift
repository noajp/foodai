//======================================================================
// MARK: - 更新版 PinCardView（SNS用）
// Path: foodai/Features/HomeFeed/Components/PinCardView.swift
//======================================================================
import SwiftUI

struct PinCardView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // メディア（写真/動画）
            RemoteImageView(imageURL: post.mediaUrl)
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // 情報部分
            VStack(alignment: .leading, spacing: 8) {
                // レストラン名
                Text(post.restaurant?.name ?? "Unknown Restaurant")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // 評価とエリア
                HStack(spacing: 4) {
                    // 星評価
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < post.rating ? "star.fill" : "star")
                                .foregroundColor(index < post.rating ? .yellow : .gray.opacity(0.3))
                                .font(.system(size: 12))
                        }
                    }
                    
                    Spacer()
                    
                    // エリア
                    if let area = post.restaurant?.area {
                        Text(area)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                // ユーザー情報
                HStack(spacing: 6) {
                    // アバター
                    if let avatarUrl = post.user?.avatarUrl {
                        RemoteImageView(imageURL: avatarUrl)
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 20, height: 20)
                    }
                    
                    // ユーザー名
                    Text(post.user?.username ?? "unknown")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
