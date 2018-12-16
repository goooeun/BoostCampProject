//
//  CommentsTableViewCell.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 28..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    var comments: Comments?
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userRatingStackView: StarRatingView!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    
    func setViews(cellRowValue: Int) {
        guard let comments: Comments = self.comments else { return }
        
        DispatchQueue.global().async {
            guard let userImage = comments.writerImage else { return }
            
            Request.requestImage(url: userImage, completion: { (image) in
                DispatchQueue.main.async {
                    if self.tag == cellRowValue {
                        self.userImageView.image = image
                    }
                }
            })
        }
        
        if comments.writer.isEmpty { self.userIdLabel.text = "이름 없음" }
        else { self.userIdLabel.text = comments.writer }
        
        self.userRatingStackView.starEditMode = false
        self.userRatingStackView.setStarsView(ratingValue: comments.rating)
        
        if let createdDate = comments.timestamp {
            let date = Date(timeIntervalSince1970: createdDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let formatDate = dateFormatter.string(from: date)
            self.createdDateLabel.text = formatDate
            
        } else {
            self.createdDateLabel.text = ""
        }
        
        self.reviewTextView.text = comments.contents
        self.reviewTextView.textContainer.lineFragmentPadding = 0
        self.reviewTextView.sizeToFit()
        
        let separatorLine = UIView(frame: CGRect(x: 0, y: self.frame.maxY-1, width: self.bounds.width, height: 1))
        separatorLine.backgroundColor = UIColor.groupTableViewBackground
        
        self.addSubview(separatorLine)
    }
    
}
