import Foundation

class PodcastViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    
    let episode: EpisodeModel
    
    private var playbackTimer: Timer?
    private let dataService = DataService.shared
    
    init(episode: EpisodeModel) {
        self.episode = episode
        self.checkIfPlaying()
        startPlaybackTimer()
    }
    
    func startPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                guard let self = self else { return }
                do {
                    if let status = try await self.dataService.getPlaybackStatus() {
                        DispatchQueue.main.async {
                            self.isPlaying = status.playing
                            self.currentPlaybackTime = TimeInterval(status.progress_ms ?? 0) / 1000
                            self.totalDuration = TimeInterval(status.duration_ms ?? 0) / 1000
                        }
                    }
                } catch {
                    print("Failed to update playback status: \(error)")
                }
            }
        }
    }
    
    func checkIfPlaying() {
        Task {
            do {
                if let status = try await dataService.getPlaybackStatus() {
                    DispatchQueue.main.async {
                        self.isPlaying = status.playing
                        self.currentPlaybackTime = TimeInterval(status.progress_ms ?? 0) / 1000
                        self.totalDuration = TimeInterval(status.duration_ms ?? 0) / 1000
                    }
                }
            } catch {
                print("Error checking playback status: \(error)")
            }
        }
    }
    
    func playOrPauseEpisode() {
        Task {
            do {
                toggleHaptic()
                let isPlaying = try await dataService.playPodcastEpisode(episodeUri: episode.uri ?? "")
                DispatchQueue.main.async {
                    self.isPlaying = isPlaying
                }
            } catch {
                print("Error playing episode: ", error)
            }
        }
    }
    
    func favoriteEpisode() {
        Task {
            do {
                toggleHaptic()
                try await dataService.toggleFavoriteEpisode(userId: "", episodeId: "")
            } catch {
                print("Error favoriting episode: ", error)
            }
        }
    }
    
    func seekForwardEpisode() {
        Task {
            do {
                toggleHaptic()
                try await dataService.seekPodcastEpisode(offsetMs: 30000)
            } catch {
                print("Error seeking episode forward: ", error)
            }
        }
    }
    
    func seekBackwardsEpisode() {
        Task {
            do {
                toggleHaptic()
                try await dataService.seekPodcastEpisode(offsetMs: -30000)
            } catch {
                print("Error seeking episode backward: ", error)
            }
        }
    }
    
    private func toggleHaptic() {
        let hapticsManager = HapticsFeedbackManager.shared
        hapticsManager.triggerVibration()
    }
    
    deinit {
        playbackTimer?.invalidate()
    }
}
