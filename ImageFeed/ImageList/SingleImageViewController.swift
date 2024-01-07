//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 27.11.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // MARK: - Public Properties
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            photoSingleImageView.image = image
        }
    }
    
    // MARK: - IB Outlets
    @IBOutlet private weak var photoSingleImageView: UIImageView!
    
    // MARK: - IB Action
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoSingleImageView.image = image
    }
}
