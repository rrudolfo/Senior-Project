//
//  LinkSpotifyViewModel.swift
//  CSCD-488-Project
//
//  Created by Jacob Lucas on 3/1/25.
//

import SwiftUI

class LinkSpotifyViewModel: ObservableObject {
    
    @Published var accessToken: String? = nil
    @Published var refreshToken: String? = nil
    @Published var userProfile: UserProfile? = nil
    
    @AppStorage("user_id") var currentUserID: String?
    
    func handleCallbackURL(_ url: URL) {
        if url.scheme == "myapp", url.host == "spotify" {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = components?.queryItems
            
            // Extract the 'code' parameter
            if let code = queryItems?.first(where: { $0.name == "code" })?.value {
                print("Authorization code: \(code)")
                
                // retrieve and save tokens
                self.saveTokensToServer(code: code)
                
                // get basic user profile info
                // - spotify pfp to use as app pfp
                // - spotify name
            }
        }
    }
    
    private func saveTokensToServer(code: String) {
        guard let userID = currentUserID else {
            print("Error unwrapping user id.")
            return
        }
        
        Task {
            do {
                let dataService = DataService.shared
                try await dataService.saveTokensToServer(userID: userID, code: code)
            } catch(let error) {
                print("Error saving refresh token: ", error)
            }
        }
    }
    
    func fetchUserProfile(token: String) {
        guard let url = URL(string: "https://cscd-488-project.glitch.me/user-profile?access_token=\(token)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let profile = try JSONDecoder().decode(UserProfile.self, from: data)
                    DispatchQueue.main.async {
                        print("USER PROFILE: ", self.userProfile as Any)
                        self.userProfile = profile
                    }
                } catch {
                    print("Error decoding profile: \(error)")
                }
            }
        }.resume()
    }
    
    struct UserProfile: Codable {
        let displayName: String
        let email: String
        
        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case email
        }
    }
}
