//
//  MovieCardDescriptionViewController.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import SnapKit
import UIKit

final class MovieCardDescriptionViewController: UIViewController {
    var movieDescription = ""

    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubviews([
            blurredView,
            titleLabel,
            textView,
        ])

        blurredView.snp.makeConstraints { $0.edges.equalToSuperview() }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(5)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        setupTitle()
        setupText()
    }
}

private extension MovieCardDescriptionViewController {
    func setupTitle() {
        titleLabel.text = "О фильме"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .black, width: .expanded)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = .clear
    }

    func setupText() {
        textView.text = movieDescription
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 17, weight: .semibold, width: .expanded)
        textView.textColor = .white
    }
}
