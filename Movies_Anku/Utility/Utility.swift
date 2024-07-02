//
//  Utility.swift
//  Movies_Anku
//
//  Created by Anku on 02/07/24.
//

import Foundation
import UIKit

class AlertManager {
    static func showAlert(on viewController: UIViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}

class LoaderManager {
    static let shared = LoaderManager()
    private var spinner: UIActivityIndicatorView?
    
    private init() { }
    
    func showLoader(on viewController: UIViewController) {
        if spinner == nil {
            spinner = UIActivityIndicatorView(style: .large)
            spinner?.center = viewController.view.center
            spinner?.color = .gray
            viewController.view.addSubview(spinner!)
            spinner?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                spinner!.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
                spinner!.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
            ])
        }
        spinner?.startAnimating()
    }
    
    func hideLoader() {
        spinner?.stopAnimating()
        spinner?.removeFromSuperview()
        spinner = nil
    }
}
