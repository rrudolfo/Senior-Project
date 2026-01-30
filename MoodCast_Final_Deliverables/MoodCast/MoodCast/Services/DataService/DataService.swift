//
//  DataService.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI
import FirebaseFirestore

let FIRESTORE_REF = Firestore.firestore()

class DataService {
    
    private init() {}
    static let shared = DataService()
    
    private let getUserModelEndpoint = "/get_data/"
    private let saveUserModelEndpoint = "/save_data/"
    private let serverURL = "https://cscd-488-project.glitch.me"
    
    let USER_REF = FIRESTORE_REF.collection("users")
    
    @AppStorage("user_id") var currentUserId: String?
    
    // MARK: FIRESTORE REQUESTS
    
    /* **************************** SAVE USER DETAILS **************************** */
    
    func saveUserModelToFirestore(userModel: UserModel) async throws {
        let userId = userModel.userId
        
        guard let userId = userId else {
            print("Unable to unwrap user id.")
            return
        }
        
        guard let components = URLComponents(string: serverURL + saveUserModelEndpoint + userId) else {
            throw APICallError.urlComponentsFailed
        }
        
        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(userModel)
            request.httpBody = jsonData
        
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let jsonString = String(data: data, encoding: .utf8)
            print(jsonString)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APICallError.requestFailed
            }
            
            print("User data saved successfully.")
        } catch {
            throw error
        }
    }
    
    /* **************************** GET USER DETAILS **************************** */
    
    func getUserModelFromFirestore(userId: String) async throws -> UserModel? {
        guard let components = URLComponents(string: serverURL + getUserModelEndpoint + userId) else {
            throw APICallError.urlComponentsFailed
        }
        
        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let userModel = try decoder.decode(UserModel.self, from: data)
            
            print("Returned user model from Firestore.")
            return userModel
        } catch {
            throw error
        }
    }
    
    // MARK: IMAGE RETRIEVAL
    
    /* **************************** RETRIEVE IMAGE **************************** */
    
    func retrieveImageFromUrl(imageUrl: URL) async throws -> UIImage {
        var request = URLRequest(url: imageUrl)
        request.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            guard let image = UIImage(data: data) else {
                throw APICallError.decodingFailed
            }
            
            print("Successfully retrieved episode image.")
            return image
        } catch {
            print("Failed to retrieve episode image: ", error)
            throw APICallError.requestFailed
        }
    }
    
    func retrieveImageFromUrl(imageUrl: String) async throws -> UIImage {
        guard let url = URL(string: imageUrl) else {
            throw APICallError.decodingFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            guard let image = UIImage(data: data) else {
                throw APICallError.decodingFailed
            }

            print("Successfully retrieved episode image.")
            return image
        } catch {
            print("Failed to retrieve episode image:", error)
            throw APICallError.requestFailed
        }
    }

    // MARK: SPOTIFY REQUESTS
    
    /* **************************** PLAY EPISODE **************************** */
    
    func playPodcastEpisode(episodeUri: String) async throws -> Bool {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return false
        }

        guard let components = URLComponents(string: serverURL + "/play-podcast") else {
            throw APICallError.urlComponentsFailed
        }

        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: String] = [
            "episodeUri": episodeUri,
            "userId": userId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APICallError.requestFailed
            }

            print("Podcast episode play request sent successfully.")
            return true
        } catch {
            throw error
        }
    }
    
    /* **************************** PAUSE EPISODE **************************** */
    
    func pausePodcastEpisode(userId: String) async throws -> Bool {
        guard let components = URLComponents(string: serverURL + "/pause-podcast") else {
            throw APICallError.urlComponentsFailed
        }

        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: String] = ["userId": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APICallError.requestFailed
            }

            print("Podcast playback paused successfully.")
            return true
        } catch {
            throw error
        }
    }
    
    /* **************************** SEEK EPISODE **************************** */
    
    func seekPodcastEpisode(offsetMs: Int) async throws {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return
        }
        
        guard let components = URLComponents(string: serverURL + "/seek-podcast") else {
            throw APICallError.urlComponentsFailed
        }

        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "userId": userId,
            "offsetMs": offsetMs
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APICallError.requestFailed
            }

            print("Podcast seek request sent successfully.")
        } catch {
            throw error
        }
    }
    
    func toggleFavoriteEpisode(userId: String, episodeId: String) async throws {
        guard let components = URLComponents(string: serverURL + "/toggle-favorite-episode") else {
            throw APICallError.urlComponentsFailed
        }

        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: String] = [
            "userId": userId,
            "episodeId": episodeId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APICallError.requestFailed
            }

            print("Favorite episode toggled successfully!")
        } catch {
            throw error
        }
    }

    enum APICallError: Error {
        case urlComponentsFailed
        case urlCreationFailed
        case requestFailed
        case decodingFailed
    }
    
    func getPlaybackStatus() async throws -> PlaybackStatus? {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return nil
        }
        
        guard let components = URLComponents(string: serverURL + "/get-podcast-status") else {
            throw APICallError.urlComponentsFailed
        }

        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: String] = ["userId": userId]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            let responseString = String(data: data, encoding: .utf8) ?? "N/A"
            print("Response body: \(responseString)")
            throw APICallError.requestFailed
        }
        
        if let rawJSONString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(rawJSONString)")
        } else {
            print("Unable to convert data to string")
        }
        
        do {
            let playback = try JSONDecoder().decode(PlaybackStatus.self, from: data)
            return playback
        } catch {
            throw APICallError.decodingFailed
        }
    }
    
    /* **************************** SKIP FORWARD EPISODE **************************** */
    
    func skipForwardPodcastEpisode() async throws {
        guard let components = URLComponents(string: serverURL + "/skip-forward") else {
            throw APICallError.urlComponentsFailed
        }
        
        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APICallError.requestFailed
            }
            
            print("Podcast skipped forward successfully.")
        } catch {
            throw error
        }
    }

    /* **************************** GENERATE EPISODE STACK **************************** */
    
    func generatePodcastEpisodes(mood: String) async throws -> [EpisodeModel] {
        guard let userId = currentUserId else {
            print("Unable to unwrap user id.")
            return []
        }

        let endpoint = "\(serverURL)/podcasts/\(mood)/\(userId)"
        guard let components = URLComponents(string: endpoint) else {
            throw APICallError.urlComponentsFailed
        }

        guard let url = components.url else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            print("Received JSON:", jsonObject)

            let episodes = try decoder.decode([EpisodeModel].self, from: data)
            return episodes

        } catch {
            throw error
        }
    }
    
    /* **************************** SAVE EPISODE **************************** */
    
    func saveEpisode(episode: EpisodeModel) async throws {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return
        }

        guard let url = URL(string: "\(serverURL)/save-episode/\(userId)") else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let jsonData = try encoder.encode(episode)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status code:", httpResponse.statusCode)
            if let responseBody = String(data: data, encoding: .utf8) {
                print("Response body:", responseBody)
            }
            guard httpResponse.statusCode == 200 else {
                throw APICallError.requestFailed
            }
        }
    }

    func removeEpisode(episodeId: String) async throws {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return
        }

        guard let url = URL(string: "\(serverURL)/remove-episode") else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare the data to send, including userId and episodeId
        let requestBody: [String: Any] = [
            "userId": userId,
            "episodeId": episodeId
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code:", httpResponse.statusCode)
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body:", responseBody)
                }
                guard httpResponse.statusCode == 200 else {
                    throw APICallError.requestFailed
                }
            }
        } catch {
            throw error
        }
    }

    
    struct EpisodeResponse: Decodable {
        let episodes: [EpisodeModel]
    }

    func getSavedEpisodes() async throws -> [EpisodeModel]? {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return nil
        }
        
        guard let url = URL(string: "\(serverURL)/get-episodes/\(userId)") else {
            throw APICallError.urlCreationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APICallError.requestFailed
            }

            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(EpisodeResponse.self, from: data)
            return decodedResponse.episodes
        } catch {
            throw error
        }
    }
    
    func saveSpotifyProfileDetails(profile: SpotifyProfileModel) {
        guard let userId = currentUserId else {
            print("Cannot save: missing user ID.")
            return
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let data = try? encoder.encode(profile),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let jsonDict = jsonObject as? [String: Any] else {
            print("Failed to convert model to dictionary.")
            return
        }

        USER_REF.document(userId).setData(jsonDict) { error in
            if let error = error {
                print("Error saving to Firestore:", error.localizedDescription)
            } else {
                print("Spotify profile saved successfully for user \(userId).")
            }
        }
    }
    
    func getSpotifyProfileDetails(completion: @escaping (SpotifyProfileModel?) -> ()) {
        guard let userId = currentUserId else {
            print("Cannot fetch: missing user ID.")
            completion(nil)
            return
        }

        USER_REF.document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching from Firestore:", error.localizedDescription)
                completion(nil)
                return
            }

            guard let data = document?.data() else {
                print("No Spotify profile data found for user \(userId).")
                completion(nil)
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let profile = try decoder.decode(SpotifyProfileModel.self, from: jsonData)
                completion(profile)
            } catch {
                print("Failed to decode Spotify profile:", error.localizedDescription)
                completion(nil)
            }
        }
    }
    
    func saveBlockedEpisode(episode: EpisodeModel) {
        guard let userId = currentUserId else {
            print("Cannot save: missing user ID.")
            return
        }
        
        let episodeId = episode.episodeId
        
        let userDocRef = USER_REF.document(userId)
        
        userDocRef.updateData(["blocked_episode_ids": FieldValue.arrayUnion([episodeId])]) { error in
            if let error = error {
                print("Error saving blocked episode: \(error.localizedDescription)")
            } else {
                print("Blocked episode saved successfully.")
            }
        }
    }

    func getBlockedEpisodes() async -> [String] {
        guard let userId = currentUserId else {
            print("Cannot fetch: missing user ID.")
            return []
        }

        let userDocRef = USER_REF.document(userId)

        do {
            let documentSnapshot = try await userDocRef.getDocument()
            if let data = documentSnapshot.data(),
               let blockedEpisodes = data["blocked_episode_ids"] as? [String] {
                return blockedEpisodes
            } else {
                return []
            }
        } catch {
            print("Error fetching blocked episodes: \(error.localizedDescription)")
            return []
        }
    }
}

/* **************************** ERROR CALLS **************************** */

enum APICallError: Error {
    case urlComponentsFailed
    case urlCreationFailed
    case requestFailed
    case decodingFailed
    case imageFetchFailed
    case imageConversionFailed
    
    var localizedDescription: String {
        switch self {
        case .urlComponentsFailed:
            return "Failed to create URL components."
        case .urlCreationFailed:
            return "Failed to create URL from components."
        case .requestFailed:
            return "Request failed."
        case .decodingFailed:
            return "Decoding failed."
        case .imageFetchFailed:
            return "Failed to fetch image data."
        case .imageConversionFailed:
            return "Failed to convert data to image."
        }
    }
}


struct PlaybackStatus: Decodable {
    let playing: Bool
    let type: String
    let name: String
    let id: String
    let image: String?
    let progress_ms: Int?
    let duration_ms: Int?
    let played_at: String?
}
