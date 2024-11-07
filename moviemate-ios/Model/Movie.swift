//
//  Movie.swift
//  moviemate-ios
//
//  Created by denis.beloshitsky on 07.11.2024.
//

import Foundation

struct Movie {
    let id: String
    let name: String
    let description: String
    let posterURL: URL?
    let releaseYear: String
    let duration: String
    let genres: [String]
    let rating: String
    let kpRating: String
}

extension Movie: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "filmId"
        case name
        case description
        case posterURL = "imageUrl"
        case releaseYear
        case duration
        case genres
        case rating = "rating_imdb"
        case kpRating = "rating_kp"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        posterURL = try URL(string: container.decode(String.self, forKey: .posterURL))
        releaseYear = try container.decode(String.self, forKey: .releaseYear)

        let durationInMinutes = (try TimeInterval(container.decode(String.self, forKey: .duration)) ?? 0.0) * 60
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru")
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.hour, .minute]
        duration = formatter.string(from: durationInMinutes) ?? ""

        genres = Array(try container.decode([String].self, forKey: .genres).prefix(2))
        rating = try container.decode(String.self, forKey: .rating)
        kpRating = try container.decode(String.self, forKey: .kpRating)
    }
}

extension Movie {
    static let mock = Movie(id: "",
                            name: "Драйв",
                            description: "Великолепный водитель – при свете дня он выполняет каскадерские трюки на съёмочных площадках Голливуда, а по ночам ведет рискованную игру. Но один опасный контракт – и за его жизнь назначена награда. Теперь, чтобы остаться в живых и спасти свою очаровательную соседку, он должен делать то, что умеет лучше всего – виртуозно уходить от погони.",
                            posterURL: URL(string: "https://avatars.mds.yandex.net/get-kinopoisk-image/1773646/921089d1-4ebd-4b6f-be74-bfe29b21fad1/orig")!,
                            releaseYear: "2011",
                            duration: "1ч 40 мин",
                            genres: ["криминал", "драма", "триллер"],
                            rating: "7.8",
                            kpRating: "7.8")
}
