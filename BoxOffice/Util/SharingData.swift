//
//  SharingData.swift
//  BoxOffice
//
//  Created by goeun on 15/12/2018.
//  Copyright © 2018 basic. All rights reserved.
//

import UIKit

private let orderTypeKr = ["예매율순", "큐레이션순", "개봉일순"]

enum OrderType: Int {
    case reservationRate = 0
    case curation = 1
    case durationReleaseDate = 2
    
    func toKrString() -> String {
        return orderTypeKr[self.rawValue]
    }
}

class BoxOfficeData {
    static let shared: BoxOfficeData = BoxOfficeData()
    
    var moviesData: [Movies]?
    var movieOrderType: OrderType = .reservationRate
    var userId: String = ""
}
