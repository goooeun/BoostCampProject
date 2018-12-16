//
//  Comment.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 17..
//  Copyright © 2018년 basic. All rights reserved.
//

import Foundation

struct Comment: Encodable {
    let movieId: String
    let writer: String
    let contents: String
    let timestamp: Double
    let rating: Double
    
    enum CodingKeys: String, CodingKey {
        case movieId = "movie_id"
        case writer, contents, timestamp, rating
    }
}


