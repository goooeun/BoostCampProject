//
//  MovieTableViewController.swift
//  BoxOffice
//
//  Created by goeun on 2018. 7. 18..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

// 화면1 - 영화목록 (테이블뷰)
class MovieTableViewController: UIViewController {
    
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
    @IBOutlet weak var moviesTableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestMovieData()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefreshView(refreshControl:)), for: .valueChanged)
        
        moviesTableView.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let sharedMovies = BoxOfficeData.shared.moviesData else { return }
        
        if self.orderType != BoxOfficeData.shared.movieOrderType {
            self.movies = sharedMovies
            self.orderType = BoxOfficeData.shared.movieOrderType
            
            self.moviesTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        BoxOfficeData.shared.moviesData = self.movies
        BoxOfficeData.shared.movieOrderType = self.orderType
    }
    
    // MARK: - Methods
    // MARK: IBAction
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

// 서버에 영화 데이터 요청
extension MovieTableViewController: ErrorAlertDelegate {
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
                        self.moviesTableView.reloadData()
                    } else {
                        let errorMessage: String = "정보를 불러오는데 실패했습니다.\n 다시 시도해주세요."
                        self.errorAlert(message: errorMessage, title: "데이터 요청 실패", viewController: self)
                    }
                }
            }
        }
    }
}

extension MovieTableViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieTableViewCell else {
            let cell = MovieTableViewCell()
            return cell
        }
        
        let movies = self.movies[indexPath.row]
        
        cell.movies = movies
        cell.tag = indexPath.row
        cell.setValue(cellRowValue: indexPath.row)
        
        return cell
    }
    
    // MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMovie = self.movies[indexPath.row]
        
        performSegue(withIdentifier: "showMovieDetailSegue", sender: selectedMovie)
    }
}

extension MovieTableViewController {
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
