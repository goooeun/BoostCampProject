//
//  CommentsResponse.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 11..
//  Copyright © 2018년 basic. All rights reserved.
//

import Foundation

struct CommentsResponse: Decodable {
    let comments: [Comments]
}

struct Comments {
    let movieId: String
    let writer: String
    let id: String
    let contents: String
    let timestamp: Double?
    let rating: Double
    let writerImage: String?

    enum CommentsCodingKeys: String, CodingKey {
        case writer, id, contents, timestamp, rating
        case movieId = "movie_id"
        case writerImage = "writer_image"
    }
    
}

extension Comments: Decodable {
    init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: CommentsCodingKeys.self)
        
        self.movieId = try dataContainer.decode(String.self, forKey: .movieId)
        self.writer = try dataContainer.decode(String.self, forKey: .writer)
        self.id = try dataContainer.decode(String.self, forKey: .id)
        self.contents = try dataContainer.decode(String.self, forKey: .contents)
        
        if dataContainer.contains(.timestamp) {
            self.timestamp = try dataContainer.decode(Double.self, forKey: .timestamp)
        } else {
            self.timestamp = nil
        }
        self.rating = try dataContainer.decode(Double.self, forKey: .rating)
        
        if dataContainer.contains(.writerImage) {
            self.writerImage = try dataContainer.decode(String.self, forKey: .writerImage)
        } else {
            self.writerImage = nil
        }
    }
}

