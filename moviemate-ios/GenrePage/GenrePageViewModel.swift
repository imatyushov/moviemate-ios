//
//  GenrePageViewModel.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import Combine
import Foundation
import UIKit

final class GenrePageViewModel: NSObject {
    weak var vc: UIViewController?

    @Published
    private(set) var allGenres: [String] = []
    @Published
    var selectedPaths: [IndexPath] = []

    override init() {
        super.init()
        loadGenres()
    }

    func loadGenres() {
        Task {
            do {
                allGenres = (try? await ApiClient.shared.getGenres()) ?? []
            }
        }
    }

    func chooseGenreRandomly() {
        guard let random = allGenres.randomElement() else { return }
        confirmSelected([random])
    }

    func confirmUserChoice(_ tableView: UITableView) {
        let genres: [String] = selectedPaths
            .compactMap { (tableView.cellForRow(at: $0) as? GenreCell) }
            .filter { $0.isChosen }
            .map { $0.genre }
        confirmSelected(genres)
    }

    private func confirmSelected(_ genres: [String]) {
        Task {
            do {
                if try await ApiClient.shared.confirmSelected(genres) {
                    await Router.shared.navigate(
                        in: vc?.navigationController,
                        to: .waitingPage(.genresChoosing),
                        makeRoot: true
                    )
                }
            } catch {
                await AlertController.showAlert(vc: vc, error: error)
            }
        }
    }
}
