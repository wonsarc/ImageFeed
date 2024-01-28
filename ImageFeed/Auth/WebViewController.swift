//
//  WebViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 13.01.2024.
//

import UIKit
import WebKit

private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
private var estimatedProgressObservation: NSKeyValueObservation?

protocol WebViewControllerDelegate: AnyObject {
    func webViewController(_ viewController: WebViewController, didAuthenticateWithCode code: String)
    func webViewControllerDidCancel(_ viewController: WebViewController)
}

final class WebViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: WebViewControllerDelegate?

    // MARK: - Private Properties
    private lazy var wkWebView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .ypWhite
        return webView
    }()

    private lazy var backwardButton: UIButton = {
        let backwardButton = UIButton.systemButton(
            with: UIImage(named: "BackwardBlack") ?? UIImage(),
            target: self,
            action: #selector(didTapBackButton)
        )
        backwardButton.translatesAutoresizingMaskIntoConstraints = false
        backwardButton.tintColor = .ypBlack
        return backwardButton
    }()

    private lazy var uiProgressView: UIProgressView = {
        let uiProgressView = UIProgressView()
        uiProgressView.translatesAutoresizingMaskIntoConstraints = false
        uiProgressView.progressTintColor = .ypBlack
        uiProgressView.progressViewStyle = .bar
        return uiProgressView
    }()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
        wkWebView.navigationDelegate = self
        loadWebView()
        createObserveEstimatedProgress()
    }

    // MARK: - Private Func
    @objc private func didTapBackButton() {
        delegate?.webViewControllerDidCancel(self)
    }

    private func updateProgress() {
        uiProgressView.progress = Float(wkWebView.estimatedProgress)
        uiProgressView.isHidden = fabs(wkWebView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - Extension
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = fetchCode(url: navigationAction.request.url) {
            delegate?.webViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func fetchCode(url: URL?) -> String? {
        guard let url = url,
              let components = URLComponents(string: url.absoluteString),
              components.path == "/oauth/authorize/native",
              let codeItem = components.queryItems?.first(where: { $0.name == "code" }) else {return nil}
        return codeItem.value
    }
}

// MARK: - Private extension
private extension WebViewController {
    func loadWebView() {
        var urlComponents = URLComponents(string: unsplashAuthorizeURLString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        if let url = urlComponents?.url {
            let request = URLRequest(url: url)
            wkWebView.load(request)
        }
    }

    func setupViews() {
        view.addSubview(wkWebView)
        view.addSubview(backwardButton)
        view.addSubview(uiProgressView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            wkWebView.topAnchor.constraint(equalTo: view.topAnchor),
            wkWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wkWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wkWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            backwardButton.heightAnchor.constraint(equalToConstant: 48),
            backwardButton.widthAnchor.constraint(equalToConstant: 48),
            backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 13),
            backwardButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            uiProgressView.topAnchor.constraint(equalTo: backwardButton.bottomAnchor),
            uiProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            uiProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func createObserveEstimatedProgress() {
        estimatedProgressObservation = wkWebView.observe(
            \.estimatedProgress,
            options: [],
             changeHandler: {[weak self] _, _ in
                 guard let self = self else {return}
                 self.updateProgress()
             })
    }
}
