//
//  Delegate.swift
//  BoxOffice
//
//  Created by goeun on 15/12/2018.
//  Copyright © 2018 basic. All rights reserved.
//

import UIKit

protocol ErrorAlertDelegate {
    func errorAlert(message: String, title: String, viewController: UIViewController)
}

extension ErrorAlertDelegate {
    func errorAlert(message: String, title: String, viewController: UIViewController) {
        let alertMessage = message
        let alertTitle = title
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default ) { _ in
            viewController.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
