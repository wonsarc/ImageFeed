//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 22.10.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        let logoImageView = addLogoImageView(name: "profilePhoto")
        let nameLabel = addNameLabel(text: "Екатерина Новикова")
        let loginLabel = addLoginLabel(text: "@ekaterina_nov")
        let logoutButton = addLogoutButton()
        let descriptionLabel = addDescriptionLabel(text: "Hello, world!")
        
        setConstraints(
            logoImageView: logoImageView,
            nameLabel: nameLabel,
            loginLabel: loginLabel,
            descriptionLabel: descriptionLabel,
            logoutButton: logoutButton
        )
    }
    
    // MARK: - Private Func
    private func addLogoImageView(name: String) -> UIImageView {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.layer.cornerRadius = 16
        logoImageView.image = UIImage(named: name)
        view.addSubview(logoImageView)
        return logoImageView
    }
    
    private func addNameLabel(text: String) -> UILabel {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = text
        nameLabel.textColor = .ypWhite
        nameLabel.font = .boldSystemFont(ofSize: 23)
        view.addSubview(nameLabel)
        return nameLabel
    }
    
    private func addLoginLabel(text: String) -> UILabel {
        let loginLabel = UILabel()
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.text = text
        loginLabel.textColor = .ypGray
        loginLabel.font = .systemFont(ofSize: 13)
        view.addSubview(loginLabel)
        return loginLabel
    }
    
    private func addDescriptionLabel(text: String) -> UILabel {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = text
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = .systemFont(ofSize: 13)
        view.addSubview(descriptionLabel)
        return descriptionLabel
    }
    
    private func addLogoutButton() -> UIButton {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(),
            target: self,
            action: #selector(didTapLogoutButton)
        )
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = .ypRed
        view.addSubview(logoutButton)
        return logoutButton
    }
    
    private func setConstraints(
        logoImageView: UIImageView,
        nameLabel: UILabel,
        loginLabel: UILabel,
        descriptionLabel: UILabel,
        logoutButton: UIButton
    ) {
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 70),
            logoImageView.heightAnchor.constraint(equalToConstant: 70),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 52),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 48),
            logoutButton.heightAnchor.constraint(equalToConstant: 48),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            logoutButton.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor),
            
            nameLabel.widthAnchor.constraint(equalToConstant: 700),
            nameLabel.heightAnchor.constraint(equalToConstant: 18),
            nameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            loginLabel.widthAnchor.constraint(equalToConstant: 400),
            loginLabel.heightAnchor.constraint(equalToConstant: 18),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionLabel.widthAnchor.constraint(equalToConstant: 400),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 18),
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    @objc
    private func didTapLogoutButton() {
    }
}
