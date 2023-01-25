//
//  ImageCollectionScrollView.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 25.01.23.
//

import UIKit


class ImageCollectionViewModel {
    
}

class ImageCollectionScrollView: UIView {
    private lazy var collection = MapLikeScrollView()
    private var viewModel = ImageCollectionViewModel()
    
    init() {
        super.init(frame: .zero)
        collection.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}


extension ImageCollectionScrollView: MapLikeScrollViewDataSource {
    func content(for indexPath: IndexPath) -> UIView {
        return UIView()
    }
}
