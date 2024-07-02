//
//  CoreDataManager.swift
//  Movies_Anku
//
//  Created by Anku on 01/07/24.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "MovieApp")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    func addFavorite(movie: Movie) {
        let context = persistentContainer.viewContext
        let favoriteMovie = FavoriteMovie(context: context)
        favoriteMovie.id = Int64(movie.id)
        favoriteMovie.title = movie.title
        favoriteMovie.overview = movie.overview
        favoriteMovie.releaseDate = movie.releaseDate
        favoriteMovie.posterPath = movie.posterPath
        
        saveContext()
    }
    
    func removeFavorite(movie: Movie) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movie.id)
        
        do {
            let favoriteMovies = try context.fetch(fetchRequest)
            for favoriteMovie in favoriteMovies {
                context.delete(favoriteMovie)
            }
            saveContext()
        } catch {
            print("Failed to remove favorite movie: \(error)")
        }
    }
    
    func fetchFavorites() -> [FavoriteMovie] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch favorite movies: \(error)")
            return []
        }
    }
     
    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}

