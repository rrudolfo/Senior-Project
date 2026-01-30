//
//  SearchView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 5/3/25.
//

import SwiftUI

struct SearchView: View {
    
    @State var searchContent: String = ""
    
    @StateObject var mainViewModel: MainViewModel
    
    private var filteredEpisodes: [EpisodeModel] {
        if searchContent.isEmpty {
            return mainViewModel.favoritedEpisodes
        } else {
            return mainViewModel.favoritedEpisodes.filter { episode in
                if let name = episode.name?.lowercased(),
                   let desc = episode.description?.lowercased() {
                    return name.contains(searchContent.lowercased()) ||
                           desc.contains(searchContent.lowercased())
                }
                return false
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                header
                searchBar
                episodeList
            }
        }
    }
}

#Preview {
    SearchView(mainViewModel: MainViewModel())
}

extension SearchView {
    private var header: some View {
        HStack {
            Text("Search")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .padding([.top, .horizontal])
    }
    
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
            ZStack(alignment: .leading) {
                if searchContent.isEmpty {
                    Text("Search your favorite episodes.")
                        .font(.system(size: 15))
                }
                
                TextField("", text: $searchContent)
                    .foregroundColor(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(30)
        .overlay {
            Capsule()
                .stroke(lineWidth: 1)
                .fill(.white.opacity(0.1))
        }
        .padding()
    }
    
    private var episodeList: some View {
        VStack(spacing: 0) {
            if filteredEpisodes.count > 0 {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(filteredEpisodes) { episode in
                            EpisodeCell(
                                episode: episode,
                                mainViewModel: mainViewModel
                            )
                        }
                    }
                }
            } else {
                Text("No episodes found.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(.systemGray))
                    .frame(height: UIScreen.main.bounds.height / 1.55)
                Spacer()
            }
        }
        .padding([.horizontal, .bottom])
    }
}

struct EpisodeCell: View {
    
    let episode: EpisodeModel
    
    @State var showEpisodeView: Bool = false
    @StateObject var mainViewModel: MainViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button {
            triggerHaptic() 
            showEpisodeView.toggle()
        } label: {
            HStack(spacing: 16) {
                if let image = episode.image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                        .frame(width: 60, height: 60)
                }
                VStack(alignment: .leading, spacing: 4) {
                    if let name = episode.name,
                       let desc = episode.description {
                        Text(name)
                            .font(.headline)
                            .lineLimit(1)
                        Text(desc)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.up")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.label))
            }
        }
        .buttonStyle(ButtonScaleStyle())
        .padding()
        .background(
            Group {
                if let uiImage = episode.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(colorScheme == .dark ? .black.opacity(0.9) : .white.opacity(0.9))
                        .blur(radius: 20)
                        .overlay(.ultraThinMaterial)
                } else {
                    Color(.systemGray6)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .fullScreenCover(isPresented: $showEpisodeView) {
            PodcastView(
                episode: episode,
                mainViewModel: mainViewModel
            )
        }
    }
    
    func triggerHaptic() {
        let haptics = HapticsFeedbackManager.shared
        haptics.triggerVibration()
    }
}

