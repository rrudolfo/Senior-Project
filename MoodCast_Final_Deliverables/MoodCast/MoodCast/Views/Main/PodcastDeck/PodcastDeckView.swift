//
//  PodcastDeckView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

struct PodcastDeckView: View {
    
    @State var showPodcastView: Bool = false
    @State var showFavoritesView: Bool = false
    
    @State var showFavoriteSuccess: Bool = false
    
    @AppStorage("user_name") var currentUserName: String?
    
    @StateObject var viewModel: MainViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        content
    }
}

extension PodcastDeckView {
    private var content: some View {
        VStack {
            header
            cardStack
            Spacer(minLength: 0)
//            controlWidget
        }
        .overlay(alignment: .top) {
            if showFavoriteSuccess {
                EpisodeSavedAlert()
                    .transition(.asymmetric(
                        insertion: .move(edge: .top),
                        removal: .move(edge: .top)
                    ))
                    .zIndex(1)
            }
        }
    }
    
    private var cardStack: some View {
        VStack {
            let model = SwipeableCardsView.Model(
                cards: viewModel.episodeStack,
                viewModel: viewModel
            )
            
            SwipeableCardsView(model: model, viewModel: viewModel) { model in
                for swiped in model.swipedCards {
                    if swiped.swipeDirection == .right {
                        self.toggleFavoriteAlert()
                        viewModel.handleRightSwipe(for: swiped)
                    } else if swiped.swipeDirection == .left {}
                    
                    viewModel.episodeStack.removeAll {
                        $0.id == swiped.id
                    }
                }
            }
            .offset(x: 16)
        }
        .padding(.top)
    }
    
    private func toggleFavoriteAlert() {
        withAnimation {
            self.showFavoriteSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showFavoriteSuccess = false
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("\(greeting()) 👋")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            CarToggle(
                isCarRide: $viewModel.isCarRide,
                emojiSelection: $viewModel.showEmojiSelection
            )
        }
        .padding()
    }

    private func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<21:
            return "Good evening"
        default:
            return "Good night"
        }
    }
    
//    private var controlWidget: some View {
//        VStack {
//            if let podcast = viewModel.widgetPodcast {
//                Button {
//                    showPodcastView.toggle()
//                } label: {
//                    HStack(spacing: 14) {
//                        Image("SwiftUI Basics")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 43, height: 43)
//                            .clipped()
//                            .cornerRadius(6)
//                        Text("Learn how to start with SwiftUI.")
//                            .font(.body)
//                            .fontWeight(.medium)
//                            .lineLimit(1)
//                        Spacer(minLength: 0)
//                        Button {
//                            if viewModel.isPlaying {
//                                
//                            } else {
//                                
//                            }
//                        } label: {
//                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
//                                .font(.headline)
//                        }
//                        Button {
//                            
//                        } label: {
//                            Image(systemName: "forward.fill")
//                                .font(.headline)
//                        }
//                    }
//                    .padding(8)
//                    .padding(.trailing, 12)
//                    .background {
//                        RoundedRectangle(cornerRadius: 10)
//                            .foregroundStyle(Color(.systemGray6))
//                    }
//                    .padding(.horizontal, 12)
//                }
//                .buttonStyle(ButtonScaleStyle())
//                .fullScreenCover(isPresented: $showPodcastView) {
//                    PodcastView(episode: EpisodeModel(
//                        episodeId: "",
//                        name: "kjnslfaSDF",
//                        urlString: "",
//                        desc: ""
//                    ))
//                }
//                .padding(.bottom, 1)
//            }
//        }
//    }
}

#Preview {
    PodcastDeckView(viewModel: MainViewModel())
}
