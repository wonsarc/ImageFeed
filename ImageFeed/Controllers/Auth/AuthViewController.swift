//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 13.01.2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ viewController: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    // MARK: - Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?

    private lazy var loginButton: UIButton = {
        let loginButton = UIButton.systemButton(
            with: UIImage(),
            target: self,
            action: #selector(didTapLoginButton)
        )

        loginButton.accessibilityIdentifier = "Authenticate"
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = .ypWhite
        loginButton.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        loginButton.setTitleColor(.ypBlack, for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        loginButton.layer.cornerRadius = 16

        return loginButton
    }()

    private lazy var logoImageView: UIImageView = {
        let logoImage = UIImageView()
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        logoImage.image = UIImage(named: "LogoOfUnsplash")
        return logoImage
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewController = segue.destination as? WebViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }

            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewController
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - Private Func
    @objc private func didTapLoginButton() {
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: self)
    }
}

// MARK: - Extension
private extension AuthViewController {
    private func setupViews() {
        view.addSubview(loginButton)
        view.addSubview(logoImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewControllerDelegate {
    func webViewController(_ viewController: WebViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        dismiss(animated: true)
        UIBlockingProgressHUD.animate()
    }

    func webViewControllerDidCancel(_ viewController: WebViewController) {
        dismiss(animated: true)
    }
}
