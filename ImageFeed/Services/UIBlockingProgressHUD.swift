//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 24.01.2024.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    static func animate() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate("Please wait...", .ballVerticalBounce)
    }

    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
