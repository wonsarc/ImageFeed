//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 22.10.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet weak private var logoImageView: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var loginLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var logoutButton: UIButton!
    
    // MARK: - IB Action
    @IBAction private func didTapLogoutButton(_ sender: Any) {
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        lel()
    }
    
    private func lel() {
        nameLabel.text = "Екатерина Новикова"
        loginLabel.text = "@ekaterina_nov"
        descriptionLabel.text = "Hello, world!"
        logoImageView.layer.cornerRadius = 16
        logoImageView.image = UIImage(named: "profilePhoto")
    }
}
