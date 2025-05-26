//======================================================================
// MARK: - 4. RestaurantDetailView を PostDetailView に置き換え
// Path: foodai/Features/PostDetail/Views/PostDetailView.swift (新規作成)
//======================================================================
import SwiftUI
import MapKit

struct PostDetailView: View {
    let post: Post
    @State private var region: MKCoordinateRegion
    
    init(post: Post) {
        self.post = post
        
        // マップの初期位置を設定
        let latitude = post.restaurant?.latitude ?? 35.6812
        let longitude = post.restaurant?.longitude ?? 139.7671
        
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 投稿画像
                RemoteImageView(imageURL: post.mediaUrl)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 400)
                    .clipped()
                    .background(Color.white)
                
                VStack(alignment: .leading, spacing: 16) {
                    // ユーザー情報
                    HStack {
                        if let avatarUrl = post.user?.avatarUrl {
                            RemoteImageView(imageURL: avatarUrl)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(post.user?.username ?? "unknown")
                                .font(.system(size: 16, weight: .semibold))
                            Text(post.createdAt, style: .date)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // レストラン情報
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.restaurant?.name ?? "Unknown Restaurant")
                            .font(.system(size: 24, weight: .bold))
                        
                        // 評価
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(post.rating) ? "star.fill" : "star")
                                    .foregroundColor(index < Int(post.rating) ? .yellow : .gray.opacity(0.3))
                                    .font(.system(size: 16))
                            }
                        }
                        
                        if let area = post.restaurant?.area {
                            Text(area)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // キャプション
                    if let caption = post.caption {
                        Text(caption)
                            .font(.system(size: 16))
                            .padding(.vertical, 8)
                    }
                    
                    Divider()
                    
                    // マップ
                    if post.restaurant?.latitude != nil {
                        Text("場所")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.top, 8)
                        
                        Map(coordinateRegion: $region, annotationItems: [post.restaurant!]) { restaurant in
                            MapMarker(coordinate: CLLocationCoordinate2D(
                                latitude: restaurant.latitude ?? 0,
                                longitude: restaurant.longitude ?? 0
                            ), tint: .red)
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                        
                        if let address = post.restaurant?.address {
                            Text(address)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }
}
