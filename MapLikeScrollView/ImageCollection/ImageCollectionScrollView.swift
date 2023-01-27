//
//  ImageCollectionScrollView.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 25.01.23.
//

import UIKit
import SwiftUI

class ImageCollectionScrollView: UIView {
    typealias T = ImageCollectionReusableView
    
    private lazy var collection = MapLikeScrollView<T>()
    private var viewModel = ImageCollectionViewModel()
    
    init() {
        super.init(frame: .zero)
        collection.dataSource = self
        addSubview(collection)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collection.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collection.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collection.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func reload() {
        collection.reload()
    }
    
}

extension ImageCollectionScrollView: MapLikeScrollViewDataSource {
    func reuseView(for indexPath: IndexPath, view: IReusableView) {
        if let view = view as? T {
            viewModel.getImage(for: indexPath) { image in
                view.image = image
            }
        }
    }
}


struct ImageCollectionScrollViewSwiftUIWrapper: UIViewRepresentable {
    func makeUIView(context: Context) -> ImageCollectionScrollView {
        ImageCollectionScrollView()
    }
    
    func updateUIView(_ uiView: ImageCollectionScrollView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            uiView.reload()
        }
    }
}
