//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 27.11.2023.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    // MARK: - Public Properties
    var imageURL: String? {
        didSet {
            uploadImage()
        }
    }

    // MARK: - IB Outlets
    @IBOutlet private weak var photoSingleImageView: UIImageView!

    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private weak var sharedButton: UIButton!

    // MARK: - IB Action
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapShareButton(_ sender: Any) {
        present(UIActivityViewController(
            activityItems: [photoSingleImageView.image as Any],
            applicationActivities: nil
        ), animated: true)
    }

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        uploadImage()
    }

    // MARK: - Private func
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let sideX = (newContentSize.width - visibleRectSize.width) / 2
        let sideY = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: sideX, y: sideY), animated: false)
    }

    private func uploadImage() {
        guard isViewLoaded else { return }
        guard let imageURL = imageURL else { return }
        UIBlockingProgressHUD.animate()
        photoSingleImageView.kf.indicatorType = .activity
        photoSingleImageView.kf.setImage(
            with: URL(string: imageURL)
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                UIBlockingProgressHUD.dismiss()
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        photoSingleImageView
    }
}
