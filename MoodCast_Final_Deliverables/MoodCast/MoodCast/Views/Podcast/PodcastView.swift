//
//  PodcastView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/6/25.
//

import SwiftUI

struct PodcastView: View {
    
    let episode: EpisodeModel
    let dataService = DataService.shared
    
    @StateObject var viewModel: PodcastViewModel
    @StateObject var mainViewModel: MainViewModel
    
    @State var showFullTitle: Bool = false
    @State var showFullDesc: Bool = false
    
    init(episode: EpisodeModel, mainViewModel: MainViewModel) {
        self.episode = episode
        _viewModel = StateObject(wrappedValue: PodcastViewModel(episode: episode))
        _mainViewModel = StateObject(wrappedValue:mainViewModel)
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heading
                mainImage
                episodeDetails
                controls
            }
        }
        .navigationBarBackButtonHidden()
        .background(
            VStack {
                if let uiImage = episode.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: UIScreen.main.bounds.height)
                        .overlay(Color.black.opacity(0.5))
                        .blur(radius: 20)
                        .overlay(.ultraThinMaterial)
                        .clipShape(Rectangle())
                        .ignoresSafeArea()
                }
            }
        )
        .foregroundStyle(.white)
        .statusBarHidden()
    }
}

extension PodcastView {
    private var mainImage: some View {
        VStack {
            if let uiImage = episode.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: UIScreen.main.bounds.width - 32,
                        height: UIScreen.main.bounds.width - 32
                    )
                    .clipped()
                    .cornerRadius(20)
                    .padding(.vertical)
            }
        }
    }
    
    private var heading: some View {
        HStack(spacing: 14) {
            Button {
                triggerHaptic()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(8)
                    .background {
                        Circle()
                            .foregroundStyle(.white.opacity(0.1))
                    }
            }
            .buttonStyle(ButtonScaleStyle())
            
            Spacer()
            Button {
                triggerHaptic()
                openEpisodeInSpotify(episode: episode)
            } label: {
                Image("spotify_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }
            .buttonStyle(ButtonScaleStyle())
            
            Button {
                triggerHaptic()
                removeFavoriteAndDismiss(episode: episode)
            } label: {
                Image(systemName: "heart.fill")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(
                        Circle()
                            .foregroundStyle(.white.opacity(0.1))
                    )
            }
            .buttonStyle(ButtonScaleStyle())
        }
        .padding()
    }
    
    private var episodeDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let name = episode.name {
                    Text(name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(showFullTitle ? .max : 1)
                        .onTapGesture {
                            showFullTitle.toggle()
                        }
                }
                
                Spacer(minLength: 0)
            }
            
            if let desc = episode.description {
                Text(desc)
                    .lineSpacing(3)
                    .opacity(0.6)
                    .font(.body)
                    .lineLimit(showFullDesc ? .max : 2)
                    .onTapGesture {
                        showFullDesc.toggle()
                    }
            }
            
            if showFullDesc {
                VStack(alignment: .leading, spacing: 10) {
                    if let publisher = episode.show?.publisher {
                        Text(publisher)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .foregroundStyle(.white)
            }
        }
        .padding()
    }
    
    private var controls: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .foregroundStyle(.white.opacity(0.1))
                        Capsule()
                            .foregroundStyle(.white.opacity(0.8))
                            .frame(width: progressWidth(geometry: geo), height: 10)
                            .animation(.linear(duration: 0.5), value: viewModel.currentPlaybackTime)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Text("4:21")
                    Spacer()
                    Text("-3.06")
                }
                .foregroundStyle(.white.opacity(0.6))
                .font(.caption)
            }
            .padding(.vertical)
            .font(.subheadline)
            
            HStack {
                Spacer(minLength: 0)
                
                Button {
                    viewModel.seekBackwardsEpisode()
                } label: {
                    Image(systemName: "backward.fill")
                }
                .buttonStyle(ButtonScaleStyle())
                
                Spacer(minLength: 0)
                Button {
                    viewModel.playOrPauseEpisode()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                }
                .buttonStyle(ButtonScaleStyle())
                
                Spacer(minLength: 0)
                
                Button {
                    viewModel.seekForwardEpisode()
                } label: {
                    Image(systemName: "forward.fill")
                }
                .buttonStyle(ButtonScaleStyle())
                
                Spacer(minLength: 0)
            }
            .padding()
            .padding(.bottom)
            .font(.largeTitle)
            .fontWeight(.semibold)
        }
        .padding()
    }
    
    private func progressWidth(geometry: GeometryProxy) -> CGFloat {
        guard viewModel.totalDuration > 0 else { return 0 }
        let fraction = CGFloat(viewModel.currentPlaybackTime / viewModel.totalDuration)
        return geometry.size.width * fraction
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    private func removeFavoriteAndDismiss(episode: EpisodeModel) {
        guard let eid = episode.episodeId else {
            print("Episode ID missing")
            return
        }

        Task {
            do {
                try await dataService.removeEpisode(episodeId: eid)
                await MainActor.run {
                    mainViewModel.favoritedEpisodes.removeAll { $0.episodeId == eid }
                    dismiss()
                }
            } catch {
                print("Failed to remove episode: \(error)")
            }
        }
    }
    
    func addFavorite(episode: EpisodeModel) {
        let dataService = DataService.shared
        
        Task {
            do {
                try await dataService.saveEpisode(episode: episode)
            } catch {
                print("Failed to remove episode: \(error)")
            }
        }
    }
    
    func openEpisodeInSpotify(episode: EpisodeModel) {
        let spotifyAppScheme = "spotify://"
        
        if let uri = episode.uri, let spotifyURL = URL(string: uri) {
            if UIApplication.shared.canOpenURL(URL(string: spotifyAppScheme)!) {
                // Open in Spotify app
                UIApplication.shared.open(spotifyURL, options: [:], completionHandler: nil)
                return
            }
        }
        
        if let externalURL = episode.externalURLs?.spotify {
            UIApplication.shared.open(externalURL, options: [:], completionHandler: nil)
            return
        }
        
        if let url = episode.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func triggerHaptic() {
        let haptics = HapticsFeedbackManager.shared
        haptics.triggerVibration()
    }
}
