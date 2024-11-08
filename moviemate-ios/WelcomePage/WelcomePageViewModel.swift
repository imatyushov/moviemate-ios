//
//  WelcomePageViewModel.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import UIKit

@MainActor
final class WelcomePageViewModel {
    weak var vc: UIViewController?

    func moveToCreateLobbyPage() {
        Router.shared.navigate(in: vc?.navigationController, to: .createLobbyPage)
    }

    func moveToJoinLobbyPage() {
        Router.shared.navigate(in: vc?.navigationController, to: .joinLobbyPage)
    }
}
