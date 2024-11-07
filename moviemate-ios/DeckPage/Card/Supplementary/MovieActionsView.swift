//
//  MovieActionsView.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import HandlersKit
import SnapKit
import UIKit

final class MovieActionsView: UIView {
    var onLikeTap: (() -> Void)?
    var onDislikeTap: (() -> Void)?

    private let dislikeButton = UIButton(configuration: .filled())
    private let likeButton = UIButton(configuration: .filled())

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MovieActionsView {
    // MARK: - Setup UI

    func setupUI() {
        self.addSubviews([
            dislikeButton,
            likeButton,
        ])
        setupConstraints()

        setupLikeButton()
        setupDislikeButton()
    }

    func setupConstraints() {
        dislikeButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
            make.size.equalTo(LayoutConfig.buttonSize)
        }

        likeButton.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(dislikeButton.snp.trailing)
            make.trailing.verticalEdges.equalToSuperview()
            make.size.equalTo(LayoutConfig.buttonSize)
        }
    }

    func setupDislikeButton() {
        var conf = UIButton.Configuration.filled()

        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .bold, width: .expanded)
            return outgoing
        }

        dislikeButton.configuration = conf

        dislikeButton.tintColor = UIColor(hex: 0xC71927)
        dislikeButton.setTitle("Не нравится", for: .normal)
        dislikeButton.setTitleColor(.white, for: .normal)

        dislikeButton.onTap { [weak self] in self?.onDislikeTap?() }
    }

    func setupLikeButton() {
        var conf = UIButton.Configuration.filled()

        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .bold, width: .expanded)
            return outgoing
        }

        likeButton.configuration = conf

        likeButton.tintColor = UIColor(hex: 0x00C726)
        likeButton.setTitle("Нравится", for: .normal)
        likeButton.setTitleColor(.white, for: .normal)

        likeButton.onTap { [weak self] in self?.onLikeTap?() }
    }

    enum LayoutConfig {
        static let buttonSize = CGSize(width: 160.0, height: 50.0)
    }
}
