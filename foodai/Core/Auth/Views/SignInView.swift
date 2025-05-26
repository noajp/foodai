//======================================================================
// MARK: - 改善版 SignInView（詳細なエラー表示）
// Path: foodai/Features/Auth/Views/SignInView.swift
//======================================================================
import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isTesting = false
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // ロゴ部分
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("foodai")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 入力フィールド
                VStack(spacing: 15) {
                    TextField("メールアドレス", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disabled(isLoading)
                    
                    SecureField("パスワード", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                
                // ログインボタン
                Button(action: signIn) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("ログイン")
                            .fontWeight(.bold)
                    }
                }
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(25)
                .disabled(isLoading || email.isEmpty || password.isEmpty)
                
                // テスト用ボタン
                VStack(spacing: 15) {
                    Text("テスト用アカウント")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 20) {
                        Button("test1でログイン") {
                            email = "test1@example.com"
                            password = "testpass123"
                            signIn()
                        }
                        .font(.caption)
                        .disabled(isLoading)
                        
                        Button("test2でログイン") {
                            email = "test2@example.com"
                            password = "testpass123"
                            signIn()
                        }
                        .font(.caption)
                        .disabled(isLoading)
                    }
                    
                    // 接続テストボタン
                    Button("接続テスト") {
                        testConnection()
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                    .disabled(isTesting)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .alert("エラー", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func signIn() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
            } catch {
                // エラーの詳細を表示
                if let nsError = error as NSError? {
                    if nsError.code == -1009 {
                        errorMessage = "インターネット接続を確認してください"
                    } else if nsError.code == -1001 {
                        errorMessage = "接続がタイムアウトしました"
                    } else {
                        errorMessage = "エラー: \(error.localizedDescription)\nコード: \(nsError.code)"
                    }
                } else {
                    errorMessage = error.localizedDescription
                }
                showError = true
                print("ログインエラー詳細: \(error)")
            }
            isLoading = false
        }
    }
    
    private func testConnection() {
        isTesting = true
        Task {
            await NetworkTest.testSupabaseConnection()
            isTesting = false
            
            // 結果をアラートで表示
            errorMessage = "接続テスト完了 - コンソールログを確認してください"
            showError = true
        }
    }
}
