//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 27.11.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - Public Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            photoSingleImageView.image = image
            rescaleAndCenterImageInScrollView(image: image ?? UIImage())
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
        present(UIActivityViewController(activityItems: [image as Any], applicationActivities: nil),
                animated: true)
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        photoSingleImageView.image = image
        rescaleAndCenterImageInScrollView(image: image ?? UIImage())
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
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        photoSingleImageView
    }
}
