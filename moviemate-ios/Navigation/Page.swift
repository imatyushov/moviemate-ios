//
//  Page.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 05.11.2024.
//

import UIKit

enum Page {
    case welcomePage
}

extension Page {
    func vc() -> UIViewController {
        switch self {
        case .welcomePage: WelcomePageViewController()
        }
    }
}
