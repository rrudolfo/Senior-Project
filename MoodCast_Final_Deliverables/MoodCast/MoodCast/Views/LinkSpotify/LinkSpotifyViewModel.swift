//
//  LinkSpotifyViewModel.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/7/25.
//

import Foundation
import SwiftUI

class LinkSpotifyViewModel: ObservableObject {
    @Published var accessToken: String? = nil
    @Published var userDisplayName: String? = nil
    @Published var isAuthenticated: Bool = false
    
    @AppStorage("user_followers") var currentUserFollowers: Int?
    @AppStorage("user_country") var currentUserCountry: String?
    @AppStorage("linked_spotify_id") var linkedSpotifyId: String?
    @AppStorage("image_url") var imageUrl: String?
    
    private let backendURL = "https://cscd-488-project.glitch.me"
    
    @AppStorage("user_id") var currentUserId: String?
    
    func handleCallbackURL(_ url: URL) {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            print("Missing code in callback URL")
            return
        }
        
        print("Received Spotify auth code: \(code)")
        sendCodeToBackend(code: code)
    }
    
    private func sendCodeToBackend(code: String) {
        guard let userId = currentUserId else {
            print("Unable to unwrap user id.")
            return
        }
        
        guard let callbackURL = URL(string: "\(backendURL)/callback?code=\(code)&userId=\(userId)") else {
            print("Invalid backend callback URL")
            return
        }

        URLSession.shared.dataTask(with: callbackURL) { data, response, error in
            if let error = error {
                print("Callback error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No data received from callback")
                return
            }

            if let accessToken = String(data: data, encoding: .utf8) {
                print("Received access token:", accessToken)
                DispatchQueue.main.async {
                    self.accessToken = accessToken
                    self.isAuthenticated = true
                }
            } else {
                print("Failed to decode access token")
            }
        }.resume()
    }

    func fetchUserProfile(token: String) {
        print("Fetching user profile details.")
        
        guard let userId = currentUserId else {
            print("Unable to unwrap user id.")
            return
        }
        
        guard let url = URL(string: "\(backendURL)/user-profile?access_token=\(token)&userId=\(userId)") else {
            print("Invalid user-profile URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching user profile:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("No profile data")
                return
            }
            
            print("Raw JSON response:")
            if let rawJSON = String(data: data, encoding: .utf8) {
                print(rawJSON)
            }

            do {
                let userProfile = try JSONDecoder().decode(SpotifyProfileModel.self, from: data)
                self.addToDb(model: userProfile)
                
                DispatchQueue.main.async {
                    self.currentUserCountry = userProfile.country
                    self.currentUserFollowers = userProfile.followers?.total
                    self.linkedSpotifyId = userProfile.id
                    self.imageUrl = userProfile.images?[0].url
                }
            } catch {
                print("Error decoding Spotify user profile:", error)
            }
        }.resume()
    }
    
    private func addToDb(model: SpotifyProfileModel) {
        let dataService = DataService.shared
        dataService.saveSpotifyProfileDetails(profile: model)
    }
}

