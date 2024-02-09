//
//  FeedCellImageStateEnum.swift
//  ImageFeed
//
//  Created by Artem Krasnov on 08.02.2024.
//

import UIKit

enum FeedCellImageStateEnum {
    case loading(CGSize?)
    case error
    case finished(UIImage)
}
