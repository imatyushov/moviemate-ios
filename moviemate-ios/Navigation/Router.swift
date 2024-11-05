//
//  Router.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import UIKit

@MainActor
final class Router {
    static let shared = Router()
    private init() {}

    func navigate(in nvc: UINavigationController?, to page: Page, makeRoot: Bool = false) {
        guard let nvc else { return }
        if !makeRoot {
            nvc.pushViewController(page.vc(), animated: true)
        } else {
            nvc.setViewControllers([page.vc()], animated: true)
        }
    }

    func handleLobbyDeleted(in nvc: UINavigationController?) {
        guard let nvc else { return }
        nvc.setViewControllers([Page.welcomePage.vc(), Page.joinLobbyPage.vc()], animated: true)
    }

    func navigateBack(in nvc: UINavigationController?) {
        nvc?.popViewController(animated: true)
    }

    func navigate(from vc: UIViewController?, to page: Page) {
        vc?.present(page.vc(), animated: true)
    }
}
