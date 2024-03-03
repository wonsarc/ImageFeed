//
//  WebViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 13.01.2024.
//

import UIKit
import WebKit

protocol WebViewControllerDelegate: AnyObject {
    func webViewController(_ viewController: WebViewController, didAuthenticateWithCode code: String)
    func webViewControllerDidCancel(_ viewController: WebViewController)
}

protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewController: UIViewController, WebViewControllerProtocol {
    private var estimatedProgressObservation: NSKeyValueObservation?

    // MARK: - Properties
    weak var delegate: WebViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?

    // MARK: - Private Properties
    private lazy var wkWebView: WKWebView = {
        let webView = WKWebView()
        webView.accessibilityIdentifier = "UnsplashWebView"
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
        presenter?.didUpdateProgressValue(0)
        presenter?.viewDidLoad()
        createObserveEstimatedProgress()
    }

    // MARK: - Func
    static func cleanCookie() {
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
          records.forEach { record in
             WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
          }
       }
    }

    func load(request: URLRequest) {
        wkWebView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        uiProgressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        uiProgressView.isHidden = isHidden
    }

    // MARK: - Private Func
    @objc private func didTapBackButton() {
        delegate?.webViewControllerDidCancel(self)
    }
}

// MARK: - Extension
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            delegate?.webViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}

// MARK: - Private extension
private extension WebViewController {
    func setupViews() {
        view.addSubview(wkWebView)
        view.addSubview(backwardButton)
        view.addSubview(uiProgressView)
    }

   private func setupConstraints() {
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
                 presenter?.didUpdateProgressValue(wkWebView.estimatedProgress)
             })
    }
}
