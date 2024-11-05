//
//  WelcomePageView.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import HandlersKit
import SnapKit
import UIKit
import YYText

final class WelcomePageView: UIView {
    private var viewModel: WelcomePageViewModel?

    private let createLobbyButton = UIButton()
    private let joinLobbyButton = UIButton()
    private let backgroundImage = UIImageView(image: .init(named: "welcome"))
    private let title = YYLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: WelcomePageViewModel) {
        guard self.viewModel == nil else { return }
        self.viewModel = viewModel
    }
}

private extension WelcomePageView {
    // MARK: - Setup UI

    func setupUI() {
        self.addSubviews(
            backgroundImage,
            title,
            createLobbyButton,
            joinLobbyButton
        )

        setupConstraints()

        setupTitle()
        setupCreateLobbyButton()
        setupJoinLobbyButton()
    }

    func setupConstraints() {
        backgroundImage.snp.makeConstraints { $0.edges.equalToSuperview() }

        title.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height * 0.61)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
        }

        createLobbyButton.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
        }

        joinLobbyButton.snp.makeConstraints { make in
            make.top.equalTo(createLobbyButton.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
            make.height.equalTo(50)
            make.bottom.greaterThanOrEqualTo(self.safeAreaLayoutGuide).inset(10)
        }
    }

    func setupTitle() {
        title.text = "Добро\nпожаловать\nв MovieMate"
        title.font = .systemFont(ofSize: 43, weight: .black, width: .expanded)
        title.textColor = .white
        title.numberOfLines = 3
        title.textAlignment = .left
        title.textVerticalAlignment = .top
    }

    func setupCreateLobbyButton() {
        var conf = UIButton.Configuration.filled()

        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 20, weight: .bold, width: .expanded)
            return outgoing
        }

        createLobbyButton.configuration = conf

        createLobbyButton.tintColor = .white
        createLobbyButton.setTitle("Создать лобби", for: .normal)
        createLobbyButton.setTitleColor(.black, for: .normal)

        createLobbyButton.onTap { [weak self] in
            self?.viewModel?.moveToCreateLobbyPage()
        }
    }

    func setupJoinLobbyButton() {
        var conf = UIButton.Configuration.plain()

        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold, width: .expanded)
            return outgoing
        }

        joinLobbyButton.configuration = conf

        joinLobbyButton.setTitle("Присоединиться к лобби", for: .normal)
        joinLobbyButton.setTitleColor(.white, for: .normal)
        joinLobbyButton.tintColor = .white

        joinLobbyButton.onTap { [weak self] in
            self?.viewModel?.moveToJoinLobbyPage()
        }
    }

    // MARK: - Layout config

    enum LayoutConfig {
        static let horizontalInset: CGFloat = 20.0
    }
}
