//
//  MovieDirectorActorCell.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 28..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

class MovieDirectorActorCell: UITableViewCell {
    
    var movie: Movie?
    
    @IBOutlet weak var movieDirectorLabel: UILabel!
    @IBOutlet weak var movieActorLable: UILabel!
    
    func setView() {
        guard let movie = self.movie else { return }
        
        // 감독,출연
        self.movieDirectorLabel.text = "감독 : \(movie.director)"
        self.movieDirectorLabel.sizeToFit()
        
        self.movieActorLable.text = "출연 : \(movie.actor)"
        self.movieActorLable.sizeToFit()
        
        let separatorLine = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 8))
        separatorLine.backgroundColor = UIColor.groupTableViewBackground
        
        self.addSubview(separatorLine)
    }
    
}
