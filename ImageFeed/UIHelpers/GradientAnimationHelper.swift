//
//  GradientView.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 08.02.2024.
//

import UIKit

final class GradientAnimationHelper {

    // MARK: - Public Properties

    let animation: CABasicAnimation = {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        return gradientChangeAnimation
    }()

    // MARK: - Public Methods

    func addGradient(size: CGSize, cornerRadius: CGFloat, view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()

        gradient.frame =  CGRect(origin: .zero, size: size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        view.layer.addSublayer(gradient)

        return gradient
    }
}
