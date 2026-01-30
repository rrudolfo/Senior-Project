//
//  EpisodeModel.swift
//  MoodCast
//
//  Created by Jacob Lucas on 5/26/25.
//

import UIKit

struct EpisodeModel: Identifiable, Equatable, Codable {
    let id = UUID()
    let episodeId: String?
    
    let name: String?
    let audioPreviewURL: URL?
    let description: String?
    
    let htmlDescription: String?
    let url: URL?
    let href: URL?
    let uri: String?
    let type: String?
    let durationMs: Int?
    let explicit: Bool?
    let isExternallyHosted: Bool?
    let isPlayable: Bool?
    
    let language: String?
    let languages: [String]?
    let releaseDate: String?
    let releaseDatePrecision: String?
    
    let images: [EpisodeImage]?
    let externalURLs: ExternalURLs?
    let show: Show?
    var image: UIImage?
    
    var swipeDirection: SwipeDirection? = nil

    static func == (lhs: EpisodeModel, rhs: EpisodeModel) -> Bool {
        return lhs.episodeId == rhs.episodeId
    }
    
    enum CodingKeys: String, CodingKey {
        case episodeId = "id"
        case name
        case audioPreviewURL = "audio_preview_url"
        case description
        case htmlDescription = "html_description"
        case externalURLs = "external_urls"
        case url
        case href
        case uri
        case type
        case durationMs = "duration_ms"
        case explicit
        case isExternallyHosted = "is_externally_hosted"
        case isPlayable = "is_playable"
        case language
        case languages
        case releaseDate = "release_date"
        case releaseDatePrecision = "release_date_precision"
        case images
        case show
    }
    
    enum SwipeDirection: String, Codable {
        case left, right
    }

    struct ExternalURLs: Codable {
        let spotify: URL?
    }
    
    struct EpisodeImage: Codable {
        let height: Int?
        let width: Int?
        let url: URL?
    }
    
    struct Show: Codable {
        let id: String?
        let name: String?
        let description: String?
        let htmlDescription: String?
        let publisher: String?
        let type: String?
        let uri: String?
        let href: URL?
        let externalURLs: ExternalURLs?
        let explicit: Bool?
        let languages: [String]?
        let mediaType: String?
        let totalEpisodes: Int?
        let images: [EpisodeImage]?
        let isExternallyHosted: Bool?
        
        enum CodingKeys: String, CodingKey {
            case id, name, description
            case htmlDescription = "html_description"
            case publisher, type, uri, href
            case externalURLs = "external_urls"
            case explicit, languages
            case mediaType = "media_type"
            case totalEpisodes = "total_episodes"
            case images
            case isExternallyHosted = "is_externally_hosted"
        }
    }
}

extension EpisodeModel {
    init(episodeId: String?,
         name: String?,
         urlString: String?,
         desc: String?)
    {
        self.episodeId            = episodeId
        self.name                 = name
        self.audioPreviewURL      = nil
        self.description          = desc
        self.htmlDescription      = nil
        self.externalURLs         = nil
        self.url                  = urlString.flatMap(URL.init(string:))
        self.href                 = nil
        self.uri                  = nil
        self.type                 = nil
        self.durationMs           = nil
        self.explicit             = nil
        self.isExternallyHosted   = nil
        self.isPlayable           = nil
        self.language             = nil
        self.languages            = nil
        self.releaseDate          = nil
        self.releaseDatePrecision = nil
        self.images               = nil
        self.show                 = nil
        self.image                = nil
        self.swipeDirection       = nil
    }
}
