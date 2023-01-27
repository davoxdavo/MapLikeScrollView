//
//  ImageCollectionViewModel.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 27.01.23.
//

import UIKit

class ImageCollectionViewModel {
    typealias ImageCompletion = (UIImage?) -> Void

    private var completions = [IndexPath: ImageCompletion]()
    
    func getImage(for indexPath: IndexPath, completion: ImageCompletion?)  {
        guard let url = URL(string: "https://source.unsplash.com/random/150x150?sig=\(abs(indexPath.hashValue))") else {
            completion?(nil)
            return
        }
        completions[indexPath] = completion
        ImageCacheService.shared.getImage(for: url) { [weak self] data, source, error in
            guard let data, let image = UIImage(data: data), let completion = self?.completions[indexPath] else {
                if let error {
                    print(error.localizedDescription)
                }
                completion?(nil)
                return
            }
            completion(image)
            self?.completions[indexPath] = nil
        }
    }
}
