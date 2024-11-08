//
//  GenrePageView.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import Combine
import HandlersKit
import UIKit

final class GenrePageView: UIView {
    let tableView = UITableView()
    private let titleLabel = UILabel()
    private let randomGenreButton = UIButton()
    private let confirmButton = UIButton()
    private let backgroundImage = UIImageView(image: .init(named: "welcome_blurred_total"))
    let spinner = UIActivityIndicatorView(style: .large)

    private var cancellables: Set<AnyCancellable> = []

    private let viewModel: GenrePageViewModel

    init(viewModel: GenrePageViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GenrePageView {
    func setupUI() {
        self.addSubviews([
            backgroundImage,
            titleLabel,
            tableView,
            randomGenreButton,
            confirmButton,
        ])
        tableView.addSubview(spinner)

        self.backgroundColor = .blue
        spinner.hidesWhenStopped = true
        spinner.color = .white

        setupConstraints()

        setupTitle()
        setupTableView()
        setupRandomGenreButton()
        setupConfirmButton()
    }

    func setupConstraints() {
        backgroundImage.snp.makeConstraints { $0.edges.equalToSuperview() }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(5)
            make.bottom.equalTo(randomGenreButton.snp.top).offset(-20)
        }

        spinner.snp.makeConstraints { $0.center.equalToSuperview() }

        randomGenreButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(randomGenreButton.snp.bottom).offset(20)
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
            make.bottom.greaterThanOrEqualTo(self.safeAreaLayoutGuide).inset(10)
        }
    }

    func setupTitle() {
        titleLabel.text = "Выберите жанр(ы)"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .black, width: .expanded)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
    }

    func setupConfirmButton() {
        var conf = UIButton.Configuration.filled()

        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 20, weight: .bold, width: .expanded)
            return outgoing
        }

        confirmButton.configuration = conf

        confirmButton.tintColor = .white
        confirmButton.setTitle("Подтвердить", for: .normal)
        confirmButton.setTitleColor(.black, for: .normal)

        viewModel.$selectedPaths
            .receive(on: DispatchQueue.main)
            .sink { [weak self] arr in
                self?.confirmButton.isEnabled = !arr.isEmpty
            }.store(in: &cancellables)

        confirmButton.onTap { [weak self] in
            guard let self else { return }
            self.viewModel.confirmUserChoice(self.tableView)
        }
    }

    func setupRandomGenreButton() {
        var conf = UIButton.Configuration.filled()

        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 20, weight: .bold, width: .expanded)
            return outgoing
        }

        randomGenreButton.configuration = conf

        randomGenreButton.tintColor = .white
        randomGenreButton.setTitle("Случайный жанр", for: .normal)
        randomGenreButton.setTitleColor(.black, for: .normal)

        randomGenreButton.onTap { [weak self] in
            self?.viewModel.chooseGenreRandomly()
        }
    }

    func setupTableView() {
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        tableView.backgroundColor = .clear

        viewModel.$allGenres
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            }.store(in: &cancellables)
    }

    // MARK: - Layout config

    enum LayoutConfig {
        static let horizontalInset: CGFloat = 20.0
    }
}
