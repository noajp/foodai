//======================================================================
// MARK: - SearchTrendsSection.swift
// Path: foodai/Features/Search/Components/SearchTrendsSection.swift
//======================================================================

import SwiftUICore
import SwiftUI
struct SearchTrendsSection: View {
    private let trends = [
        "Best restaurants in San Francisco",
        "Restaurants near me",
        "New restaurants in San Francisco",
        "Best restaurants in New York",
        "Restaurants with outdoor seating"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search trends")
                .font(AppEnvironment.Fonts.primaryBold(size: 18))
                .foregroundColor(AppEnvironment.Colors.textPrimary)
            
            VStack(spacing: 0) {
                ForEach(trends, id: \.self) { trend in
                    SearchTrendRowView(title: trend)
                    
                    if trend != trends.last {
                        Divider()
                            .background(AppEnvironment.Colors.subtleBorder)
                    }
                }
            }
        }
    }
}

struct SearchTrendRowView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppEnvironment.Fonts.primary(size: 16))
                .foregroundColor(AppEnvironment.Colors.textPrimary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Image(systemName: "arrow.right")
                .foregroundColor(AppEnvironment.Colors.textSecondary)
                .font(.system(size: 14))
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle trend tap
        }
    }
}

