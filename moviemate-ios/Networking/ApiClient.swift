//
//  ApiClient.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 06.11.2024.
//

import Alamofire
import Combine
import Foundation

final class ApiClient {
    static let shared = ApiClient()

    @Published
    private(set) var lobbyInfo: LobbyInfo?

    private static let pollingManager = PollingManager()

    private let mainURL = "http://90.156.216.250:8081/v1"
    private let headers = HTTPHeaders([.init(
        name: "X-Device-Token",
        value: UIDevice.current.identifierForVendor?.uuidString ?? ""
    )])

    private var lobbyId: String { lobbyInfo?.lobbyId ?? "" }

    private init() {}

    // MARK: - Polling manager

    func startPolling() {
        ApiClient.pollingManager.startPolling()
    }

    func stopPolling() {
        ApiClient.pollingManager.stopPolling()
    }

    func updateLobbyInfo() async {
        let response = await AF.request(mainURL + "/lobbies/\(lobbyId)", method: .get, headers: headers)
            .validate()
            .serializingDecodable(LobbyInfo.self)
            .response

        switch response.result {
        case let .success(lobbyInfo):
            self.lobbyInfo = lobbyInfo
        case .failure:
            self.lobbyInfo = nil
        }
    }

    // MARK: - Lobby

    func createLobby() async throws -> String {
        let response = await AF.request(mainURL + "/lobbies", method: .post, headers: headers)
            .validate()
            .serializingDecodable(LobbyInfo.self)
            .response

        switch response.result {
        case let .success(lobbyInfo):
            self.lobbyInfo = lobbyInfo
            return lobbyInfo.code
        case .failure:
            throw ApiError.unableToCreateLobby
        }
    }

    func joinLobby(lobbyId: String) async throws {
        let response = await AF.request(
            mainURL + "/lobbies:join",
            method: .post,
            parameters: ["token": lobbyId],
            headers: headers
        )
        .validate()
        .serializingDecodable(LobbyInfo.self)
        .response

        switch response.result {
        case let .success(lobbyInfo):
            self.lobbyInfo = lobbyInfo
        case .failure:
            throw ApiError.incorrectId
        }
    }

    func deleteLobby() async throws {
        let response = await AF.request(mainURL + "/lobbies/\(lobbyId)", method: .delete, headers: headers)
            .validate()
            .serializingDecodable(EmptyEntity.self, emptyResponseCodes: [200])
            .response

        switch response.result {
        case .success:
            self.lobbyInfo = nil
        case .failure:
            throw ApiError.unableToDeleteLobby
        }
    }

    func startLobby() async throws -> Bool {
        let response = await AF.request(mainURL + "/lobbies/\(lobbyId)/start", method: .post, headers: headers)
            .validate()
            .serializingDecodable(EmptyEntity.self, emptyResponseCodes: [200])
            .response

        switch response.result {
        case .success:
            return true
        case .failure:
            throw ApiError.unableToStartLobby
        }
    }

    func restartLobby() async throws {
        let response = await AF.request(mainURL + "/lobbies/\(lobbyId)/restart", method: .post, headers: headers)
            .validate()
            .serializingDecodable(LobbyInfo.self)
            .response

        if case .failure = response.result {
            throw ApiError.unableToRestartLobby
        }
    }

    // MARK: - Genres

    func getGenres() async throws -> [String] {
        let response = await AF.request(mainURL + "/genres", method: .get, headers: headers)
            .validate()
            .serializingDecodable([String].self)
            .response

        switch response.result {
        case let .success(result):
            return result
        case .failure:
            throw ApiError.unableToGetGenres
        }
    }

    func confirmSelected(_ genres: [String]) async throws -> Bool {
        let encoder = URLEncodedFormParameterEncoder(encoder: .init(arrayEncoding: .noBrackets))
        let response = await AF.request(
            mainURL + "/lobbies/\(lobbyId)/sessions",
            method: .post,
            parameters: ["ids": genres],
            encoder: encoder,
            headers: headers
        )
        .validate()
        .serializingDecodable(EmptyEntity.self, emptyResponseCodes: [200])
        .response

        switch response.result {
        case .success:
            return true
        case .failure:
            throw ApiError.unableToConfirmGenres
        }
    }

    // MARK: - Deck

    func getMovies() async throws -> [Movie] {
        let response = await AF.request(mainURL + "/lobbies/\(lobbyId)/films", method: .get, headers: headers)
            .validate()
            .serializingDecodable([Movie].self)
            .response

        switch response.result {
        case let .success(result):
            return result
        case .failure:
            throw ApiError.unableToGetMovies
        }
    }

    func like(movie: Movie) async {
        _ = await AF.request(mainURL + "/lobbies/\(lobbyId)/films/\(movie.id)", method: .post, headers: headers)
            .validate()
            .serializingDecodable(EmptyEntity.self, emptyResponseCodes: [200])
            .response
    }

    func undoLike(movie: Movie) async {
        _ = await AF.request(mainURL + "/lobbies/\(lobbyId)/films/\(movie.id)", method: .delete, headers: headers)
            .validate()
            .serializingDecodable(EmptyEntity.self, emptyResponseCodes: [200])
            .response
    }

    func notifyEmpty() async {
        _ = await AF.request(
            mainURL + "/lobbies/\(lobbyId)/userFinishChoosing",
            method: .post,
            headers: headers
        )
        .validate()
        .serializingDecodable(EmptyEntity.self, emptyResponseCodes: [200])
        .response
    }
}

private extension ApiClient {
    struct EmptyEntity: Decodable, EmptyResponse {
        static func emptyValue() -> EmptyEntity { .init() }
    }
}
