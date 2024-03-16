//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 27.02.2024.
//

import Foundation
import Kingfisher

enum PhotoError: Error {
    case invalidURL
}

protocol ImageListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesListService: ImagesListServiceProtocol { get set }

    func fetchPhotos()
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func observeDataChanges()
    func didLikePhoto(at index: Int, completion: @escaping (Bool) -> Void)
    func willDisplayCell(at indexPath: IndexPath, photosCount: Int)
    func formatDate(_ date: Date?) -> String
    func downloadImagePhoto(_ photoImageURL: String, completion: @escaping ResultImageError)
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {

    // MARK: - Public Properties

    weak var view: ImagesListViewControllerProtocol?
    var profileImageListViewObserver: NSObjectProtocol?
    var imagesListService: ImagesListServiceProtocol = ImagesListService()

    // MARK: - Private Properties

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    // MARK: - Initializers

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public Methods

    func fetchPhotos() {
        imagesListService.fetchPhotosNextPage()
    }

    func downloadImagePhoto(_ photoImageURL: String, completion: @escaping ResultImageError) {
        ImageDownloadService().downloadImage(on: photoImageURL, completion: completion)
    }

    func observeDataChanges() {
        profileImageListViewObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) {_ in
                self.handleDataChangeNotification()
            }
    }

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }

    func didLikePhoto(at index: Int, completion: @escaping (Bool) -> Void) {
        view?.showLoading(isLoading: true)
        guard let photo = view?.photos[index] else {return}

        imagesListService.changeLike(
            photoId: photo.id,
            isLike: photo.isLiked) { result in
                switch result {
                case .success:
                    self.view?.photos = self.imagesListService.photos
                    self.view?.showLoading(isLoading: false)
                    completion(true)
                case.failure:
                    self.view?.showLoading(isLoading: false)
                    completion(false)
                }
            }
    }

    func formatDate(_ date: Date?) -> String {
       guard let date = date else { return "" }
       return dateFormatter.string(from: date)
   }

    func willDisplayCell(at indexPath: IndexPath, photosCount: Int) {
        if indexPath.row + 1 == photosCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.fetchPhotos()
            }
        }
    }

    // MARK: - Private Methods

    private func handleDataChangeNotification() {
        let oldCount = view?.photos.count
        let newCount = imagesListService.photos.count
        view?.photos = imagesListService.photos
        updateTableViewAnimated(oldCount: oldCount ?? 0, newCount: newCount)
    }
}
