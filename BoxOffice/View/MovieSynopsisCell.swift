//
//  MovieSynopsisCell.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 28..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

class MovieSynopsisCell: UITableViewCell {
    
    var movie: Movie?
    
    @IBOutlet weak var movieSynopsisTextView: UITextView!
    
    func setView() {
        guard let movie = self.movie else { return }
        // 줄거리
        self.movieSynopsisTextView.text = movie.synopsis
        self.movieSynopsisTextView.sizeToFit()
        
        let separatorLine = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 8))
        separatorLine.backgroundColor = UIColor.groupTableViewBackground
        
        self.addSubview(separatorLine)
    }
    
}
