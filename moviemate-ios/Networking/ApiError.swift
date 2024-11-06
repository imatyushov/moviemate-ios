//
//  ApiClient.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 06.11.2024.
//

import Foundation

struct ErrorInfo {
    let title: String
    let message: String
    let buttonTitle: String
    let action: (() -> Void)?

    init(_ title: String, _ message: String, _ buttonTitle: String, _ action: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }
}

enum ApiError: Error {
    case incorrectId
    case unableToCreateLobby
    case unableToDeleteLobby
    case unableToStartLobby
    case unableToRestartLobby
    case unableToGetGenres
    case unableToConfirmGenres
    case unableToGetMovies
}

extension ApiError {
    var errorInfo: ErrorInfo {
        switch self {
        case .incorrectId: ErrorInfo(
                "Некорректный ID",
                "Введите корректный ID комнаты",
                "Хорошо"
            )
        case .unableToCreateLobby: ErrorInfo(
                "Не удалось создать лобби",
                "Проверьте интернет",
                "Хорошо"
            )
        case .unableToDeleteLobby: ErrorInfo(
                "Не удалось удалить лобби",
                "Проверьте интернет",
                "Хорошо"
            )
        case .unableToStartLobby, .unableToRestartLobby: ErrorInfo(
                "Не удалось начать игру",
                "Проверьте интернет",
                "Хорошо"
            )
        case .unableToGetGenres: ErrorInfo(
                "Не удалось получить жанры",
                "Проверьте интернет",
                "Хорошо"
            )
        case .unableToConfirmGenres: ErrorInfo(
                "Не удалось подтвердить жанры",
                "Проверьте интернет",
                "Хорошо"
            )
        case .unableToGetMovies: ErrorInfo(
                "Не удалось получить фильмы",
            "Проверьте интернет",
            "Хорошо"
        )
        }
    }
}
