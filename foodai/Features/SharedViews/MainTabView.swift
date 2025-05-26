//======================================================================
// MARK: - MainTabView.swift の更新（投稿画面を追加）
// Path: foodai/Features/SharedViews/MainTabView.swift
//======================================================================
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingCreatePost = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeFeedView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)
            
            // 投稿ボタン（真ん中）
            Text("")
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                }
                .tag(1)
                .onAppear {
                    if selectedTab == 1 {
                        showingCreatePost = true
                        selectedTab = 0 // 元のタブに戻る
                    }
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "person.fill" : "person")
                }
                .tag(2)
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView()
        }
    }
}
