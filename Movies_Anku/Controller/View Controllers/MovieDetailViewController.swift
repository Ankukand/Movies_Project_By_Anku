//
//  MovieDetailViewController.swift
//  Movies_Anku
//
//  Created by Anku on 01/07/24.
//

import UIKit
import SDWebImage
import CoreData

class MovieDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let movie: Movie
    private var cast: [Cast] = []
    private var movieDetail: MovieOverView?
    private var overviewLabel: UILabel!
    private var ratingLabel: UILabel!
    private let tableView = UITableView()
    private var managedObjectContext: NSManagedObjectContext!
    var imageposterImageview = UIImageView()
    private var favoriteButton: UIButton!
    
    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(imageposterImageview.image)
        // Initialize managed object context
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        setupUI()
        fetchMovieDetails()
        fetchCastDetails()
        
        // Check if the movie is favorited and update favoriteButton state
        favoriteButton.isSelected = isFavorite(movie: self.movie)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = movie.title
        
        // Overview Label
        overviewLabel = UILabel()
        overviewLabel.font = UIFont.systemFont(ofSize: 16)
        overviewLabel.numberOfLines = 0
        view.addSubview(overviewLabel)
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overviewLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Rating Label
        ratingLabel = UILabel()
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(ratingLabel)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 10),
            ratingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ratingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Table View
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CastTableViewCell.self, forCellReuseIdentifier: CastTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Favorite Button
        favoriteButton = UIButton(type: .custom)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
    }
    
    @objc private func toggleFavorite() {
        if isFavorite(movie: movie) {
            removeFavorite(movie: movie)
            favoriteButton.isSelected = false // Update button state to not favorited
        } else {
            addFavorite(movie: movie)
            favoriteButton.isSelected = true // Update button state to favorited
        }
    }
    
    private func isFavorite(movie: Movie) -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FavoriteMovie")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(movie.id)")
        
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch {
            print("Failed to fetch favorite movie: \(error)")
            return false
        }
    }
    
    private func addFavorite(movie: Movie) {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteMovie", in: managedObjectContext) else {
            fatalError("Failed to initialize FavoriteMovie entity description")
        }
        
        let favoriteMovie = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        favoriteMovie.setValue(movie.id, forKey: "id")
        favoriteMovie.setValue(movie.title, forKey: "title")
        favoriteMovie.setValue(movie.overview, forKey: "overview")
        favoriteMovie.setValue(movie.releaseDate, forKey: "releaseDate")
        favoriteMovie.setValue(movie.posterPath, forKey: "posterPath")
        favoriteMovie.setValue(movie.posterPath, forKey: "posterPath")
        favoriteMovie.setValue((imageposterImageview.image ?? UIImage()).pngData(), forKey: "posterData")
        do {
            try managedObjectContext.save()
            print("Movie added to favorites")
        } catch {
            print("Failed to save movie to favorites: \(error)")
        }
    }
    
    private func removeFavorite(movie: Movie) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FavoriteMovie")
        fetchRequest.predicate = NSPredicate(format: "id = %@", "\(movie.id)")
        
        do {
            let fetchedEntities = try managedObjectContext.fetch(fetchRequest)
            for entity in fetchedEntities {
                managedObjectContext.delete(entity as! NSManagedObject)
            }
            try managedObjectContext.save()
            print("Movie removed from favorites")
        } catch {
            print("Failed to remove movie from favorites: \(error)")
        }
    }
    
    private func fetchMovieDetails() {
        NetworkManager.shared.fetchMovieDetails(movieID: movie.id, on: self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movieDetail):
                self.movieDetail = movieDetail
                print(movieDetail)
                DispatchQueue.main.async {
                    self.updateMovieDetails()
                }
            case .failure(let error):
                print("Failed to fetch movie details: \(error)")
                // Handle error, show alert or retry logic
            }
        }
    }
    
    private func fetchCastDetails() {
        NetworkManager.shared.fetchCastDetails(movieID: movie.id, on: self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let cast):
                self.cast = cast
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch cast details: \(error)")
                // Handle error, show alert or retry logic
            }
        }
    }
    
    private func updateMovieDetails() {
        if let movieDetail = self.movieDetail {
            overviewLabel.text = movieDetail.overview
            ratingLabel.text = "Rating: \(movieDetail.voteAverage)"
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cast.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CastTableViewCell.reuseIdentifier, for: indexPath) as! CastTableViewCell
        let castMember = cast[indexPath.row]
        cell.configure(with: castMember)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle didSelectRow as per your app's requirement (e.g., show movie details)
    }
}
