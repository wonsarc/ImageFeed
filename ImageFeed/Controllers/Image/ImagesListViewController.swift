//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 08.10.2023.
//

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol? { get set }
    var photos: [Photo] { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showLoading(isLoading: Bool)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
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

    // MARK: - Properties
    var presenter: ImageListViewPresenterProtocol?
    var photos: [Photo] = []

    private let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

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
        configureActivityIndicator()
        configurePresenter()
        presenter?.fetchPhotos()
        presenter?.observeDataChanges()
    }

    // MARK: - Public Methods
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard oldCount != newCount else { return }
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { index in
                IndexPath(row: index, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }

    func showLoading(isLoading: Bool) {
        if isLoading {
            UIBlockingProgressHUD.animate()
        } else {
            UIBlockingProgressHUD.dismiss()
        }
    }

    // MARK: - Private Methods
    private func configurePresenter() {
        presenter = ImageListViewPresenter()
        presenter?.view = self
    }

    // MARK: - Activity Indicator Methods
    private func configureActivityIndicator() {
        tableView.tableFooterView = activityIndicatorView
    }

    private func startLoadingIndicator() {
        activityIndicatorView.startAnimating()
    }

    private func stopLoadingIndicator() {
        activityIndicatorView.stopAnimating()
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = photos[indexPath.row]
        let imageSize = CGSize(width: cell.size.width, height: cell.size.height)
        let aspectRatio = imageSize.width / imageSize.height
        return tableView.frame.width / aspectRatio
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didLikePhoto(at: indexPath.row) { success in
            if success {
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
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

        imageListCell.imageState = .loading
        imageListCell.delegate = self

        guard let presenter = presenter else { return UITableViewCell()}

        let photo = photos[indexPath.row]

        ImageLoader().loadImage(on: photo.thumbImageURL, completion: { result in
            switch result {
            case.success(let image):
                imageListCell.imageState = .finished(image)
            case .failure(let error):
                imageListCell.imageState = .error
                print("Ошибка при загрузке изображения: \(error)")
            }
        })

        let formatDate = presenter.formatDate(photo.createdAt)

        imageListCell.configureCell(
            date: formatDate,
            isLiked: photo.isLiked
        )

        return imageListCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        startLoadingIndicator()
        presenter?.willDisplayCell(at: indexPath, photosCount: photos.count)
        stopLoadingIndicator()
    }
}
