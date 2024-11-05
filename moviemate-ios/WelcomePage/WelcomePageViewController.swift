//
//  WelcomePageViewController.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import SnapKit
import UIKit

final class WelcomePageViewController: UIViewController {
    private let welcomeView = WelcomePageView()
    private let welcomeVM = WelcomePageViewModel()

    init() {
        super.init(nibName: nil, bundle: nil)
        welcomeVM.vc = self
        welcomeView.configure(with: welcomeVM)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = "Назад"

        view.addSubview(welcomeView)
        welcomeView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
