//
//  CommentTitelBarCell.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 29..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

class CommentTitleBarCell: UITableViewCell {
    @IBOutlet weak var createCommentButton: UIButton!
    
    func setView() {
        let separatorLine = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 8))
        separatorLine.backgroundColor = UIColor.groupTableViewBackground
        
        self.addSubview(separatorLine)
    }
}
