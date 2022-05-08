//
//  FullScreenImage.swift
//  PexelsApp
//
//  Created by Daniel Bell on 4/28/22.
//

import Foundation
import UIKit

class FullScreenImage: UIViewController, UIScrollViewDelegate {
    var imageView: URLLoadableImageView
    var scrollView: UIScrollView!

    var largeURL: String
    var lowURL: String?


    init(url: String, lowURL: String?) {
        imageView = URLLoadableImageView()
        largeURL = url
        self.lowURL = lowURL
        super.init(nibName: nil, bundle: nil)
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        scrollView.backgroundColor = .systemTeal
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Set the contentSize to 100 times the height of the phone's screen so that
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: UIScreen.main.bounds.height*100)
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 4.0
//        view = imageView

        imageView.contentMode = .scaleAspectFit
        view.backgroundColor = .tertiarySystemBackground
        imageView.backgroundColor = .secondarySystemBackground
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(imageView)

        let g = scrollView.contentLayoutGuide

        imageView.topAnchor.constraint(equalTo: g.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: g.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: g.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: g.trailingAnchor).isActive = true
        loadImage()
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
    func loadImage() {
        Task {
            if let lowURL = lowURL {
                await imageView.loadImageUsing(lowUrl: lowURL, highUrl: largeURL)
            } else {
                await imageView.loadImageUsing(urlString: largeURL)
            }
            imageView.widthAnchor.constraint(equalToConstant: imageView.image?.size.width ?? 0).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: imageView.image?.size.height ?? 0).isActive = true
        }
    }
    //TODO: ZOOM
    //TODO: Image gestures
    init() {
        imageView = URLLoadableImageView()
        largeURL = ""
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
