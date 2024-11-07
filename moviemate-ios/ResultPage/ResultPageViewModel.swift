//
//  ResultPageViewModel.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import Foundation
import UIKit

final class ResultPageViewModel {
    enum Result {
        case good
        case bad
    }

    weak var vc: UIViewController?

    let result: Result
    let matchedMovie: Movie?

    convenience init(result: Result) {
        self.init(result: result, matchedMovie: ApiClient.shared.lobbyInfo?.matchedMovie)
    }

    init(result: Result, matchedMovie: Movie?) {
        self.result = result
        self.matchedMovie = matchedMovie
    }

    func restartSession() {
        Task {
            try await ApiClient.shared.restartLobby()
        }
    }

    func leaveSession() {
        Task {
            ApiClient.shared.stopPolling()
            await Router.shared.navigate(in: vc?.navigationController, to: .welcomePage, makeRoot: true)
        }
    }
}
