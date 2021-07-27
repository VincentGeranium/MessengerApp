//
//  Media.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/07/26.
//

import Foundation
import MessageKit

// c.f : Media is conform to the MediaItem protocol
struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
