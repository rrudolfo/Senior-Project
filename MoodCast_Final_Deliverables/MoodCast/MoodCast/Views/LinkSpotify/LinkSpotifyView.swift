//
//  LinkSpotifyView.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/3/25.
//

import SwiftUI

struct LinkSpotifyView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel = LinkSpotifyViewModel()
    
    @AppStorage("user_id") var currentUserId: String?
    
    var body: some View {
        VStack {
            Spacer()
            Image("link_spotify")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width - 40)
            Spacer()
            VStack(spacing: 0) {
                Text("Connect your Spotify.")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Link your Spotify to get personalized podcast recommendations based on your mood and ETE.")
                    .font(.system(size: 14))
                    .lineSpacing(4)
                    .foregroundStyle(Color(.systemGray))
                    .padding(.vertical)
            }
            .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button {
                    linkSpotify()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(height: 45)
                            .foregroundStyle(Color(.label))
                        HStack(spacing: 10) {
                            Image("spotify_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)
                                .padding(3)
                            Text("Link Spotify")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                        }
                    }
                }
                .buttonStyle(ButtonScaleStyle())
                
                Button {
                    dismiss()
                } label: {
                    Text("Later")
                }
                .buttonStyle(CapsuleButtonStyle(
                    textColor: Color(.label),
                    backgroundColor: Color(.systemGray5))
                )
            }
        }
        .padding()
        .onOpenURL { url in
            print("Received URL:", url)
            viewModel.handleCallbackURL(url)
        }
        .onChange(of: viewModel.accessToken) { (_, newToken) in
            if let token = newToken {
                viewModel.fetchUserProfile(token: token)
            }
        }
        .onChange(of: viewModel.isAuthenticated) { _, newValue in
            if newValue {
                dismiss()
                Task {
                    do {
                        guard let userId = currentUserId else { return }
                        let userModel = UserModel(userId: userId, spotifyLinked: true)
                        try await DataService.shared.saveUserModelToFirestore(userModel: userModel)
                    } catch (let error) {
                        print("Error: ", error)
                    }
                }
            }
        }
        .background {
            Color(red: 18/255, green: 18/255, blue: 18/255)
                .ignoresSafeArea()
        }
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
    }
    
    private func linkSpotify() {
        let url = "https://cscd-488-project.glitch.me/login"
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    LinkSpotifyView()
}
