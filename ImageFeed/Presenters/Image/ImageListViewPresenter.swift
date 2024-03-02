//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 27.02.2024.
//

import UIKit
import Kingfisher

enum PhotoError: Error {
    case invalidURL
}

protocol ImageListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesListService: ImagesListServiceProtocol { get set }
    var imageLoader: ImageLoaderProtocol { get set }

    func fetchPhotos()
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func observeDataChanges()
    func didLikePhoto(at index: Int, completion: @escaping (Bool) -> Void)
    func willDisplayCell(at indexPath: IndexPath, photosCount: Int)
    func configurePhotoCell(at indexPath: IndexPath, completion: @escaping (PhotoCellViewModel?) -> Void)
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    // MARK: - Properties
    weak var view: ImagesListViewControllerProtocol?
    var imagesListService: ImagesListServiceProtocol = ImagesListService()
    var imageLoader: ImageLoaderProtocol = ImageLoader()
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

    func observeDataChanges() {
        NotificationCenter.default.addObserver(
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
        UIBlockingProgressHUD.animate()
        guard let photo = view?.photos[index] else {return}

        imagesListService.changeLike(
            photoId: photo.id,
            isLike: photo.isLiked) { result in
                switch result {
                case .success:
                    self.view?.photos = self.imagesListService.photos
                    UIBlockingProgressHUD.dismiss()
                    completion(true)
                case.failure:
                    UIBlockingProgressHUD.dismiss()
                    completion(false)
                }
            }
    }

    func configurePhotoCell(at indexPath: IndexPath, completion: @escaping (PhotoCellViewModel?) -> Void) {
        guard let photo = view?.photos[indexPath.row] else {
            completion(nil)
            return
        }
        imageLoader.loadImage(for: photo) { result in
            switch result {
            case .success(let image):
                let date = self.dateFormatter.string(from: photo.createdAt ?? Date())
                let photoCellViewModel = self.createPhotoCellViewModel(image: image, date: date, isLiked: photo.isLiked)
                completion(photoCellViewModel)
            case .failure(let error):
                print("Failed to load image:", error)
                completion(nil)
            }
        }
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

    private func formatDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }

    private func createPhotoCellViewModel(image: UIImage, date: String, isLiked: Bool) -> PhotoCellViewModel {
        return PhotoCellViewModel(image: image, date: date, isLiked: isLiked)
    }
}
