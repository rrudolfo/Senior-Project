//
//  SpotifyProfileModel.swift
//  MoodCast
//
//  Created by Jacob Lucas on 5/12/25.
//

import Foundation

struct SpotifyProfileModel: Codable {
    let country: String?
    let displayName: String?
    let email: String?
    let explicitContent: ExplicitContent?
    let externalURLs: ExternalURLs?
    let followers: Followers?
    let href: String?
    let id: String?
    let images: [SpotifyImage]?
    let product: String?
    let type: String?
    let uri: String?
    
    enum CodingKeys: String, CodingKey {
        case country
        case displayName = "display_name"
        case email
        case explicitContent = "explicit_content"
        case externalURLs = "external_urls"
        case followers
        case href
        case id
        case images
        case product
        case type
        case uri
    }
}

struct ExplicitContent: Codable {
    let filterEnabled: Bool?
    let filterLocked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
    }
}

struct ExternalURLs: Codable {
    let spotify: String?
}

struct Followers: Codable {
    let href: String?
    let total: Int?
}

struct SpotifyImage: Codable {
    let height: Int?
    let url: String?
    let width: Int?
}

