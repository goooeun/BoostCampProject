//
//  MovieCollectionViewController.swift
//  BoxOffice
//
//  Created by goeun on 2018. 7. 25..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

// 화면1 - 영화목록 (컬렉션뷰)
class MovieCollectionViewController: UIViewController {
    // MARK: - Properties
    var movies = [Movies]()
    let cellIdentifier: String = "movieCell"
    
    var orderType: OrderType = .reservationRate {
        didSet {
            self.navigationItem.title = orderType.toKrString()
        }
    }
    var requestParameter: String {
        return "movies?order_type=\(orderType.rawValue)"
    }
    
    var activityIndicator = UIActivityIndicatorView()
    
    // MARK: IBOutlet
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    // MARK: - Methods
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefreshView(refreshControl:)), for: .valueChanged)
        
        moviesCollectionView.refreshControl = refreshControl
        
        if #available(iOS 11.0, *) {
            moviesCollectionView.contentInsetAdjustmentBehavior = .always
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let sharedMovies = BoxOfficeData.shared.moviesData else { return }
        let sharedOrderType = BoxOfficeData.shared.movieOrderType
        
        if self.orderType != sharedOrderType || self.movies.isEmpty {
            self.movies = sharedMovies
            self.orderType = sharedOrderType
            
            self.moviesCollectionView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        BoxOfficeData.shared.moviesData = self.movies
        BoxOfficeData.shared.movieOrderType = self.orderType
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieDetailSegue" {
            guard let nextController: MovieDetailViewController = segue.destination as? MovieDetailViewController else { return }
            
            guard let selectedMovie: Movies = sender as? Movies else { return }
            nextController.movieId = selectedMovie.id
            nextController.movieName = selectedMovie.title
        }
    }
    
}

extension MovieCollectionViewController {
    @IBAction func touchUpSettingButton(_ sender: UIButton) {
        let actionTitle: String = "정렬방식 선택"
        let actionMessage: String = "영화를 어떤 순서로 정렬할까요?"
        
        var alertContrller: UIAlertController
        alertContrller = UIAlertController(title: actionTitle, message: actionMessage, preferredStyle: .actionSheet)
        
        let sortReservationRateAction: UIAlertAction
        sortReservationRateAction = UIAlertAction(title: "예매율", style: .default, handler: { _ in
            self.orderType = .reservationRate
            self.requestMovieData()
        })
        
        let sortCurationAction: UIAlertAction
        sortCurationAction = UIAlertAction(title: "큐레이션", style: .default, handler: { _ in
            self.orderType = .curation
            self.requestMovieData()
        })
        
        let sortDurationReleaseDateAction: UIAlertAction
        sortDurationReleaseDateAction = UIAlertAction(title: "개봉일", style: .default, handler: { _ in
            self.orderType = .durationReleaseDate
            self.requestMovieData()
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertContrller.addAction(sortReservationRateAction)
        alertContrller.addAction(sortCurationAction)
        alertContrller.addAction(sortDurationReleaseDateAction)
        alertContrller.addAction(cancelAction)
        
        self.present(alertContrller, animated: true, completion: nil)
    }
}

extension MovieCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: UICollectionDataSource Methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? MovieCollectionViewCell else {
            let cell = MovieCollectionViewCell()
            return cell
        }
        
        let movies = self.movies[indexPath.item]
        
        cell.movies = movies
        cell.tag = indexPath.item
        cell.setValue(cellRowValue: indexPath.item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    // MARK: UICollectionDelegate Method
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = self.movies[indexPath.item]
        
        performSegue(withIdentifier: "showMovieDetailSegue", sender: selectedMovie)
    }
}

// 서버에 영화 데이터 요청
extension MovieCollectionViewController: ErrorAlertDelegate {
    func requestMovieData() {
        self.showIndicator()
        
        DispatchQueue.global().async {
            defer {
                self.hideIndicator()
            }
            
            Request.requestData(url: self.requestParameter, responseType: MoviesResponse.self) { data in
                DispatchQueue.main.async {
                    if let moviesData = data {
                        self.movies = moviesData.movies
                        self.moviesCollectionView.reloadData()
                    } else {
                        let errorMessage: String = "정보를 불러오는데 실패했습니다.\n 다시 시도해주세요."
                        self.errorAlert(message: errorMessage, title: "데이터 요청 실패", viewController: self)
                    }
                }
            }
        }
    }
}

extension MovieCollectionViewController {
    @objc func pullToRefreshView(refreshControl: UIRefreshControl) {
        DispatchQueue.global().async {
            self.requestMovieData()
        }
        
        refreshControl.endRefreshing()
    }
    
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
