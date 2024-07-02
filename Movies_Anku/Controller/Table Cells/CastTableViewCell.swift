//
//  CastTableViewCell.swift
//  Movies_Anku
//
//  Created by Anku on 02/07/24.
//

import UIKit
import SDWebImage

class CastTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CastTableViewCell"
    
    private let nameLabel = UILabel()
    private let characterLabel = UILabel()
    private let castImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure nameLabel
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        contentView.addSubview(nameLabel)
        
        // Configure characterLabel
        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        characterLabel.font = UIFont.systemFont(ofSize: 14)
        characterLabel.textColor = .gray
        contentView.addSubview(characterLabel)
        
        // Configure castImageView
        castImageView.translatesAutoresizingMaskIntoConstraints = false
        castImageView.contentMode = .scaleAspectFit // Adjust content mode as needed
        contentView.addSubview(castImageView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            castImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            castImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            castImageView.widthAnchor.constraint(equalToConstant: 60),
            castImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: castImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            characterLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            characterLabel.leadingAnchor.constraint(equalTo: castImageView.trailingAnchor, constant: 16),
            characterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            characterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with castMember: Cast) {
        nameLabel.text = castMember.name
        characterLabel.text = castMember.character
        
        if let profilePath = castMember.profilePath {
            let imageUrl = URL(string: "https://image.tmdb.org/t/p/w185/\(profilePath)")
            castImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder_image"))
        } else {
            castImageView.image = UIImage(named: "placeholder_image")
        }
    }
}
