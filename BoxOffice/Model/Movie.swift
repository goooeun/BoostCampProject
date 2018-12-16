//
//  MovieResponse.swift
//  BoxOffice
//
//  Created by goeun on 2018. 7. 30..
//  Copyright © 2018년 basic. All rights reserved.
//

import Foundation

struct Movie: Decodable {
    let date: String
    let id: String
    let reservationRate: Double
    let image: String
    let synopsis: String
    let genre: String
    let reservationGrade: Int
    let actor: String
    let userRating: Double
    let duration: Int
    let grade: Int
    let audience: Int
    let title: String
    let director: String
    
    enum CodingKeys: String, CodingKey {
        case actor, audience, date, director, duration, grade, genre, id, image, synopsis, title
        case reservationGrade = "reservation_grade"
        case reservationRate = "reservation_rate"
        case userRating = "user_rating"
    }
}
