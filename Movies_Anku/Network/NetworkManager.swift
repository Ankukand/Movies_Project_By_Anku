//
//  NetworkManager.swift
//  Movies_Anku
//
//  Created by Anku on 01/07/24.
//

import Alamofire
import UIKit

struct Constant {
    fileprivate static let apiKey = "51a1257438b8d8f35799b279e858e1d5"
    fileprivate static let baseUrl = "https://api.themoviedb.org/3"
}
class NetworkManager {
    static let shared = NetworkManager()
    private let reachabilityManager = NetworkReachabilityManager()
    private init() {
        startNetworkReachabilityObserver()
    }
    private func startNetworkReachabilityObserver() {
        reachabilityManager?.startListening { [weak self] status in
            guard let self = self else { return }
            
            switch status {
            case .notReachable:
                print("The network is not reachable")
                // Assuming you have an AlertManager class with showAlert method
                DispatchQueue.main.async {
                    AlertManager.showAlert(on: self.currentViewController() ?? UIViewController(), title: "Network Unreachable", message: "Please check your internet connection.")
                }
                
            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
            case .reachable(.cellular):
                print("The network is reachable over the cellular connection")
            case .unknown:
                print("It is unknown whether the network is reachable")
            }
        }
    }
    
    private func isNetworkReachable() -> Bool {
        return reachabilityManager?.isReachable ?? false
    }
    
    private func currentViewController() -> UIViewController? {
        // Implement a method to get the current visible view controller
        // This can depend on your app structure, such as navigation controllers, tab controllers, etc.
        // Example:
        if let currentVC = UIApplication.shared.windows.first?.currentViewController {
            // Use `currentVC` to perform actions or access properties of the current visible view controller.
            print("Current View Controller: \(currentVC)")
            return currentVC
        } else {
            print("No visible view controller found.")
            return nil
        }
    }
    
    private func performRequest<T: Decodable>(url: String, parameters: Parameters, on viewController: UIViewController, responseType: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard isNetworkReachable() else {
            AlertManager.showAlert(on: viewController, title: "Network Error", message: "No Internet Connection")
            
            completion(.failure(AFError.sessionTaskFailed(error: URLError(.notConnectedToInternet))))
            return
        }
        
        LoaderManager.shared.showLoader(on: viewController)
        
        AF.request(url, parameters: parameters).responseDecodable(of: T.self) { response in
            LoaderManager.shared.hideLoader()
            switch response.result {
            case .success(let responseData):
                completion(.success(responseData))
            case .failure(let error):
                AlertManager.showAlert(on: viewController, title: "Error", message: error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func fetchMovies(page: Int, on viewController: UIViewController, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        let url = "\(Constant.baseUrl)/discover/movie"
        let parameters: Parameters = [
            "api_key": Constant.apiKey,
            "page": page
        ]
        performRequest(url: url, parameters: parameters, on: viewController, responseType: MovieResponse.self, completion: completion)
    }
    
    func searchMovies(query: String, page: Int, on viewController: UIViewController, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        let url = "\(Constant.baseUrl)/search/movie"
        let parameters: Parameters = [
            "api_key": Constant.apiKey,
            "query": query,
            "page": page
        ]
        performRequest(url: url, parameters: parameters, on: viewController, responseType: MovieResponse.self, completion: completion)
    }
    
    func fetchCastDetails(movieID: Int, on viewController: UIViewController, completion: @escaping (Result<[Cast], Error>) -> Void) {
        let urlString = "\(Constant.baseUrl)/movie/\(movieID)/credits?api_key=\(Constant.apiKey)"
        performRequest(url: urlString, parameters: [:], on: viewController, responseType: CastDetail.self) { result in
            switch result {
            case .success(let castDetail):
                completion(.success(castDetail.cast))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMovieDetails(movieID: Int, on viewController: UIViewController, completion: @escaping (Result<MovieOverView, Error>) -> Void) {
        let url = "\(Constant.baseUrl)/movie/\(movieID)"
        let parameters: [String: String] = [
            "api_key": Constant.apiKey
            // Add any additional parameters if needed
        ]
        performRequest(url: url, parameters: parameters, on: viewController, responseType: MovieOverView.self, completion: completion)
    }
}
extension UIWindow {
    /// Get the current visible view controller from the window's root view controller.
    var currentViewController: UIViewController? {
        guard let rootViewController = self.rootViewController else {
            return nil
        }
        return UIWindow.getCurrentViewController(from: rootViewController)
    }
    
    /// Recursively traverse through the view controller hierarchy to find the visible view controller.
    private static func getCurrentViewController(from viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            // If the view controller is a navigation controller, return the visible view controller of the navigation stack.
            return getCurrentViewController(from: navigationController.visibleViewController ?? navigationController)
        } else if let tabBarController = viewController as? UITabBarController {
            // If the view controller is a tab bar controller, return the selected view controller of the tab bar.
            if let selectedViewController = tabBarController.selectedViewController {
                return getCurrentViewController(from: selectedViewController)
            }
            return tabBarController
        } else if let presentedViewController = viewController.presentedViewController {
            // If the view controller presents another view controller, return the presented view controller.
            return getCurrentViewController(from: presentedViewController)
        }
        // Otherwise, return the view controller itself.
        return viewController
    }
}
