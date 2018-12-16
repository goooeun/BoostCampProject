//
//  APIResponse.swift
//  BoxOffice
//
//  Created by goeun on 2018. 7. 30..
//  Copyright © 2018년 basic. All rights reserved.
//

import Foundation

struct MoviesResponse: Decodable {
    let movies: [Movies]
}

struct Movies: Decodable {
    let id: String
    let thumb: String
    let reservationRate: Double
    let grade: Int
    let userRating: Double
    let date: String
    let reservationGrade: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id, thumb, grade, date, title
        case reservationRate = "reservation_rate"
        case userRating = "user_rating"
        case reservationGrade = "reservation_grade"
    }
}
