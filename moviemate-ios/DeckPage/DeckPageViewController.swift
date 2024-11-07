//
//  DeckPageViewController.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import Combine
import Shuffle_iOS
import SnapKit
import UIKit

final class DeckPageViewController: UIViewController {
    private let deckView = SwipeCardStack()
    private let dataSource = DeckPageDataSource()
    private let emptyDeckView = WaitingPageView()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        super.init(nibName: nil, bundle: nil)
        dataSource.stack = deckView
        dataSource.vc = self
        deckView.dataSource = dataSource
        deckView.delegate = self
        navigationController?.isNavigationBarHidden = true

        dataSource.$movies
            .receive(on: DispatchQueue.main)
            .filter { !$0.isEmpty }
            .sink { [weak self] _ in
                self?.deckView.reloadData()
            }.store(in: &cancellables)

        ApiClient.shared.$lobbyInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.handleStateChanged($0)
            }.store(in: &cancellables)
    }

    private func handleStateChanged(_ info: LobbyInfo?) {
        guard let info else { return }

        switch info.appState {
        case .finished:
            Router.shared.navigate(in: self.navigationController,
                                   to: .resultPage(info.matchedMovie != nil ? .good : .bad),
                                   makeRoot: true)
        case .choosingMoviesMatchError:
            Router.shared.navigate(in: self.navigationController,
                                   to: .resultPage(.bad),
                                   makeRoot: true)
        case .choosingMoviesTimeout:
            AlertController.showAlert(vc: self, errorInfo: .init("Время вышло",
                                                                 "Кто-то из пользователей не успел выбрать фильмы",
                                                                 "Бывает") { [weak self] in
                Router.shared.navigate(in: self?.navigationController, to: .welcomePage, makeRoot: true)
                ApiClient.shared.stopPolling()
            })
        default:
            break
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews([
            emptyDeckView,
            deckView
        ])

        deckView.cardStackInsets = .zero
        emptyDeckView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyDeckView.useSolidBackground = true
        deckView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

extension DeckPageViewController: SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        guard let movie = dataSource.movies[safe: index], direction == .right else { return }
        Task {
            await ApiClient.shared.like(movie: movie)
        }
    }

    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        guard let movie = dataSource.movies[safe: index], direction == .right else { return }
        Task {
            await ApiClient.shared.undoLike(movie: movie)
        }
    }

    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        emptyDeckView.startAnimating()
        Task {
            await ApiClient.shared.notifyEmpty()
        }
    }
}
