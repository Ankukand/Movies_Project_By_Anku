//
//  MovieTableViewCell.swift
//  Movies_Anku
//
//  Created by Anku on 01/07/24.
//

import UIKit
import SDWebImage

class MovieTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MovieTableViewCell"
    let posterImageView = UIImageView()
    let titleLabel = UILabel()
    let releaseYearLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(posterImageView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        releaseYearLabel.font = UIFont.systemFont(ofSize: 14)
        releaseYearLabel.textColor = .gray
        releaseYearLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(releaseYearLabel)
        
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            posterImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 60),
            posterImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            releaseYearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseYearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            releaseYearLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            releaseYearLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        releaseYearLabel.text = String(movie.releaseDate?.prefix(4) ?? "") // Assumes releaseDate is a String in "YYYY-MM-DD" format
        
        // Load the poster image using SDWebImage
        if let posterPath = movie.posterPath {
            let imageUrl = URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)")!
            posterImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        } else {
            posterImageView.image = UIImage(named: "placeholder")
        }
    }
}

