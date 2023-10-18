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
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Public Methods
    func configureCell(image: UIImage?, date: String, isLiked: Bool) {
       gradientView.backgroundColor = .clear
       cellView.layer.cornerRadius = 16
       cellView.layer.masksToBounds = true
       
       cellView.image = image
       dateLabel.text = date
       let likedButtonImage = isLiked ? "Active" : "No Active"
       likeButton.setImage(UIImage(named: likedButtonImage), for: .normal)
   }
    
    
    // MARK: - Private Methods
    func configGradientView() {
        gradientView.backgroundColor = .clear
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor
        ]
        //        gradientLayer.startPoint = CGPointMake(0.5, 0.0)
        //        gradientLayer.endPoint = CGPointMake(0.5, 1.0)
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
    }
}
