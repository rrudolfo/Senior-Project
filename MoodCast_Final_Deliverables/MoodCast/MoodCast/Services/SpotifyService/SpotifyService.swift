//
//  SpotifyService.swift
//  MoodCast
//
//  Created by Jacob Lucas on 5/12/25.
//

import Foundation

class SpotifyService {
    static let shared = SpotifyService()
    private let baseURL = "https://cscd-488-project.glitch.me"
    
    func fetchUserProfile(userId: String) async throws -> SpotifyProfileModel {
        guard var urlComponents = URLComponents(string: "\(baseURL)/user-profile") else {
            throw URLError(.badURL)
        }
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: userId)]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let userProfile = try decoder.decode(SpotifyProfileModel.self, from: data)
        
        return userProfile
    }
}
