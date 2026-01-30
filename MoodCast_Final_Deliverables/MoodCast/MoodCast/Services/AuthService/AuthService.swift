//
//  AuthService.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import Foundation
import FirebaseAuth

struct UserModel: Codable {
    var userId: String?
    var name: String?
    var email: String?
    var spotifyLinked: Bool?
}

class AuthService {
    private init() {}
    static let shared = AuthService()
    
    let dataService = DataService.shared
    
    func createAccount(name: String, email: String, password: String) async throws {
        let userAuthModel = try await Auth.auth().createUser(withEmail: email, password: password)
        let userId = userAuthModel.user.uid
        
        // Save name and email in Firestore using user id.
        let userModel = UserModel(userId: userId, name: name, email: email, spotifyLinked: false)
        try await dataService.saveUserModelToFirestore(userModel: userModel)
        
        // Set the user defaults.
        setUserDefaults(userId: userId, name: name, email: email)
    }
    
    func signIn(email: String, password: String) async throws {
        let userAuthModel = try await Auth.auth().signIn(withEmail: email, password: password)
        let userId = userAuthModel.user.uid
        
        // Retrieve user details from Firestore
        let userModel = try await dataService.getUserModelFromFirestore(userId: userId)
        
        guard let name = userModel?.name, let email = userModel?.email else {
            print("Error unwrapping user name or email.")
            return
        }
        
        let dataService = DataService.shared
        dataService.getSpotifyProfileDetails { model in
            self.setProfileDefaults(
                followers: model?.followers?.total ?? 0,
                country: model?.country ?? "",
                spotifyId: model?.id ?? "",
                imageUrl: model?.images?[0].url ?? ""
            )
        }
        
        setUserDefaults(
            userId: userId,
            name: name,
            email: email
        )
    }
    
    func signOut() {
        removeUserDefaults()
    }

    private func setProfileDefaults(followers: Int, country: String, spotifyId: String, imageUrl: String) {
        UserDefaults.standard.set(followers, forKey: "user_followers")
        UserDefaults.standard.set(country, forKey: "user_country")
        UserDefaults.standard.set(spotifyId, forKey: "linked_spotify_id")
        UserDefaults.standard.set(imageUrl, forKey: "image_url")
    }
    
    private func setUserDefaults(userId: String, name: String, email: String) {
        UserDefaults.standard.set(userId, forKey: "user_id")
        UserDefaults.standard.set(name, forKey: "user_name")
        UserDefaults.standard.set(email, forKey: "user_email")
    }
    
    private func removeUserDefaults() {
        let defaults = UserDefaults.standard
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
    }
}
