//
//  LobbyPageView.swift
//  moviemate-ios
//
//  Created by ilya.matyushov on 06.11.2024.
//

import Combine
import Foundation
import UIKit

final class LobbyPageViewModel {
    enum LobbyAction {
        case create
        case join
    }

    weak var vc: UIViewController?

    let action: LobbyAction
    let headerText: String
    let continueButtonTitle: String

    @Published
    private(set) var roomID: String?
    private(set) var textFieldPlaceholder: String?

    private var cancellable: AnyCancellable?

    init(action: LobbyAction) {
        self.action = action

        switch action {
        case .create:
            headerText = "Ваш Lobby ID"
            continueButtonTitle = "Начать игру!"
        case .join:
            headerText = "Введите Lobby ID"
            continueButtonTitle = "Присоединиться"
            textFieldPlaceholder = "Ваш Lobby ID"
        }

        createLobbyIfNeeded()
        cancellable = ApiClient.shared.$lobbyInfo
            .receive(on: DispatchQueue.main)
            .filter { $0?.appState == .joinTimeout }
            .sink { [weak self] _ in
                self?.onTimeout()
            }
    }

    func createLobbyIfNeeded() {
        guard action == .create else { return }
        Task {
            do {
                roomID = try await ApiClient.shared.createLobby().uppercased()
                ApiClient.shared.startPolling()
            } catch {
                await AlertController.showAlert(vc: vc, error: error)
            }
        }
    }

    func joinLobby(lobbyId: String) {
        guard action == .join else { return }
        Task {
            do {
                try await ApiClient.shared.joinLobby(lobbyId: lobbyId)
                ApiClient.shared.startPolling()
                await Router.shared.navigate(in: vc?.navigationController, to: .waitingPage(.join), makeRoot: true)
            } catch {
                await AlertController.showAlert(vc: vc, error: error)
            }
        }
    }

    @MainActor func cancelRoomCreation() {
        guard action == .create else { return }
        Task {
            try? await ApiClient.shared.deleteLobby()
        }
        ApiClient.shared.stopPolling()
        Router.shared.navigateBack(in: vc?.navigationController)
    }

    func startLobby() {
        guard action == .create else { return }
        Task {
            do {
                if try await ApiClient.shared.startLobby() {
                    await Router.shared.navigate(in: vc?.navigationController, to: .genresChoosingPage, makeRoot: true)
                }
            } catch {
                await AlertController.showAlert(vc: vc, error: error)
            }
        }
    }

    func onTimeout() {
        Task {
            await Router.shared.navigateBack(in: vc?.navigationController)
            await AlertController.showAlert(vc: vc, errorInfo: .init("Время вышло",
                                                                     "Вы не успели присоединиться к комнате",
                                                                     "Хорошо",
                                                                     nil))
        }
    }
}
