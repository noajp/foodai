//======================================================================
// MARK: - AdvancedNetworkTest（詳細なネットワーク診断）
// Path: foodai/Core/Utilities/AdvancedNetworkTest.swift
//======================================================================
import Foundation

class AdvancedNetworkTest {
    
    static func runCompleteDiagnostics() async {
        print("\n🔥🔥🔥 完全ネットワーク診断開始 🔥🔥🔥\n")
        
        // 1. 基本的なインターネット接続
        await testBasicInternet()
        
        // 2. DNS解決テスト
        await testDNSResolution()
        
        // 3. Supabase直接アクセス
        await testSupabaseDirectAccess()
        
        // 4. 代替Supabaseエンドポイント
        await testAlternativeEndpoints()
        
        // 5. ネットワーク設定の詳細
        printNetworkConfiguration()
        
        print("\n🔥🔥🔥 診断完了 🔥🔥🔥\n")
    }
    
    // 1. 基本的なインターネット接続テスト
    static func testBasicInternet() async {
        print("📡 === 基本インターネット接続テスト ===")
        
        let testURLs = [
            "https://www.google.com",
            "https://api.github.com",
            "https://httpbin.org/get"
        ]
        
        for urlString in testURLs {
            guard let url = URL(string: urlString) else { continue }
            
            do {
                let start = Date()
                let (_, response) = try await URLSession.shared.data(from: url)
                let elapsed = Date().timeIntervalSince(start)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("✅ \(urlString): Status \(httpResponse.statusCode) - \(String(format: "%.2f", elapsed))秒")
                }
            } catch {
                print("❌ \(urlString): \(error.localizedDescription)")
            }
        }
    }
    
    // 2. DNS解決テスト
    static func testDNSResolution() async {
        print("\n🌐 === DNS解決テスト ===")
        
        let host = "yccjlkcxqybxqewzchen.supabase.co"
        
        do {
            let hostRef = CFHostCreateWithName(nil, host as CFString).takeRetainedValue()
            var resolved = DarwinBoolean(false)
            CFHostStartInfoResolution(hostRef, .addresses, nil)
            
            if let addresses = CFHostGetAddressing(hostRef, &resolved)?.takeUnretainedValue() as? [Data], resolved.boolValue {
                print("✅ DNS解決成功: \(host)")
                for address in addresses {
                    print("   IPアドレス: \(address.map { String(format: "%02x", $0) }.joined())")
                }
            } else {
                print("❌ DNS解決失敗: \(host)")
            }
        } catch {
            print("❌ DNS解決エラー: \(error)")
        }
    }
    
    // 3. Supabase直接アクセステスト
    static func testSupabaseDirectAccess() async {
        print("\n🔗 === Supabase直接アクセステスト ===")
        
        let baseURL = Config.supabaseURL
        let endpoints = [
            "",  // ルート
            "/rest/v1/",
            "/auth/v1/health",
            "/auth/v1/"
        ]
        
        for endpoint in endpoints {
            let urlString = baseURL + endpoint
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            request.setValue(Config.supabaseAnonKey, forHTTPHeaderField: "apikey")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let start = Date()
                let (data, response) = try await URLSession.shared.data(for: request)
                let elapsed = Date().timeIntervalSince(start)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("✅ \(endpoint): Status \(httpResponse.statusCode) - \(String(format: "%.2f", elapsed))秒")
                    
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("   レスポンス: \(String(responseString.prefix(100)))...")
                    }
                }
            } catch let error as NSError {
                print("❌ \(endpoint): エラーコード \(error.code) - \(error.localizedDescription)")
                analyzeError(error)
            }
        }
    }
    
    // 4. 代替エンドポイントテスト
    static func testAlternativeEndpoints() async {
        print("\n🔄 === 代替エンドポイントテスト ===")
        
        // 別のSupabaseプロジェクトでテスト（公開プロジェクト）
        let testURL = "https://xyzcompany.supabase.co/rest/v1/"
        
        if let url = URL(string: testURL) {
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    print("✅ 他のSupabaseプロジェクト: Status \(httpResponse.statusCode)")
                    print("   → Supabase自体は接続可能")
                }
            } catch {
                print("❌ 他のSupabaseプロジェクト: \(error.localizedDescription)")
            }
        }
    }
    
    // 5. ネットワーク設定の詳細
    static func printNetworkConfiguration() {
        print("\n⚙️ === ネットワーク設定 ===")
        
        let config = URLSessionConfiguration.default
        print("タイムアウト設定:")
        print("  - リクエストタイムアウト: \(config.timeoutIntervalForRequest)秒")
        print("  - リソースタイムアウト: \(config.timeoutIntervalForResource)秒")
        print("  - HTTP最大接続数: \(config.httpMaximumConnectionsPerHost)")
        print("  - クッキー受け入れ: \(config.httpCookieAcceptPolicy.rawValue)")
        
        // プロキシ設定
        if let proxyDict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] {
            print("\nプロキシ設定:")
            if let httpProxy = proxyDict["HTTPProxy"] {
                print("  ⚠️ HTTPプロキシ: \(httpProxy)")
            }
            if let httpsProxy = proxyDict["HTTPSProxy"] {
                print("  ⚠️ HTTPSプロキシ: \(httpsProxy)")
            }
            if proxyDict.isEmpty || (proxyDict["HTTPProxy"] == nil && proxyDict["HTTPSProxy"] == nil) {
                print("  ✅ プロキシなし")
            }
        }
    }
    
    // エラー分析
    static func analyzeError(_ error: NSError) {
        print("\n🔍 エラー詳細分析:")
        print("  - ドメイン: \(error.domain)")
        print("  - コード: \(error.code)")
        
        switch error.code {
        case -1001:
            print("  💡 タイムアウト: サーバーが応答しない")
            print("     → プロジェクトが一時停止中の可能性")
        case -1003:
            print("  💡 ホストが見つからない: DNSエラー")
        case -1004:
            print("  💡 サーバーに接続できない")
        case -1005:
            print("  💡 ネットワーク接続が失われた")
        case -1009:
            print("  💡 インターネット接続なし")
        default:
            print("  💡 その他のネットワークエラー")
        }
    }
}

