//
//  PodcastSelectionView.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 2/27/25.
//

import SwiftUI

struct PodcastSelectionView: View {
    var body: some View {
        ZStack {
            CardStack()
            
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "bookmark.fill")
                        .font(.title3)
                }
                .padding()
                Spacer()
                mediaControlBar
            }
        }
    }
}

extension PodcastSelectionView {
    private var mediaControlBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 34, height: 34)
                Text("Podcast Name")
                    .font(.system(size: 14, weight: .medium))
                Spacer()
                HStack(spacing: 12) {
                    Image(systemName: "pause.fill")
                    Image(systemName: "forward.fill")
                }
                .font(.headline)
                .padding(.horizontal, 10)
            }
            .padding(10)
            
            Rectangle()
                .frame(height: 3)
                .foregroundStyle(Color(.systemGray5))
                .overlay(
                    Rectangle()
                        .frame(width: 200, height: 3)
                    ,alignment: .leading
                )
        }
        .background {
            Rectangle()
                .foregroundStyle(Color(.systemGray6))
        }
    }
    
    private var menu: some View {
        VStack {
            
        }
    }
}

#Preview {
    PodcastSelectionView()
}
