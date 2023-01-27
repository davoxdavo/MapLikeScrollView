//
//  ImageCacheService.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 27.01.23.
//

import Foundation

class ImageCacheService {
    enum ImageCacheError: Error {
        case wrongURL
        case networkError(Error?)
    }

    enum DataSource {
        case all
        case memory
        case storage
        case network
    }
    
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSURL, NSData>()
    private let queue = DispatchQueue.global(qos: .userInitiated)
    private let storage = StorageService()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 150 * 1024 * 1024
    }
    // MARK: - Public
    
    func getImage(for url: URL, completion: @escaping (Data?, DataSource, ImageCacheError?) -> ()) {
        guard let nsURL = NSURL(string: url.absoluteString) else {
            completion(nil, .all, .wrongURL)
            return
        }
        if let data = cache.object(forKey: nsURL) {
            completion(Data(data), .memory, nil)
            return
        }
    
        let data: Data? = storage.getModelFor(key: url.absoluteString)
            
        if let data {
            completion(data, .storage, nil)
            if let nsURL = NSURL(string: url.absoluteString) {
                cache.setObject(NSData(data: data), forKey: nsURL)
            }
            return
        }
        
        loadImage(url: url) { data, error in
            if let data {
                completion(data, .network, nil)
                self.storage.saveModelFor(key: url.absoluteString, model: data)
                if let nsURL = NSURL(string: url.absoluteString) {
                    self.cache.setObject(NSData(data: data), forKey: nsURL)
                }
            } else {
                completion(nil, .network, .networkError(error))
            }
        }
    }
    
    // MARK: - Image Loading
    
    private func loadImage(url: URL, completion: @escaping (Data?, Error?) -> ()) {
        queue.async {
            do {
               let data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    completion(data, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
    }
}
