//
//  PhotoViewerViewController.swift
//  MessengerApp
//
//  Created by 김광준 on 2021/06/11.
//

import UIKit
import SDWebImage

/*
 Descussion:
 I can download image from firebase storage used url.
 And SDWebImage framework is help to donwload image used by the url.
 Also I have another option to download image that pass in the bytes,
 Because technically I already download it on the other screen.
 So, it's kind of redundant
 */

class PhotoViewerViewController: UIViewController {
    
    private let url: URL
        
    // added own initializer
    // c.f : initializer have parameter the 'URL', because I want to pass in a URL to show the image from
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .clear
        view.addSubview(imageView)
        imageView.sd_setImage(with: self.url, completed: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
        
    }
    
}
