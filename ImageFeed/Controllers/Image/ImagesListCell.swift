//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 11.10.2023.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    // MARK: - IB Outlets
    @IBOutlet private weak var cellView: UIImageView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!

    // MARK: - Public Properties
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    var animationLayers = Set<CALayer>()
    var imageState: FeedCellImageStateEnum = .loading {
        didSet {
            switch imageState {
            case .loading:
                animationLayers.insert(gradientLayer)
            case .error:
                print("error")
            case .finished(let image):
                cellView.image = image
                animationLayers.forEach { $0.removeFromSuperlayer() }
                animationLayers.removeAll()
            }
        }
    }

    // MARK: - Private Properties
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    private var gradientAnimationHelper = GradientAnimationHelper()

    // MARK: - Overrides Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds

        if !animationLayers.isEmpty {
            let animation = gradientAnimationHelper.animation
            let cellViewGradient = gradientAnimationHelper.addGradient(
                size: cellView.bounds.size,
                cornerRadius: 16,
                view: cellView
            )
            cellViewGradient.add(animation, forKey: "locationsChange")
            animationLayers.insert(cellViewGradient)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellView.image = nil // сброс изображенияя ячейки перед повторным использованием
    }

    // MARK: - IB Actions
    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }

    // MARK: - Public Methods
    func configureCell(date: String, isLiked: Bool) {
        cellView.layer.cornerRadius = 16
        cellView.layer.masksToBounds = true
        dateLabel.text = date
        setIsLiked(isLiked)
        configGradientView()
    }

    func setIsLiked(_ isLiked: Bool) {
        let likedButtonImage = isLiked ? "Active" : "No Active"
        likeButton.setImage(UIImage(named: likedButtonImage), for: .normal)
    }

    // MARK: - Private Methods
    private func configGradientView() {
        gradientView.backgroundColor = .clear

        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}
