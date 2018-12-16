//
//  Request.swift
//  BoxOffice
//
//  Created by goeun on 2018. 7. 25..
//  Copyright © 2018년 basic. All rights reserved.
//

import UIKit

struct Request {
    // MARK: - Type Properties
    private static let baseURL: String = "http://connect-boxoffice.run.goorm.io/"
    private static let defaultSession: URLSession = URLSession(configuration: .default)
    private static var storedThumbImage: [URL:UIImage] = [:]
}

extension Request {
    // MARK: - Type Methods
    static func requestData<T: Decodable>(url: String, responseType: T.Type, completion: @escaping (T?) -> Void) {
        guard let requestURL: URL = URL(string: baseURL+url) else {
            print("잘못된 URL")
            completion(nil)
            return
        }
        
        let dataTask = Request.defaultSession.dataTask(with: requestURL) { ( data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("데이터가 없습니다.")
                completion(nil)
                return
            }
            
            let jsonDecoder: JSONDecoder = JSONDecoder()
            do {
                let response = try jsonDecoder.decode(T.self, from: data)
                completion(response)
            } catch {
                print(error.localizedDescription)
                completion(nil)
            }
        }
        dataTask.resume()
    }
    
    static func requestImage(url: String, completion: @escaping (UIImage?) -> Void) {
        guard let requestURL: URL = URL(string: url) else {
            print("잘못된 URL")
            completion(nil)
            return
        }
        
        if let storedImage: UIImage = storedThumbImage[requestURL] {
            completion(storedImage)
        }
        
        guard let imageData: Data = try? Data(contentsOf: requestURL) else {
            completion(nil)
            return
        }
        
        let image = UIImage(data: imageData)
        storedThumbImage[requestURL] = image
        completion(image)
    }
    
    static func postData<T: Encodable>(data: T, url: String, completion: @escaping (Data?) -> Void) {
        guard let requestURL: URL = URL(string: baseURL+url) else {
            print("잘못된 URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        
        do {
            let jsonEncoder = JSONEncoder()
            let postData = try jsonEncoder.encode(data)
            request.httpBody = postData
        } catch {
            print(error.localizedDescription)
        }
        
        let dataTask = defaultSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            
            completion(data)
        }
        
        dataTask.resume()
    }
    
}
