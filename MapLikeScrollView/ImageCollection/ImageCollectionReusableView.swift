//
//  ImageCollectionReusableView.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 27.01.23.
//

import UIKit

class ImageCollectionReusableView: ReusableView {
    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    init() {
        defer {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
            addGestureRecognizer(gesture)
        }
        super.init(frame: .zero)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image = nil
    }
    
    @objc func tapHandler() {
        print(indexPath)
    }
}
