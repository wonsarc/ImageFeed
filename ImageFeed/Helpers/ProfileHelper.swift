//
//  ProfileHelper.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 26.02.2024.
//

import Foundation

protocol ProfileHelperProtocol {
    func setupGradientAnimation(view: ProfileViewControllerProtocol)
}

final class ProfileHelper: ProfileHelperProtocol {
    func setupGradientAnimation(view: ProfileViewControllerProtocol) {
        let gradientAnimationHelper = GradientAnimationHelper()
        let animation = gradientAnimationHelper.animation

        let logoImageViewGradient = gradientAnimationHelper.addGradient(
            size: CGSize(width: 70, height: 70),
            cornerRadius: 35,
            view: view.logoImageView
        )
        logoImageViewGradient.add(animation, forKey: "locationsChange")
        view.animationLayers.insert(logoImageViewGradient)

        let nameLabelGradient = gradientAnimationHelper.addGradient(
            size: CGSize(width: 250, height: 18),
            cornerRadius: 10,
            view: view.nameLabel
        )
        nameLabelGradient.add(animation, forKey: "locationsChange")
        view.animationLayers.insert(nameLabelGradient)

        let loginLabelGradient = gradientAnimationHelper.addGradient(
            size: CGSize(width: 200, height: 18),
            cornerRadius: 10,
            view: view.loginLabel
        )
        loginLabelGradient.add(animation, forKey: "locationsChange")
        view.animationLayers.insert(loginLabelGradient)

        let descriptionLabelGradient = gradientAnimationHelper.addGradient(
            size: CGSize(width: 150, height: 18),
            cornerRadius: 10,
            view: view.descriptionLabel
        )
        descriptionLabelGradient.add(animation, forKey: "locationsChange")
        view.animationLayers.insert(descriptionLabelGradient)
    }
}
