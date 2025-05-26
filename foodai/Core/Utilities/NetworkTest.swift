//======================================================================
// MARK: - ネットワーク接続テスト
// Path: foodai/Core/Utilities/NetworkTest.swift
//======================================================================
import Foundation

class NetworkTest {
    static func testSupabaseConnection() async {
        print("🔵 Supabase接続テスト開始")
        print("URL: \(Config.supabaseURL)")
        print("Key: \(String(Config.supabaseAnonKey.prefix(20)))...")
        
        // 1. URLが正しいか確認
        guard let url = URL(string: Config.supabaseURL) else {
            print("❌ 無効なURL")
            return
        }
        
        // 2. 基本的な接続テスト
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ HTTP Status: \(httpResponse.statusCode)")
            }
        } catch {
            print("❌ 接続エラー: \(error)")
        }
        
        // 3. Supabase APIテスト
        do {
            let supabase = SupabaseManager.shared.client
            // health checkエンドポイントをテスト
            let testUrl = URL(string: "\(Config.supabaseURL)/rest/v1/")!
            var request = URLRequest(url: testUrl)
            request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Supabase API Status: \(httpResponse.statusCode)")
            }
        } catch {
            print("❌ Supabase APIエラー: \(error)")
        }
    }
}
