//
//  LobbyPageView.swift
//  moviemate-ios
//
//  Created by ilya.matyushov on 06.11.2024.
//

import Combine
import CombineCocoa
import HandlersKit
import SnapKit
import UIKit

final class LobbyPageView: UIView {
    private var viewModel: LobbyPageViewModel?

    private let headerLabel = UILabel()
    private lazy var roomIDLabel = UILabel()
    private lazy var textField = UITextField()
    private let continueButton = UIButton()
    private lazy var cancelRoomCreationButton = UIButton()
    private let backgroundImage = UIImageView(image: .init(named: "welcome_blurred_total"))

    @Published
    private var probablyRoomID = ""
    private var cancellables: Set<AnyCancellable> = []

    func configure(with viewModel: LobbyPageViewModel) {
        guard self.viewModel == nil else { return }
        self.viewModel = viewModel
        setupLobby()
    }
}

private extension LobbyPageView {
    // MARK: - Setup UI

    func setupLobby() {
        setupHierarchy()
        setupConstraints()
        setupUI()
    }

    func setupHierarchy() {
        guard let action = viewModel?.action else { return }

        self.addSubviews(
            backgroundImage,
            headerLabel,
            continueButton
        )

        if action == .create {
            self.addSubviews(
                roomIDLabel,
                cancelRoomCreationButton
            )
        } else {
            self.addSubview(textField)
            textField.delegate = self
        }
    }

    func setupConstraints() {
        guard let action = viewModel?.action else { return }
        registerAutomaticKeyboardConstraints()

        backgroundImage.snp.makeConstraints { $0.edges.equalToSuperview() }

        headerLabel.snp.prepareConstraints { make in
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height * 0.32).keyboard(true, in: self)
        }

        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height * 0.61).keyboard(false, in: self)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
        }

        if action == .create {
            roomIDLabel.snp.makeConstraints { make in
                make.top.equalTo(headerLabel.snp.bottom).offset(10)
                make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
            }
            cancelRoomCreationButton.snp.makeConstraints { make in
                make.top.equalTo(continueButton.snp.bottom).offset(10)
                make.height.equalTo(50)
                make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
                make.bottom.equalTo(self.safeAreaLayoutGuide).inset(20)
            }
        } else {
            textField.snp.makeConstraints { make in
                make.top.equalTo(headerLabel.snp.bottom).offset(10)
                make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)
            }
        }

        continueButton.snp.prepareConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(40).keyboard(true, in: self)
        }

        continueButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(LayoutConfig.horizontalInset)

            if action == .join {
                make.bottom.greaterThanOrEqualTo(self.safeAreaLayoutGuide).inset(20).keyboard(false, in: self)
            }
        }
    }

    func setupUI() {
        setupHeaderLabel()
        setupRoomIDLabel()
        setupTextField()
        setupContinueButton()
        setupCancelRoomCreationButton()
    }

    // MARK: - Setup separate views

    func setupHeaderLabel() {
        headerLabel.text = viewModel?.headerText
        headerLabel.textColor = .white

        headerLabel.numberOfLines = 2
        headerLabel.font = .systemFont(ofSize: 42, weight: .black, width: .expanded)
    }

    func setupRoomIDLabel() {
        guard viewModel?.action == .create else { return }

        roomIDLabel.font = .systemFont(ofSize: 65, weight: .black, width: .expanded)
        roomIDLabel.textColor = .white
        roomIDLabel.text = "YOURID"

        viewModel?.$roomID
            .receive(on: DispatchQueue.main)
            .filter { !($0?.isEmpty ?? true) }
            .sink { [weak self] in
                guard let label = self?.roomIDLabel else { return }
                label.text = $0
            }.store(in: &cancellables)
    }

    func setupTextField() {
        guard viewModel?.action == .join else { return }

        textField.placeholder = viewModel?.textFieldPlaceholder

        textField.font = .systemFont(ofSize: 40, weight: .medium, width: .expanded)
        textField.textColor = .white
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .join

        textField.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] str in
                self?.probablyRoomID = str ?? ""
            }.store(in: &cancellables)

        textField.returnPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.viewModel?.joinLobby(lobbyId: self.probablyRoomID)
            }.store(in: &cancellables)
    }

    func setupContinueButton() {
        var conf = UIButton.Configuration.filled()
        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 20, weight: .bold, width: .expanded)
            return outgoing
        }

        let updateHandler: UIButton.ConfigurationUpdateHandler = { button in
            switch button.state {
            case .disabled:
                button.configuration?.baseBackgroundColor = .gray
            default:
                button.configuration?.baseBackgroundColor = .white
            }
        }

        continueButton.configurationUpdateHandler = updateHandler

        continueButton.configuration = conf
        continueButton.setTitle(viewModel?.continueButtonTitle, for: .normal)
        continueButton.setTitleColor(.black, for: .normal)
        continueButton.setTitleColor(.white, for: .disabled)

        if viewModel?.action == .join {
            $probablyRoomID
                .receive(on: DispatchQueue.main)
                .sink { [weak self] str in
                    guard let self, let action = self.viewModel?.action else { return }
                    self.continueButton.isEnabled = action == .join && !str.isEmpty
                }.store(in: &cancellables)
        } else {
            ApiClient.shared.$lobbyInfo
                .receive(on: DispatchQueue.main)
                .sink { [weak self] info in
                    self?.continueButton.isEnabled = info?.appState == .readyToStart
                }
                .store(in: &cancellables)
        }

        continueButton.onTap { [weak self] in
            guard let vm = self?.viewModel else { return }
            if vm.action == .join {
                vm.joinLobby(lobbyId: self?.probablyRoomID ?? "")
            } else {
                vm.startLobby()
            }
        }
    }

    func setupCancelRoomCreationButton() {
        guard viewModel?.action == .create else { return }

        var conf = UIButton.Configuration.plain()
        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .semibold, width: .expanded)
            return outgoing
        }
        cancelRoomCreationButton.configuration = conf

        cancelRoomCreationButton.tintColor = .white
        cancelRoomCreationButton.setTitle("Распустить лобби", for: .normal)
        cancelRoomCreationButton.setTitleColor(.white, for: .normal)

        cancelRoomCreationButton.onTap { [weak self] in
            self?.viewModel?.cancelRoomCreation()
        }
    }

    // MARK: - Layout config

    enum LayoutConfig {
        static let horizontalInset: CGFloat = 20.0
    }
}

extension LobbyPageView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let isLengthOK = updatedText.count <= 6

        let allowedSet = CharacterSet.letters.union(.decimalDigits)
        var charsAllowed = true

        updatedText.forEach { char in
            char.unicodeScalars.forEach { charsAllowed = allowedSet.contains($0) }
        }

        return isLengthOK && charsAllowed
    }
}
