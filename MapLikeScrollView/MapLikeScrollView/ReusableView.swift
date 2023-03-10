//
//  ReusableView.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 25.01.23.
//

import UIKit

protocol IReusableView: UIView {
    func prepareForReuse()
    var indexPath: IndexPath? { get set }
}

extension IReusableView {
    func prepareForReuse() {}
}

class ReusableView: UIView, IReusableView {
    var indexPath: IndexPath?
}

class DebugReusableView: ReusableView {
    weak var label: UILabel?
    
    init() {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        self.label = label
        super.init(frame: .zero)
        addSubview(label)
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 80).isActive = true
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        backgroundColor = UIColor.random()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func prepareForReuse() {
        prepareForReuse()
        label?.text = "x: \(frame.origin.x)\ny: \(frame.origin.y)"
    }
}
