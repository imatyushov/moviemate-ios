//
//  GenreCell.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import SnapKit
import UIKit

final class GenreCell: UITableViewCell {
    var isChosen = false {
        didSet {
            self.accessoryType = isChosen ? .checkmark : .none
        }
    }

    private(set) var genre = ""

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.tintColor = .white
        self.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        genre = ""
        self.contentConfiguration = nil
        self.isChosen = false
    }

    func configure(with genre: String) {
        self.genre = genre
        var content = self.defaultContentConfiguration()
        content.text = genre
        content.textProperties.color = .white
        content.textProperties.font = UIFont.systemFont(ofSize: 20, weight: .medium, width: .expanded)

        self.contentConfiguration = content
    }
}
