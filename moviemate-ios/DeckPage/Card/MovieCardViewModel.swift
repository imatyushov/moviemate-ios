//
//  MovieCardViewModel.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import UIKit

final class MovieCardViewModel {
    static var onLikeTap: (() -> Void)?
    static var onDislikeTap: (() -> Void)?
    static var onUndoTap: (() -> Void)?
    static var onDescriptionTap: ((String) -> Void)?

    let title: String
    let description: String
    let posterURL: URL?
    let rating: String
    let releaseYear: String
    let duration: String
    let genres: [String]

    let canUndo: Bool

    init(with movie: Movie, canUndo: Bool) {
        self.title = movie.name
        self.description = movie.description
        self.posterURL = movie.posterURL
        self.rating = movie.rating != "0.0" ? movie.rating : movie.kpRating
        self.releaseYear = movie.releaseYear
        self.duration = movie.duration
        self.genres = movie.genres
        self.canUndo = canUndo
    }
}
