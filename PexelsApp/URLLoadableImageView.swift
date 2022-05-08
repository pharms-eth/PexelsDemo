//
//  URLLoadableImageView.swift
//  PexelsApp
//
//  Created by Daniel Bell on 4/30/22.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

class URLLoadableImageView: UIImageView {

    var imageUrlString: String?

    func loadImageUsing(lowUrl: String, highUrl: String) async {

        imageUrlString = highUrl

        guard let url = URL(string: highUrl) else { return }

        image = nil

        if let imageFromCache = imageCache.object(forKey: lowUrl as NSString) {
            image = imageFromCache
        } else if let imageFromCache = imageCache.object(forKey: highUrl as NSString) {
            image = imageFromCache
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            DispatchQueue.main.async {
                guard let imageToCache = UIImage(data: data) else { return }

                if self.imageUrlString == highUrl {
                    self.image = imageToCache
                }

                imageCache.setObject(imageToCache, forKey: highUrl as NSString)
            }
        } catch {

        }
    }

    func loadImageUsing(urlString: String) async {

        imageUrlString = urlString

        guard let url = URL(string: urlString) else { return }

        image = nil

        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            image = imageFromCache
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            DispatchQueue.main.async {
                guard let imageToCache = UIImage(data: data) else { return }

                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }

                imageCache.setObject(imageToCache, forKey: urlString as NSString)
            }
        } catch {

        }
    }

}
