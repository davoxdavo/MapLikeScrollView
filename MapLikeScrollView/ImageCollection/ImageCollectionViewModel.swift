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
        let number = dummyNumberFrom(indexPath: indexPath)
        guard let url = URL(string: "https://picsum.photos/200/300?random=2\(number)") else {
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
    
        // This function is just trying to create as unique number as it possible from indexPath :) to help me unify the URL 
    private func dummyNumberFrom(indexPath: IndexPath) -> Int {
        let row = indexPath.row
        let section = indexPath.section
        let arg1 = row * row * row + 2
        let arg2 = section * (row.isMultiple(of: 2) ? 7 : 12) + 3
        let arg3 = (section > 0 ? 51 : -6) * (row > 1 ? 14 : 41 )
        let number = arg1 * arg2 + arg3
        
        return number
    }
}
