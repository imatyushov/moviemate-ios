//
//  GenrePageViewController.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import Combine
import SnapKit
import UIKit

final class GenrePageViewController: UIViewController {
    private let genreView: GenrePageView
    private let viewModel: GenrePageViewModel

    private var cancellable: AnyCancellable?

    init() {
        viewModel = GenrePageViewModel()
        genreView = GenrePageView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)

        viewModel.vc = self
        genreView.tableView.register(cellWithClass: GenreCell.self)
        genreView.tableView.delegate = self
        genreView.tableView.dataSource = self

        cancellable = ApiClient.shared.$lobbyInfo
            .receive(on: DispatchQueue.main)
            .filter { $0?.appState == .choosingMoviesTimeout }
            .sink { [weak self] _ in
                self?.onTimeout()
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(genreView)
        genreView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        genreView.spinner.startAnimating()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func onTimeout() {
        AlertController.showAlert(vc: self, errorInfo: .init(
            "Время вышло",
            "Вы не успели выбрать жанры",
            "Бывает"
        ) { [weak self] in
            Router.shared.navigate(in: self?.navigationController, to: .welcomePage, makeRoot: true)
        })
    }
}

extension GenrePageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? GenreCell else { return }

        if !cell.isChosen {
            viewModel.selectedPaths.append(indexPath)
        } else {
            viewModel.selectedPaths.removeAll { $0 == indexPath }
        }

        cell.isChosen.toggle()
    }
}

extension GenrePageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.allGenres.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let genre = viewModel.allGenres[safe: indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withClass: GenreCell.self, for: indexPath)
        cell.configure(with: genre)
        return cell
    }
}
