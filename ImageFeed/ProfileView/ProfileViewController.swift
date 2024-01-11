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
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Private Properties
    private lazy var logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.layer.cornerRadius = 16
        logoImageView.image = UIImage(named: "profilePhoto")
        return logoImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = .boldSystemFont(ofSize: 23)
        return nameLabel
    }()
    
    private lazy var loginLabel: UILabel = {
        let loginLabel = UILabel()
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.text = "@ekaterina_nov"
        loginLabel.textColor = .ypGray
        loginLabel.font = .systemFont(ofSize: 13)
        return loginLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = .systemFont(ofSize: 13)
        return descriptionLabel
    }()
    
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "LogOut") ?? UIImage(),
            target: self,
            action: #selector(didTapLogoutButton)
        )
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.tintColor = .ypRed
        return logoutButton
    }()
    
    // MARK: - Private Func
    private func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 70),
            logoImageView.heightAnchor.constraint(equalToConstant: 70),
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
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
