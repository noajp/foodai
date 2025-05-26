//======================================================================
// MARK: - MapView（地図画面）
// Path: foodai/Features/Map/Views/MapView.swift
//======================================================================
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671), // 東京
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                // 地図
                Map(coordinateRegion: $region, annotationItems: viewModel.restaurants) { restaurant in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: restaurant.latitude ?? 35.6812,
                        longitude: restaurant.longitude ?? 139.7671
                    )) {
                        RestaurantMapPin(restaurant: restaurant)
                    }
                }
                .ignoresSafeArea(edges: .top)
                
                // 検索バー
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("エリアやレストランを検索", text: $viewModel.searchText)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                    
                    Spacer()
                }
                
                // 現在地ボタン
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // 現在地に移動
                            viewModel.centerOnCurrentLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding()
                                .background(AppEnvironment.Colors.accentGreen)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("地図")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// レストランのマップピン
struct RestaurantMapPin: View {
    let restaurant: Restaurant
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(AppEnvironment.Colors.accentGreen)
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 10))
                .foregroundColor(AppEnvironment.Colors.accentGreen)
                .offset(y: -3)
        }
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            RestaurantQuickView(restaurant: restaurant)
        }
    }
}

// レストランのクイックビュー
struct RestaurantQuickView: View {
    let restaurant: Restaurant
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text(restaurant.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let area = restaurant.area {
                    Label(area, systemImage: "map")
                        .foregroundColor(.secondary)
                }
                
                if let address = restaurant.address {
                    Label(address, systemImage: "location")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("レストラン情報")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MapViewModel
@MainActor
class MapViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var searchText = ""
    
    init() {
        loadMockRestaurants()
    }
    
    func loadMockRestaurants() {
        // モックデータのレストラン
        restaurants = [
            Restaurant(
                id: "1",
                name: "トラットリア ベラ",
                area: "東京都渋谷区",
                address: "渋谷1-2-3",
                latitude: 35.6580,
                longitude: 139.7016,
                googlePlaceId: nil,
                createdAt: Date()
            ),
            Restaurant(
                id: "2",
                name: "麺屋 極",
                area: "東京都新宿区",
                address: "新宿3-4-5",
                latitude: 35.6896,
                longitude: 139.7006,
                googlePlaceId: nil,
                createdAt: Date()
            ),
            Restaurant(
                id: "3",
                name: "鮨処 かねさか",
                area: "東京都港区",
                address: "港区赤坂1-2-3",
                latitude: 35.6762,
                longitude: 139.7363,
                googlePlaceId: nil,
                createdAt: Date()
            )
        ]
    }
    
    func centerOnCurrentLocation() {
        // TODO: 現在地を取得して中心に移動
        print("現在地に移動")
    }
}
