//
//  EpisodeSavedAlert.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/27/25.
//

import SwiftUI

struct EpisodeSavedAlert: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack(spacing: 10) {
            Text("✅")
                .font(.system(size: 22))
            Text("Saved to Favorites")
                .font(.system(size: 18, weight: .semibold))
        }
        .padding(12)
        .padding(.horizontal, 5)
        .background {
            ZStack {
                Capsule()
                foregroundStyle(Color(.systemGray6))
                Capsule()
                    .stroke(lineWidth: 2)
                    .foregroundStyle(Color(.systemGray5))
            }
        }
    }
}

#Preview {
    EpisodeSavedAlert()
}
