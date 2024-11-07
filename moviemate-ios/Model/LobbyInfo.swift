//
//  AppDelegate.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import Foundation

struct LobbyInfo {
    let lobbyId: String
    let code: String
    let appState: AppState
    let genresChosen: [String]
    let usersJoined: [String]
    let isAvailableToStart: Bool
    let matchedMovie: Movie?
}

extension LobbyInfo: Decodable {
    enum CodingKeys: String, CodingKey {
        case lobbyId
        case code
        case appState = "status"
        case genresChosen = "chosenGenres"
        case usersJoined = "joinedPersons"
        case isAvailableToStart
        case matchedMovie = "matchedFilm"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lobbyId = try container.decode(String.self, forKey: .lobbyId)
        code = try container.decode(String.self, forKey: .code)
        appState = try container.decode(AppState.self, forKey: .appState)
        genresChosen = try container.decodeIfPresent([String].self, forKey: .genresChosen) ?? []
        usersJoined = try container.decodeIfPresent([String].self, forKey: .usersJoined) ?? []
        isAvailableToStart = try container.decode(Bool.self, forKey: .isAvailableToStart)
        matchedMovie = try container.decodeIfPresent(Movie.self, forKey: .matchedMovie)
    }
}
