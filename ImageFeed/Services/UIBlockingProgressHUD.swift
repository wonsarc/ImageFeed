//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 24.01.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    static var isShowing: Bool = false
    private static var window: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            return nil
        }
        return window
    }

    static func animate() {
        isShowing = true
        window?.isUserInteractionEnabled = false
        ProgressHUD.colorAnimation = .ypBlack
        ProgressHUD.animate(nil, .activityIndicator)
    }

    static func dismiss() {
        isShowing = false
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
