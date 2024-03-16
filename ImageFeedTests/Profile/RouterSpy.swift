//
//  RouterSpy.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 05.03.2024.
//

@testable import ImageFeed
import Foundation

final class RouterSpy: ProfileViewRouterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    var didCallLogout = false

    func logout() {
        didCallLogout = true
    }
}
