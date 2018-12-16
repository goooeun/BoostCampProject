//
//  CommentCreateViewController.swift
//  BoxOffice
//
//  Created by goeun on 2018. 8. 15..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

// 화면 3 - 한줄평 작성
class CommentCreateViewController: UIViewController {
    // MARK: - Properties
    var movie: Movie?
    var checkValue: Bool = false
    
    // MARK: IBOutlet
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieGradeImageView: UIImageView!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!

    // MARK: - Methods
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.createNavigationBar()
        
        // 별점이 변경되면 별점 숫자 라벨을 변경하기 위한 노티피케이션
        NotificationCenter.default.addObserver(self, selector: #selector(starRatingValueChanged), name: StarRatingValueChangedDataNotification, object: nil)
        
        // 키보드가 나타나고 사라지는 것을 확인하기 위한 노티피케이션
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // 스크롤뷰에 화면 터치가 인식되도록 해준다
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchUpScreen))
        
        tapGesture.numberOfTapsRequired = 1
        tapGesture.isEnabled = true
        tapGesture.cancelsTouchesInView = false
        
        self.scrollView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let movie = self.movie else { return }
        
        self.movieNameLabel.text = movie.title
        let movieGrade: String
        if movie.grade == 0 { movieGrade = "ic_allages" }
        else { movieGrade = "ic_\(movie.grade)" }
        self.movieGradeImageView.image = UIImage(named: movieGrade)
        
        self.starRatingView.starEditMode = true
        
        let userId: String = BoxOfficeData.shared.userId
        self.userIdTextField.text = userId
        
        self.commentTextView.layer.borderWidth = 1.0
        self.commentTextView.layer.borderColor = UIColor(red:0.31, green:0.44, blue:0.78, alpha:1.0).cgColor

    }
}

extension CommentCreateViewController: ErrorAlertDelegate {
    // Keyboard Event
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func showKeyboard(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            guard let keyboardFrame: NSValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            self.scrollView.contentSize.height += keyboardHeight
            
            let textViewFrameY = self.commentTextView.frame.midY
            
            let scrollBottomOffset = CGPoint(x: 0, y: textViewFrameY)
            scrollView.setContentOffset(scrollBottomOffset, animated: true)
        }
    }
    
    @objc func hideKeyboard(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            guard let keyboardFrame: NSValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            self.scrollView.contentSize.height -= keyboardHeight
            
            let scrolltopOffset = CGPoint(x: 0, y: 0)
            scrollView.setContentOffset(scrolltopOffset, animated: true)
        }
    }

    // MARK: Custom Methods
    @objc func touchUpScreen() {
        self.view.endEditing(true)
    }
    
    func postCommentInfo() {
        if let userId = self.userIdTextField.text {
            BoxOfficeData.shared.userId = userId
            
            guard let movie = self.movie else { return }
            guard let sendContents = self.commentTextView.text,
                let userRating = self.ratingLabel.text,
                let doubleRating = Double(userRating) else { return }
            
            let nowTimeStamp = NSDate().timeIntervalSince1970
            
            let comment = Comment(movieId: movie.id, writer: userId, contents: sendContents, timestamp: nowTimeStamp, rating: doubleRating)
            
            Request.postData(data: comment, url: "comment") { data in
                if data != nil {
                    print("한줄평 등록 성공!")
                } else {
                    let errorMessage: String = "한줄평 등록에 실패했습니다.\n 다시 시도해주세요"
                    self.errorAlert(message: errorMessage, title: "데이터 요청 실패", viewController: self)
                }
            }
        }
    }
    
    @objc func touchUpCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func touchUpDoneButton() {
        self.checkForm()
        if self.checkValue {
            self.postCommentInfo()
            dismiss(animated: true) {
                NotificationCenter.default.post(name: AddCommentsNotification, object: nil)
            }
        }
    }
    
    @objc func starRatingValueChanged(_ notification: Notification) {
        if let notificationUserInfo = notification.userInfo {
            if let ratingValue = notificationUserInfo["ratingValue"] {
                self.ratingLabel.text = "\(ratingValue)"
            }
        }
    }
    
    func checkForm() {
        self.checkValue = true
        
        if let contents = self.commentTextView.text {
            if contents.isEmpty {
                self.checkValue = false
                
                let alertController = UIAlertController(title: "한줄평 작성", message: "한줄평 내용을 입력해주세요", preferredStyle: .alert)
                
                let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertController.addAction(okButton)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        if let userId = self.userIdTextField.text {
            if userId.isEmpty {
                self.checkValue = false
                
                let alertController = UIAlertController(title: "한줄평 작성", message: "사용자 이름을 입력해주세요", preferredStyle: .alert)
                
                let okButton = UIAlertAction(title: "확인", style: .default, handler: nil)
                alertController.addAction(okButton)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func createNavigationBar() {
        let windowBounds = UIScreen.main.bounds
        let windowWidth = windowBounds.width
        
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: windowWidth, height: 64))
        navigationBar.barTintColor = UIColor(red:0.31, green:0.44, blue:0.78, alpha:1.0)
        navigationBar.isTranslucent = false
        self.view.addSubview(navigationBar)
        
        let navigationItem = UINavigationItem(title: "한줄평 작성")
        
        let leftItem = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: #selector(self.touchUpCancelButton))
        navigationItem.leftBarButtonItem = leftItem
        let rightItem = UIBarButtonItem(title: "완료", style: .plain, target: nil, action: #selector(self.touchUpDoneButton))
        navigationItem.rightBarButtonItem = rightItem
        
        navigationBar.setItems([navigationItem], animated: false)
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        
        navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        navigationBar.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        navigationBar.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
    }

}
