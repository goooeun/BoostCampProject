//
//  MoviesTableViewCell.swift
//  BoxOffice
//
//  Created by goeun on 2018. 7. 21..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var movies: Movies?
    
    // MARK: IBOutlet
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieGradeImageView: UIImageView!
    @IBOutlet weak var movieRankLabel: UILabel!
    @IBOutlet weak var movieReservationRateLabel: UILabel!
    @IBOutlet weak var movieUserRatingLabel: UILabel!
    @IBOutlet weak var movieDurationReleaseDateLabel: UILabel!
    
    func setValue(cellRowValue: Int) {
        guard let movies: Movies = self.movies else { return }
        
        // 비동기 백그라운드 스레드에서 이미지 다운로드
        DispatchQueue.global().async {
            Request.requestImage(url: movies.thumb, completion: { (image) in
                DispatchQueue.main.async {
                    if self.tag == cellRowValue {
                        self.moviePosterImageView.image = image
                    }
                }
            })
        }
        
        self.movieNameLabel.text = movies.title
        self.movieNameLabel.sizeToFit()
        
        let movieGrade: String
        
        if movies.grade == 0 { movieGrade = "ic_allages" }
        else { movieGrade = "ic_\(movies.grade)" }
        self.movieGradeImageView.image = UIImage(named: movieGrade)
        
        self.movieRankLabel.text = "예매순위 : \(movies.reservationGrade)위"
        self.movieReservationRateLabel.text = "예매율 : \(movies.reservationRate)%"
        self.movieReservationRateLabel.sizeToFit()
        
        self.movieUserRatingLabel.text = " \(movies.userRating)"
        
        self.movieDurationReleaseDateLabel.text = "개봉일 : \(movies.date)"
        self.movieDurationReleaseDateLabel.sizeToFit()
    }
    
}
