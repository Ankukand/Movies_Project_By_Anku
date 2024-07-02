//
//  SearchViewController.swift
//  Movies_Anku
//
//  Created by Anku on 01/07/24.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var movies: [Movie] = []
    private var currentPage = 1
    private var totalPages = 1
    private var isFetching = false
    private var isSearching = false
    private var searchQuery: String?
    private let debouncer = Debouncer(interval: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        setupUI()
        fetchMovies()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.items = [flexSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func fetchMovies() {
        guard !isFetching else { return }
        isFetching = true
        
        NetworkManager.shared.fetchMovies(page: currentPage, on: self) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let movieResponse):
                self.movies.append(contentsOf: movieResponse.results)
                self.totalPages = movieResponse.totalPages
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch movies: \(error)")
            }
        }
    }
    
    private func fetchSearchResults(query: String) {
        guard !isFetching else { return }
        isFetching = true
        
        NetworkManager.shared.searchMovies(query: query, page: currentPage, on: self) { [weak self] result in
            guard let self = self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let movieResponse):
                self.movies.append(contentsOf: movieResponse.results)
                self.totalPages = movieResponse.totalPages
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to search movies: \(error)")
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            searchQuery = nil
            movies.removeAll()
            currentPage = 1
            fetchMovies()
        } else {
            debouncer.debounce { [weak self] in
                guard let self = self else { return }
                self.isSearching = true
                self.searchQuery = searchText
                self.movies.removeAll()
                self.currentPage = 1
                self.fetchSearchResults(query: searchText)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        isSearching = true
        searchQuery = query
        movies.removeAll()
        currentPage = 1
        fetchSearchResults(query: query)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? MovieTableViewCell else { return }
        let movie = movies[indexPath.row]
        let detailVC = MovieDetailViewController(movie: movie)
        detailVC.imageposterImageview = cell.posterImageView
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard currentPage < totalPages else { return }
            currentPage += 1
            if isSearching, let query = searchQuery {
                fetchSearchResults(query: query)
            } else {
                fetchMovies()
            }
        }
    }
}



