//
//  AlertController.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import UIKit

@MainActor
final class AlertController {
    static func showAlert(
        vc: UIViewController,
        title: String,
        message: String,
        buttonTitle: String,
        action: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in action?() }))
        vc.present(alert, animated: true)
    }

    static func showAlert(vc: UIViewController?, errorInfo: ErrorInfo) {
        guard let vc else { return }
        self.showAlert(
            vc: vc,
            title: errorInfo.title,
            message: errorInfo.message,
            buttonTitle: errorInfo.buttonTitle,
            action: errorInfo.action
        )
    }

    static func showAlert(vc: UIViewController?, error: Error) {
        guard let vc, let apiError = error as? ApiError else { return }
        self.showAlert(vc: vc, errorInfo: apiError.errorInfo)
    }
}
