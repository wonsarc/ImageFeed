//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 08.10.2023.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UINib(nibName: ImagesListCell.reuseIdentifier, bundle: nil),
                               forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
    }

    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []

    // MARK: - View Life Cycles
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController else {return}
            guard let indexPath = sender as? IndexPath else {return}
            viewController.imageURL = photos[indexPath.row].largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imagesListService.fetchPhotosNextPage()
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else {return}
                self.updateTableViewAnimated()
            }
    }

    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]

        UIBlockingProgressHUD.animate()

        imagesListService.changeLike(
            photoId: photo.id,
            isLike: photo.isLiked) { result in
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                case.failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print(error)
                }
            }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        var imageView = UIImageView()
        let photo = photos[indexPath.row]
        imageListCell.imageState = .loading(CGSize(width: photo.size.width, height: photo.size.height))
        let imageURL = URL(string: photo.thumbImageURL)

        DispatchQueue.main.async {
            imageView.kf.setImage(with: imageURL, completionHandler: { result in
                switch result {
                case .success(let download):
                    imageListCell.imageState = .finished(download.image)
                case .failure:
                    imageListCell.imageState = .error
                }
            })
        }

        let date: String = {
            let date = photo.createdAt
            if let date = date {
                return dateFormatter.string(from: date)
            } else {
                return ""
            }
    }()
        imageListCell.configureCell(
            date: date,
            isLiked: photo.isLiked
        )

        return imageListCell
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}
