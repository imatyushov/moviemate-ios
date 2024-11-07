//
//  MovieInfoLabel.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import UIKit
import YYText

final class MovieInfoLabel: YYLabel {
    func setup(with viewModel: MovieCardViewModel) {
        let imdbLogo = YYTextAttachment()
        imdbLogo.contentMode = .scaleAspectFill
        imdbLogo.content = UIImage(named: "imdb_logo")
        imdbLogo.contentInsets = .init(top: 0, left: 0, bottom: 5, right: 0)

        let ratingAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hex: 0xEFC944),
            .font: UIFont.systemFont(ofSize: 17, weight: .heavy, width: .expanded),
        ]

        let attrStr = NSMutableAttributedString(string: "         ")
        attrStr.yy_setTextAttachment(imdbLogo, range: NSRange(location: 0, length: 9))

        let ratingStr = NSAttributedString(string: " \(viewModel.rating)", attributes: ratingAttrs)
        attrStr.append(ratingStr)

        let dividerAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .heavy, width: .expanded),
        ]

        let dividerStr = NSAttributedString(string: " • ", attributes: dividerAttrs)
        attrStr.append(dividerStr)

        attrStr.yy_appendString("\(viewModel.releaseYear)")
        attrStr.yy_appendString(" • ")
        attrStr.yy_appendString(viewModel.duration)

        self.textVerticalAlignment = .bottom
        self.attributedText = attrStr
    }
}
