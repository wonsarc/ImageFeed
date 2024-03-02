//
//  ImageListViewTests.swift
//  ImageFeedTests
//
//  Created by Artem Krasnov on 01.03.2024.
//

@testable import ImageFeed
import XCTest

final class ImageListViewTests: XCTestCase {
    private let photos = [Photo(
        id: "1",
        size: CGSize(width: 100, height: 100),
        createdAt: Date(),
        welcomeDescription: "Test",
        thumbImageURL: "url",
        largeImageURL: "url",
        isLiked: false
    )]

    func testFetchPhotos() {
        // given
        let presenter = ImageListViewPresenter()
        let imagesListService = ImagesListServiceSpy()
        presenter.imagesListService = imagesListService

        // when
        presenter.fetchPhotos()

        // then
        XCTAssertTrue(imagesListService.didFetchPhotosNextPage)
    }

    func testUpdateTableViewAnimated() {
        // given
        let oldCountPresenter = 1
        let newCountPresenter = 2
        let presenter = ImageListViewPresenter()
        let view = ImagesListViewControllerSpy()
        presenter.view = view

        // when
        presenter.updateTableViewAnimated(oldCount: oldCountPresenter, newCount: newCountPresenter)

        // then
        XCTAssertTrue(view.didCallUpdateTableViewAnimated)
        XCTAssertEqual(view.newCountView, newCountPresenter)
        XCTAssertEqual(view.oldCountView, oldCountPresenter)
    }

    func testObserveDataChanges() {
        // given
        let presenter = ImageListViewPresenter()
        let expectation = expectation(description: "Data change notification handled")

        // when
        presenter.observeDataChanges()

        // then
        let notificationName = ImagesListService.didChangeNotification
        let observer = NotificationCenter.default.addObserver(
            forName: notificationName,
            object: nil,
            queue: .main
        ) { _ in
            expectation.fulfill()
        }

        defer {
            NotificationCenter.default.removeObserver(observer)
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error = error {
                XCTFail("Failed to receive notification within timeout: \(error)")
            }
        }
    }

    func testDidLikePhoto() {
        // given
        let presenter = ImageListViewPresenter()
        let imagesListService = ImagesListServiceSpy()
        let view = ImagesListViewControllerSpy()

        view.photos = photos

        presenter.imagesListService = imagesListService
        presenter.view = view

        // when
        presenter.didLikePhoto(at: 0) { _ in }

        // then
        XCTAssertFalse(UIBlockingProgressHUD.isShowing, "Expected progress HUD to be dismissed")
        XCTAssertEqual(view.photos, imagesListService.photos, "Expected view's photos to be updated")
    }

    func testWillDisplayCell() {
        // given
        let fetchExpectation = expectation(description: "Fetch photos next page")
        let presenter = ImageListViewPresenter()
        let imagesListService = ImagesListServiceSpy()
        presenter.imagesListService = imagesListService

        // when
        presenter.willDisplayCell(at: IndexPath(row: 0, section: 0), photosCount: 1)

        // then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(imagesListService.didFetchPhotosNextPage)
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Timeout waiting for fetch photos: \(error)")
            }
        }
    }

    func testConfigurePhotoCell() {
        // given
        let presenter = ImageListViewPresenter()
        let imageLoader = ImageLoaderSpy()
        let view = ImagesListViewControllerSpy()
        let indexPath = IndexPath(row: 0, section: 0)

        presenter.imageLoader = imageLoader
        presenter.view = view

        view.photos = photos

        // when
        presenter.configurePhotoCell(at: indexPath) { response in

            // then
            XCTAssertEqual(response?.image, UIImage(named: "0"))
        }
    }
}
