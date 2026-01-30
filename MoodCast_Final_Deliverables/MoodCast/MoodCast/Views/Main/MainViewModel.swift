//
//  MainViewModel.swift
//  MoodCast
//
//  Created by Jacob Lucas on 4/1/25.
//

import SwiftUI

class MainViewModel: ObservableObject {
    
    @Published var selectedIndex = 0
    
    @Published var isCarRide: Bool = false
    @Published var isLoading: Bool = false
    
    @Published var showLinkSpotifyView: Bool = false
    @Published var showEmojiSelection: Bool = false
    
    @Published var episodeStack: [EpisodeModel] = []
    @Published var favoritedEpisodes: [EpisodeModel] = []
    
    @Published var widgetPodcast: EpisodeModel? = nil
    @Published var isPlaying: Bool = false
    
    @Published var blockedList: [String] = []
    
    @AppStorage("user_id") var currentUserId: String?
    
    init() {
        getBlockedList()
        getFavoriteEpisodes()
        getCurrentPlayingAudio()
    }
    
    @Published var playbackDetails: PlaybackStatus?

    private var playbackTimer: Timer?
    
    func getBlockedList() {
        Task {
            let dataService = DataService.shared
            let blockedEpisodes = await dataService.getBlockedEpisodes()
            self.blockedList = blockedEpisodes
        }
    }

    func startUpdatingPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task {
                do {
                    self.playbackDetails = try await DataService.shared.getPlaybackStatus()
                } catch {
                    print("Playback update failed:", error)
                }
            }
        }
    }
    
    func getCurrentPlayingAudio() {
        Task {
            do {
                let dataService = DataService.shared
                let details = try await dataService.getPlaybackStatus()
                print("CURRENT PLAYING AUDIO DETAILS: ", details)
            } catch(let error) {
                print("Error getting current playing audio: ", error)
            }
        }
    }

    func stopUpdatingPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    func toggleAudioWidget() {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return
        }
        
        let dataService = DataService.shared
        
        Task {
            do {
                if isPlaying {
                    let success = try await dataService.pausePodcastEpisode(userId: userId)
                    if success {
                        isPlaying = false
                    }
                } else {
                    if let episodeId = widgetPodcast?.uri {
                        let success = try await dataService.playPodcastEpisode(episodeUri: episodeId)
                        if success {
                            isPlaying = true
                        }
                    }
                }
            } catch(let error) {
                print("Error playing/pausing episode: ", error)
            }
        }
    }
    
    func checkIsPlaying() {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return
        }
        
        Task {
            do {
                let dataService = DataService.shared
                let playbackDetails = try await dataService.getPlaybackStatus()
                
                if let playbackDetails = playbackDetails {
                    
                    widgetPodcast = EpisodeModel(
                        episodeId: playbackDetails.id,
                        name: playbackDetails.name,
                        urlString: "",
                        desc: ""
                    )
                    
                    if playbackDetails.playing {
                        self.isPlaying = true
                    } else {
                        self.isPlaying = false
                    }
                }
            } catch {
                print("Error fetching playback status: \(error)")
            }
        }
    }
    
    func getFavoriteEpisodes() {
        Task {
            do {
                let dataService = DataService.shared
                let returnedEpisodes = try await dataService.getSavedEpisodes()
                
                guard let episodes = returnedEpisodes else {
                    print("Unable to unwrap returned episodes.")
                    return
                }
                
                print("Calling fetch images.")
                let episodesWithImages = try await fetchImagesForEpisodes(episodes)
                
                DispatchQueue.main.async {
                    self.favoritedEpisodes = episodesWithImages
                }
            } catch(let error) {
                print("Error getting user's favorite episodes: ", error)
            }
        }
    }
    
    func spotifyAccountLinked() {
        guard let userId = currentUserId else {
            print("Unable to unwrap current user id.")
            return
        }
        
        Task {
            do {
                let dataService = DataService.shared
                let returnedUserModel = try await dataService.getUserModelFromFirestore(userId: userId)
                
                guard let userModel = returnedUserModel else {
                    print("Unable to unwrap user model or spotify linked: ", returnedUserModel as Any)
                    return
                }
                
                if let spotifyLinked = userModel.spotifyLinked, spotifyLinked {
                    return
                } else {
                    DispatchQueue.main.async {
                        self.showLinkSpotifyView = true
                    }
                }
            } catch(let error) {
                print("Error checking if Spotify is linked: ", error)
            }
        }
    }
    
    func handleRightSwipe(for episode: EpisodeModel) {
        guard let newEpisodeId = episode.episodeId,
              !favoritedEpisodes.contains(where: { $0.episodeId == newEpisodeId }) else {
            print("Episode already favorited: \(episode.name ?? "Unknown")")
            return
        }

        print("Right swipe on episode: \(episode.name)")
        self.addPodcastEpisodeToFirestore(episode: episode)
        
        DispatchQueue.main.async {
            self.favoritedEpisodes.append(episode)
        }
        
//        Task {
//            do {
//                let playback = try await DataService.shared.getPlaybackStatus()
//                if let playback = playback {
//                    if playback.playing {
//                        print("Currently playing: \(playback.name)")
//                        print("Progress: \(playback.progress_ms ?? 0) / \(playback.duration_ms ?? 0) ms")
//                    } else {
//                        print("Last played: \(playback.name) at \(playback.played_at ?? "unknown time")")
//                        if let url = episode.uri {
//                            try await DataService.shared.playPodcastEpisode(episodeUri: url)
//                        }
//                    }
//                }
//            } catch {
//                print("Error fetching playback status: \(error)")
//            }
//        }
    }
    
    private func addPodcastEpisodeToFirestore(episode: EpisodeModel) {
        Task {
            do {
                let dataService = DataService.shared
                try await dataService.saveEpisode(episode: episode)
            } catch(let error) {
                print("Error saving episode to Firestore: ", error)
            }
        }
    }
    
    func checkIfSomethingIsPlaying(userId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://your-server.com/get-podcast-status") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["userId": userId]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Failed to encode request body:", error)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error:", error)
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            guard let data = data else {
                print("No data in response")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            do {
                let playbackStatus = try JSONDecoder().decode(PlaybackStatus.self, from: data)
                DispatchQueue.main.async {
                    completion(playbackStatus.playing)
                }
            } catch {
                print("Failed to decode response:", error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }
    
    func generateNewEpisodes(mood: String) {
        showEmojiSelection = false
        isLoading = true
        Task {
            do {
                let dataService = DataService.shared
                let episodes = try await dataService.generatePodcastEpisodes(mood: mood)
                let episodesWithImages = try await fetchImagesForEpisodes(episodes)
                self.episodeStack = episodesWithImages
                self.isLoading = false
            } catch {
                print("Error: \(error)")
                self.isLoading = false
            }
        }
    }
    
    func fetchImagesForEpisodes(_ episodes: [EpisodeModel]) async throws -> [EpisodeModel] {
        var updatedEpisodes: [EpisodeModel] = []
        let dataService = DataService.shared
        
        print("episodes: ", episodes)

        for var episode in episodes {
            if let imageUrl = episode.images?[0].url {
                print("URL: ", imageUrl)
                do {
                    let image = try await dataService.retrieveImageFromUrl(imageUrl: imageUrl)
                    episode.image = image
                    updatedEpisodes.append(episode)
                } catch {
                    print("Failed to fetch image for episode \(episode.name ?? "n/a"): \(error)")
                    episode.image = nil
                }
            } else {
                print("No url")
            }
        }

        return updatedEpisodes
    }
}
