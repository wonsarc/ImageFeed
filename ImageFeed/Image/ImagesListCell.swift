//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 11.10.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet private weak var cellView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    
    // MARK: - Private Properties
    private var isGradient: Bool = false
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Public Methods
    func configureCell(image: UIImage?, date: String, isLiked: Bool) {
        cellView.layer.cornerRadius = 16
        cellView.layer.masksToBounds = true
        cellView.image = image
        dateLabel.text = date
        let likedButtonImage = isLiked ? "Active" : "No Active"
        likeButton.setImage(UIImage(named: likedButtonImage), for: .normal)
    }
    
    // MARK: - Private Methods
    private func configGradientView() {
        gradientView.backgroundColor = .clear
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Override Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isGradient {
            configGradientView()
            isGradient = true
        }
    }
}
