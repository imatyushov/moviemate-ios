//
//  WaitingPageViewController.swift
//  moviemate-ios
//
//  Created by ilya.matyushov on 07.11.2024.
//

import Combine
import SnapKit
import UIKit

final class WaitingPageViewController: UIViewController {
    enum WaitingType {
        case join
        case genresChoosing
    }

    private let pageView = WaitingPageView()

    private let type: WaitingType

    private var cancellable: AnyCancellable?

    init(type: WaitingType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)

        cancellable = ApiClient.shared.$lobbyInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleStateChanged($0)
            }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(pageView)
        pageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageView.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageView.stopAnimating()
    }

    private func handleStateChanged(_ info: LobbyInfo?) {
        guard let info else {
            Router.shared.handleLobbyDeleted(in: self.navigationController)
            ApiClient.shared.stopPolling()
            return
        }

        if info.appState == .choosingGenresTimeout {
            AlertController.showAlert(vc: self, errorInfo: .init(
                "Время вышло",
                "Кто-то из пользователей не успел выбрать жанры",
                "Бывает"
            ) { [weak self] in
                Router.shared.navigate(in: self?.navigationController, to: .welcomePage, makeRoot: true)
                ApiClient.shared.stopPolling()
            })
        }

        let targetState: AppState
        let targetPage: Page
        switch type {
        case .join:
            targetState = .choosingGenres
            targetPage = .genresChoosingPage
        case .genresChoosing:
            targetState = .choosingMovies
            targetPage = .deckPage
        }

        guard info.appState == targetState else { return }
        Router.shared.navigate(in: self.navigationController, to: targetPage, makeRoot: true)
    }
}
