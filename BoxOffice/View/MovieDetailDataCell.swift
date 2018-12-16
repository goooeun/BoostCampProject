//
//  MovieDetailDataCell.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 28..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

class MovieDetailDataCell: UITableViewCell {
    
    var movie: Movie?
    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieGradeImageView: UIImageView!
    @IBOutlet weak var movieDurationReleaseDateLabel: UILabel!
    @IBOutlet weak var movieGenreLabel: UILabel!
    @IBOutlet weak var movieRankAndReservationRateLabel: UILabel!
    @IBOutlet weak var movieUserRatingLabel: UILabel!
    @IBOutlet weak var movieStarRatingView: StarRatingView!
    @IBOutlet weak var movieAudienceLabel: UILabel!
    
    func setView() {
        guard let movie: Movie = self.movie else { return }
        
        DispatchQueue.global().async {
            Request.requestImage(url: movie.image, completion: { (image) in
                DispatchQueue.main.async {
                    self.moviePosterImageView.image = image
                }
            })
        }
        
        self.movieNameLabel.text = movie.title
        
        let movieGrade: String
        if movie.grade == 0 { movieGrade = "ic_allages" }
        else { movieGrade = "ic_\(movie.grade)" }
        self.movieGradeImageView.image = UIImage(named: movieGrade)
        
        self.movieDurationReleaseDateLabel.text = "\(movie.date) 개봉"
        
        self.movieGenreLabel.text = movie.genre
        
        self.movieRankAndReservationRateLabel.text = "\(movie.reservationGrade)위 \(movie.reservationRate)%"
        
        self.movieUserRatingLabel.text = "\(movie.userRating)"
        self.movieStarRatingView.starEditMode = false
        self.movieStarRatingView.setStarsView(ratingValue: movie.userRating)
        
        let audienceValue = NSNumber(value: movie.audience)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: audienceValue)
        
        self.movieAudienceLabel.text = formattedNumber

    }
    
}

