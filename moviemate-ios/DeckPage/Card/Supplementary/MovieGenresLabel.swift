//
//  MovieGenresLabel.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import UIKit

final class MovieGenresLabel: UILabel {
    func setup(with viewModel: MovieCardViewModel) {
        let attrStr = NSMutableAttributedString()

        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .medium, width: .expanded),
        ]

        let divider = NSAttributedString(string: " • ", attributes: attrs)

        for genre in viewModel.genres {
            attrStr.append(NSAttributedString(string: genre, attributes: attrs))
            attrStr.append(divider)
        }

        attrStr.deleteCharacters(in: NSRange(location: attrStr.length - 3, length: 3))

        self.attributedText = attrStr
    }
}
