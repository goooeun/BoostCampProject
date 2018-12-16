//
//  MovieDetailViewController.swift
//  BoxOffice
//
//  Created by goeun on 2018. 7. 26..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

let AddCommentsNotification: Notification.Name = Notification.Name("AddComment")

// 화면 2 - 영화 상세 정보
class MovieDetailViewController: UITableViewController {
    
    // MARK: - Properties
    var movieId: String?
    var movieName: String?
    var movie: Movie?
    
    var movieRequestParameter: String {
        return "movie?id=\(movieId ?? "")"
    }
    
    var commentsRequestParameter: String {
        return "comments?movie_id=\(movieId ?? "")"
    }
    
    var comments = [Comments]()
    let cells = ["movieDetailDataCell","movieSynopsisCell","movieDirectorActorCell","commentTitleBarCell"]
    
    var activityIndicator = UIActivityIndicatorView()
    var cellHeaderView = UIView()
    
    // MARK: IBOutlet
    @IBOutlet var dataTableView: UITableView!
    
    // MARK: - Methods
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = self.movieId else { return }
        
        if let title = self.movieName {
            self.navigationItem.title = title
        }
        
        dataTableView.register(UINib(nibName: "MovieDetailDataCell", bundle: nil), forCellReuseIdentifier: cells[0])
        dataTableView.register(UINib(nibName: "MovieSynopsisCell", bundle: nil), forCellReuseIdentifier: cells[1])
        dataTableView.register(UINib(nibName: "MovieDirectorActorCell", bundle: nil), forCellReuseIdentifier: cells[2])
        dataTableView.register(UINib(nibName: "CommentTitleBarCell", bundle: nil), forCellReuseIdentifier: cells[3])
        dataTableView.register(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "commentsCell")
        
        dataTableView.estimatedRowHeight = dataTableView.rowHeight
        dataTableView.rowHeight = UITableViewAutomaticDimension
        
        DispatchQueue.global().async {
            self.showIndicator()
            self.requestMovieDetailData(movieId: id)
            self.requestMovieCommentData(movieId: id)
        }
        
        // 한줄평이 등록되면 한줄평 테이블을 새로고침 하기 위한 노티피케이션
        NotificationCenter.default.addObserver(self, selector: #selector(addCommentNotification(_:)), name: AddCommentsNotification, object: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreateComment" {
            guard let nextController: CommentCreateViewController = segue.destination as? CommentCreateViewController else { return }
            
            guard let sendMovieData: Movie = sender as? Movie else { return }
            
            nextController.movie = sendMovieData
        }
    }
    
}

extension MovieDetailViewController {
    // MARK: UITableViewDataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : self.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellIdentifier = cells[indexPath.row]
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieDetailDataCell else {
                    let cell = MovieDetailDataCell()
                    return cell
                }
                cell.movie = self.movie
                cell.setView()
                cell.moviePosterImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpMoviePosterImage(_:))))
                
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieSynopsisCell else {
                    let cell = MovieSynopsisCell()
                    return cell
                }
                cell.movie = self.movie
                cell.setView()
                
                return cell
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieDirectorActorCell else {
                    let cell = MovieDirectorActorCell()
                    return cell
                }
                cell.movie = self.movie
                cell.setView()
                
                return cell
            case 3:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CommentTitleBarCell else {
                    let cell = CommentTitleBarCell()
                    return cell
                }
                cell.setView()
                cell.createCommentButton.addTarget(self, action: #selector(touchUpCreateCommentButton(_:)), for: .touchUpInside)
                return cell
            default:
                return UITableViewCell()
            }
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as? CommentsTableViewCell else {
                let cell = CommentsTableViewCell()
                return cell
            }
            cell.comments = self.comments[indexPath.row]
            cell.tag = indexPath.row
            cell.setViews(cellRowValue: indexPath.row)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension MovieDetailViewController: ErrorAlertDelegate {
    // 영화 정보 요청
    func requestMovieDetailData(movieId: String) {
        self.showIndicator()
        
        DispatchQueue.global().async {
            defer {
                self.hideIndicator()
            }
            
            Request.requestData(url: self.movieRequestParameter, responseType: Movie.self) { data in
                DispatchQueue.main.async {
                    if let movieData = data {
                        self.movie = movieData
                        self.dataTableView.reloadSections(IndexSet(integer: 0), with: .none)
                    } else {
                        let errorMessage: String = "정보를 불러오는데 실패했습니다.\n 다시 시도해주세요."
                        self.errorAlert(message: errorMessage, title: "데이터 요청 실패", viewController: self)
                    }
                }
            }
        }
    }
    
    // 한줄평 요청
    func requestMovieCommentData(movieId: String) {
        self.showIndicator()
        
        DispatchQueue.global().async {
            defer {
                self.hideIndicator()
            }
            
            Request.requestData(url: self.commentsRequestParameter, responseType: CommentsResponse.self) { data in
                DispatchQueue.main.async {
                    if let commentsData = data {
                            self.comments = commentsData.comments
                            self.dataTableView.reloadSections(IndexSet(integer: 1), with: .none)
                    } else {
                        let errorMessage: String = "정보를 불러오는데 실패했습니다.\n 다시 시도해주세요."
                        self.errorAlert(message: errorMessage, title: "데이터 요청 실패", viewController: self)
                    }
                }
            }
        }
    }
}

extension MovieDetailViewController {
    // 한줄평 작성버튼 클릭
    @IBAction func touchUpCreateCommentButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showCreateComment", sender: self.movie)
    }
    
    // 영화 포스터 이미지 터치해서 크게보기
    @IBAction func touchUpMoviePosterImage(_ sender: UITapGestureRecognizer) {
        guard let posterImageView = sender.view as? UIImageView else { return }
        
        if let posterImage = posterImageView.image {
            let largeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
            largeImageView.image = posterImage
            largeImageView.backgroundColor = UIColor(red:0.17, green:0.17, blue:0.17, alpha:1.0)
            largeImageView.contentMode = .scaleAspectFit
            largeImageView.isUserInteractionEnabled = true
            
            let tapImageViewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissMoviePosterImage(_:)))
            largeImageView.addGestureRecognizer(tapImageViewGestureRecognizer)
            
            self.view.addSubview(largeImageView)
            
            largeImageView.translatesAutoresizingMaskIntoConstraints = false
            
            let safeAreaGuide = self.view.safeAreaLayoutGuide
            
            largeImageView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor).isActive = true
            largeImageView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor).isActive = true
            largeImageView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor).isActive = true
            largeImageView.bottomAnchor.constraint(equalTo: safeAreaGuide.bottomAnchor).isActive = true
            
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
        
    }
    
    // 큰 영화 포스터 화면 없애기
    @objc func dismissMoviePosterImage(_ sender: UITapGestureRecognizer) {
        guard let posterImageView = sender.view as? UIImageView else { return }
        
        posterImageView.removeFromSuperview()
        
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // 새로운 댓글이 등록되면 노티피케이션으로 테이블을 바로 새로고침
    @objc func addCommentNotification(_ notification: Notification) {
        guard let id: String = self.movieId else { return }
        
        DispatchQueue.global().async {
            self.requestMovieCommentData(movieId: id)
        }
    }
    
}

extension MovieDetailViewController {
    func showIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            self.view.addSubview(self.activityIndicator)
            
            let safeAreaLayoutGuide: UILayoutGuide = self.view.safeAreaLayoutGuide
            self.activityIndicator.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
            self.activityIndicator.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
            
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.activityIndicator.removeFromSuperview()
        }
    }
}
