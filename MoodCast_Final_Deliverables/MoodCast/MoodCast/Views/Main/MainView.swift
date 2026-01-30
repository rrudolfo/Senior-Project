//
//  MainView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.selectedIndex {
            case 0:
                PodcastDeckView(viewModel: viewModel)
            case 1:
                SearchView(mainViewModel: viewModel)
            case 2:
                ProfileView()
            default:
                VStack {
                    Spacer()
                    Text("ERROR")
                    Spacer()
                }
            }
            
            Menu(index: $viewModel.selectedIndex)
        }
        .onAppear {
            viewModel.spotifyAccountLinked()
        }
        .fullScreenCover(isPresented: $viewModel.showLinkSpotifyView) {
            LinkSpotifyView()
        }
        .statusBarHidden()
    }
}

#Preview {
    MainView()
}
