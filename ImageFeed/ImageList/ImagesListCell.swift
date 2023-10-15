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
    @IBOutlet weak var gradientView: UIView!
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Private Properties
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Public Methods
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.gradientView.backgroundColor = .clear
        cell.cellView.layer.cornerRadius = 16
        cell.cellView.layer.masksToBounds = true
        if let photoImage: UIImage = UIImage(named: ImagesListViewController().photosName[indexPath.row]) {
            cell.cellView.image = photoImage
            cell.dateLabel.text = dateFormatter.string(from: Date())
            
        } else {return}
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.setImage(UIImage(named: "Active"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "No Active"), for: .normal)
        }
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    // MARK: - Private Methods
    private func configGradientView(gradientView: UIView) {
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientView.backgroundColor = .clear
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
