//
//  ResultPageViewController.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import Combine
import SnapKit
import UIKit

final class ResultPageViewController: UIViewController {
    private let resultPageView = ResultPageView()
    private let viewModel: ResultPageViewModel

    private var cancellable: AnyCancellable?

    init(with viewModel: ResultPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.vc = self
        resultPageView.configure(with: viewModel)

        cancellable = ApiClient.shared.$lobbyInfo
            .receive(on: DispatchQueue.main)
            .filter { $0?.appState == .choosingGenres }
            .sink { [weak self] _ in
                Router.shared.navigate(in: self?.navigationController, to: .genresChoosingPage, makeRoot: true)
            }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(resultPageView)
        resultPageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
