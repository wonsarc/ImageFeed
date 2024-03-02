//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 02.03.2024.
//

@testable import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImageListViewPresenterProtocol?
    var photos: [ImageFeed.Photo] = []
    var didCallUpdateTableViewAnimated = false
    var oldCountView: Int?
    var newCountView: Int?

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        didCallUpdateTableViewAnimated = true
        oldCountView = oldCount
        newCountView = newCount
    }
}
