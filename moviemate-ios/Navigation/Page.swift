//
//  Page.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import UIKit

enum Page {
    case welcomePage
    case createLobbyPage
    case joinLobbyPage
    case waitingPage(WaitingPageViewController.WaitingType)
    case deckPage
    case resultPage(ResultPageViewModel.Result)
}

extension Page {
    func vc() -> UIViewController {
        switch self {
        case .welcomePage: WelcomePageViewController()

        case .createLobbyPage: LobbyPageViewController(with: .init(action: .create))

        case .joinLobbyPage: LobbyPageViewController(with: .init(action: .join))

        case let .waitingPage(type): WaitingPageViewController(type: type)

        case .deckPage: DeckPageViewController()

        case let .resultPage(result): ResultPageViewController(with: .init(result: result))
        }
    }
}
