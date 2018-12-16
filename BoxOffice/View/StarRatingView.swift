//
//  StarRatingView.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 14..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

let StarRatingValueChangedDataNotification: Notification.Name = Notification.Name("StarRatingValueChanged")

class StarRatingView: UIStackView {
    
    // MARK: - Properties
    private var starButtons = [UIButton]()
    
    let fullStarImageName: String = "ic_star_large_full"
    let halfStarImageName: String = "ic_star_large_half"
    let emptyStarImageName: String = "ic_star_large"
    
    var starButtonsSize: CGFloat = 20
    var rating: Int = 1
    var starEditMode: Bool = false {
        didSet {
            setEmptyStarView()
        }
    }
    
    var longPressGesture = UILongPressGestureRecognizer()
    
    // MARK: - Methods
    // 비어있는 별 이미지 버튼을 5개 생성
    func setEmptyStarView() {
        
        // 기존에 있는것 삭제
        for starButton in starButtons {
            removeArrangedSubview(starButton)
            starButton.removeFromSuperview()
        }
        
        starButtons.removeAll()
        
        for i in 1 ... 5 {
            let emptyStarButton: UIButton = UIButton()
            
            // 별점은 1점부터 시작
            var starImageName: String = emptyStarImageName
            if i == 1 { starImageName = halfStarImageName }
        
            let emptyStarImage = UIImage(named: starImageName)
            emptyStarButton.setImage(emptyStarImage, for: .normal)
            emptyStarButton.adjustsImageWhenHighlighted = false
            emptyStarButton.addTarget(self, action: #selector(touchStarButton(_:forEvent:)), for: .touchUpInside)
            
            if starEditMode == true {
                starButtonsSize = 62.5
        
                emptyStarButton.isUserInteractionEnabled = true
            } else {
                emptyStarButton.isUserInteractionEnabled = false
            }
            
            emptyStarButton.translatesAutoresizingMaskIntoConstraints = false
            emptyStarButton.widthAnchor.constraint(equalToConstant: self.starButtonsSize).isActive = true
            emptyStarButton.heightAnchor.constraint(equalToConstant: self.starButtonsSize).isActive = true
            
            emptyStarButton.tag = 100 + i
    
            addArrangedSubview(emptyStarButton)
            starButtons.append(emptyStarButton)
        }
        
        if starEditMode {
            longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressStarButton(_:)))
            longPressGesture.minimumPressDuration = 0.1
            addGestureRecognizer(longPressGesture)
        }

    }
    
    // 조작이 불가능한 기본 별점뷰 세팅
    func setStarsView(ratingValue: Double) {
        
        let starRatingValue: Double = floor(ratingValue) / 2.0
        
        let fullStarCount: Double = floor(starRatingValue)
        let halfStarCount: Double = starRatingValue - fullStarCount
        
        let halfStarState: Bool
        if halfStarCount == 0.5 { halfStarState = true }
        else { halfStarState = false }
        
        if fullStarCount > 0 {

            for i in 1 ... Int(fullStarCount) {
                let tagValue = 100 + i
                guard let starButton = self.viewWithTag(tagValue) as? UIButton else { return }
                let starImage = UIImage(named: fullStarImageName)
                starButton.setImage(starImage, for: .normal)
            }
            
            if halfStarState {
                let tagValue = 101 + Int(fullStarCount)
                guard let starButton = self.viewWithTag(tagValue) as? UIButton else { return }
                let starImage = UIImage(named: halfStarImageName)
                starButton.setImage(starImage, for: .normal)
            }
        
        } else {
            guard let starButton = self.viewWithTag(101) as? UIButton else { return }
            let starImage = UIImage(named: halfStarImageName)
            starButton.setImage(starImage, for: .normal)
        }
    }
    
    // 별점 버튼을 눌렀을때 이벤트 (기본 터치시 이벤트)
    @IBAction func touchStarButton(_ sender: UIButton, forEvent event: UIEvent) {
        setEmptyStarView()
        
        guard let firstTouch: UITouch = event.touches(for: sender)?.first else { return }
        let touchLocation = firstTouch.location(in: sender)
        
        var halfState: Bool = false
        
        let buttonCenterX = (sender.frame.maxX + sender.frame.minX) / 2
        
        if touchLocation.x < buttonCenterX {
            halfState = true
        }
        
        let tagValue = sender.tag
        
        var ratingValue = (tagValue - 100) * 2
        if halfState { ratingValue -= 1 }
        self.rating = ratingValue
        
        NotificationCenter.default.post(name: StarRatingValueChangedDataNotification, object: nil, userInfo: ["ratingValue":ratingValue])
        
        for i in 101 ... tagValue {
            guard let starButton = self.viewWithTag(i) as? UIButton else { return }
            
            var buttonImageName: String = fullStarImageName
            if i == tagValue && halfState {
                buttonImageName = halfStarImageName
            }
            
            let starImage = UIImage(named: buttonImageName)
            starButton.setImage(starImage, for: .normal)
        }
    }
    
    // 버튼을 길게 눌러 드래그하여 별점을 주는 이벤트
    @objc func longPressStarButton(_ press: UILongPressGestureRecognizer) {
        let touchLocation = press.location(in: self)
        
        let frameWidth = self.frame.size.width
        
        let halfStarButtonSize = frameWidth / 10
        let touchValue = touchLocation.x / halfStarButtonSize
        
        var ratingValue: CGFloat
        if touchValue < 10.5 {
            ratingValue = round(touchValue)
        } else {
            ratingValue = 10
        }
    
        var halfState: Bool = false
        
        var tagValue: Int = 100 + Int(floor(ratingValue / 2))
        if ratingValue.truncatingRemainder(dividingBy: 2) != 0 {
            tagValue += 1
            halfState = true
        }
        
        setEmptyStarView()
        
        if ratingValue > 0 && ratingValue < 11 {
            
            NotificationCenter.default.post(name: StarRatingValueChangedDataNotification, object: nil, userInfo: ["ratingValue":Int(ratingValue)])
        
            for i in 101 ... tagValue {
                guard let starButton = self.viewWithTag(i) as? UIButton else { return }
                
                var buttonImageName: String = fullStarImageName
                if i == tagValue && halfState {
                    buttonImageName = halfStarImageName
                }
                
                let starImage = UIImage(named: buttonImageName)
                starButton.setImage(starImage, for: .normal)
            }
        }
    }
}
