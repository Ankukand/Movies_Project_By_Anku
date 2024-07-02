//
//  FavoriteViewController.swift
//  Movies_Anku
//
//  Created by Anku on 01/07/24.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {
    
    // MARK: - Properties
    private var fetchedResultsController: NSFetchedResultsController<FavoriteMovie>!
    private var managedObjectContext: NSManagedObjectContext
    
    // Initialize with managed object context
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        view.backgroundColor = .white
        
        setupTableView()
        setupFetchedResultsController()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Failed to fetch favorite movies: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource
extension FavoriteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let favoriteMovie = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = favoriteMovie.title
        
        if let imageData = favoriteMovie.posterData, let image = UIImage(data: imageData) {
            cell.imageView?.image = image
        } else {
            cell.imageView?.image = UIImage(systemName: "photo")
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension FavoriteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Handle didSelectRow as per your app's requirement (e.g., show movie details)
        let selectedMovie = fetchedResultsController.object(at: indexPath)
        let movieDetailVC = FavMovDetailViewController(favoriteMovie: selectedMovie)
        navigationController?.present(movieDetailVC, animated: true)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension FavoriteViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
