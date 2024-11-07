//
//  ResultPageView.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import AlamofireImage
import SnapKit
import UIKit

final class ResultPageView: UIView {
    private var viewModel: ResultPageViewModel?

    private let title = UILabel()
    private let subtitle = UILabel()

    private let leaveSessionButton = UIButton()
    private let restartButton = UIButton()
    private let backgroundImage = UIImageView(image: .init(named: "welcome_blurred_total"))

    private lazy var moviePoster = UIImageView()

    func configure(with viewModel: ResultPageViewModel) {
        guard self.viewModel == nil else { return }
        self.viewModel = viewModel
        setupResultPage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if viewModel?.result == .good {
            moviePoster.roundCorners(radius: 6.0)
        }
    }
}

private extension ResultPageView {
    func setupResultPage() {
        setupHierarchy()
        setupConstraints()
        setupUI()
    }

    func setupHierarchy() {
        guard let viewModel else { return }

        self.addSubviews([
            backgroundImage,
            title,
            subtitle,
            leaveSessionButton,
            restartButton,
        ])

        if viewModel.result == .good {
            self.addSubviews([
                moviePoster,
            ])

            if let posterURL = viewModel.matchedMovie?.posterURL {
                moviePoster.af.setImage(withURL: posterURL)
                moviePoster.clipsToBounds = true
            }
        }
    }

    func setupConstraints() {
        guard let result = viewModel?.result else { return }

        backgroundImage.snp.makeConstraints { $0.edges.equalToSuperview() }

        title.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height * 0.61)
            make.leading.equalToSuperview().inset(LayoutConfig.horizontalInset)
            make.trailing.equalToSuperview().inset(16)
        }

        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        if result == .good {
            moviePoster.snp.makeConstraints { make in
                make.top.equalTo(self.safeAreaLayoutGuide).inset(10)
                make.horizontalEdges.equalToSuperview().inset(2 * LayoutConfig.horizontalInset)
                make.bottom.equalTo(title.snp.top).offset(-20)
            }
        }

        restartButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
        }

        leaveSessionButton.snp.makeConstraints { make in
            make.top.equalTo(restartButton.snp.bottom).offset(20)
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
            make.bottom.greaterThanOrEqualTo(self.safeAreaLayoutGuide).inset(10)
        }
    }

    func setupUI() {
        setupLabel()
        setupRestartButton()
        setupLeaveSessionButton()
    }

    func setupLabel() {
        guard let viewModel else { return }
        switch viewModel.result {
        case .good:
            title.text = viewModel.matchedMovie?.name
            subtitle.text = "🍿🍿🍿"
        case .bad:
            title.text = "Сожалеем 😢"
            subtitle.text = "Найти фильм не удалось 🫠"
        }

        title.font = .systemFont(ofSize: 43, weight: .black, width: .expanded)
        title.textColor = .white
        title.textAlignment = .left
        title.numberOfLines = 2

        subtitle.numberOfLines = 2
        subtitle.textColor = .white
        subtitle.font = .systemFont(ofSize: 40, weight: .medium, width: .expanded)
    }

    func setupRestartButton() {
        var conf = UIButton.Configuration.filled()

        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 20, weight: .bold, width: .expanded)
            return outgoing
        }

        restartButton.configuration = conf
        restartButton.tintColor = .white
        restartButton.setTitle("Попробовать еще раз", for: .normal)
        restartButton.setTitleColor(.black, for: .normal)

        restartButton.onTap { [weak self] in
            self?.viewModel?.restartSession()
        }
    }

    func setupLeaveSessionButton() {
        var conf = UIButton.Configuration.plain()

        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold, width: .expanded)
            return outgoing
        }

        leaveSessionButton.configuration = conf
        leaveSessionButton.setTitle("Выйти", for: .normal)
        leaveSessionButton.setTitleColor(.white, for: .normal)
        leaveSessionButton.tintColor = .white

        leaveSessionButton.onTap { [weak self] in
            self?.viewModel?.leaveSession()
        }
    }

    // MARK: - Layout config

    enum LayoutConfig {
        static let horizontalInset: CGFloat = 20.0
    }
}
