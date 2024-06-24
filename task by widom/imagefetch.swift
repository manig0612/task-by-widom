//
//  imagefetch.swift
//  task by wisdom
//
//  Created by Mani on 23/06/24.
//

import Foundation
import UIKit

class Imageloader {
    static let shared = Imageloader()
    private var imageCache = NSCache<NSURL, UIImage>()
    
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), error == nil else {
                completion(nil)
                return
            }
            self.imageCache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                completion(image)
            }
        }
        task.resume()
    }
}

class Imagecache {
    static let shared = Imagecache()
    private var cache = NSCache<NSURL, UIImage>()
    
    private init() {}
    
    func getimage(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func saveimage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Download image if not cached
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self, let data = data, let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                
                
                self.cache.setObject(image, forKey: urlString as NSString)
                
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            task.resume()
        } else {
            completion(nil)
        }
    }
}

class PendingOperations {
    lazy var downloadsInProgress: [Int: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Download Queue"
        queue.maxConcurrentOperationCount = 2 // Adjust as needed
        return queue
    }()
}
