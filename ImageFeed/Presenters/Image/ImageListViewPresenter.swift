//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 27.02.2024.
//

import UIKit
import Kingfisher

protocol ImageListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? {get set}
    var imagesListService: ImagesListService {get set}

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
    var imagesListService = ImagesListService()

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
        guard let imageURL = URL(string: photo.thumbImageURL) else {
            completion(nil)
            return
        }

        let date = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""

        loadImage(from: imageURL) { image in
            guard let image = image else {
                print("Не удалось загрузить изображение.")
                completion(nil)
                return
            }

            let photoCellViewModel = PhotoCellViewModel(image: image, date: date, isLiked: photo.isLiked)
            completion(photoCellViewModel)
        }
    }

    func willDisplayCell(at indexPath: IndexPath, photosCount: Int) {
        if indexPath.row + 1 == photosCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.fetchPhotos()
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

    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let options: KingfisherOptionsInfo = [.cacheMemoryOnly, .transition(.fade(0.2))]

        KingfisherManager.shared.retrieveImage(with: url, options: options) { result in
            switch result {
            case .success(let imageResult):
                completion(imageResult.image)
            case .failure(let error):
                print("Ошибка при загрузке изображения: \(error)")
                completion(nil)
            }
        }
    }
}
