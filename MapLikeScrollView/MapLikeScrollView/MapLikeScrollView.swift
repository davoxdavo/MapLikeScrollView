//
//  MapLikeScrollView.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 15.01.23.
//

import UIKit
import SwiftUI

protocol MapLikeScrollViewDataSource: AnyObject {
    func content(for indexPath: IndexPath) -> UIView
}

class MapLikeScrollView: UIView {
    private var viewProvider = ViewProvider()
    private var layoutStructure = ViewLayoutStructure(itemSize: 200)
    
    weak var dataSource: MapLikeScrollViewDataSource?
    private var itemInsetClosure: ((CGRect) -> ReusableView?)?
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Gesture Recognizer

    private func addGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panDidMove(_ :)))
        addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_ :)))
        addGestureRecognizer(pinchGesture)
    }
    
    @objc private func panDidMove(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let direction = ScrollDirection(point: translation)
        layoutStructure.onScroll(translation: translation)
        newRegion(for: direction)
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
        guard sender.scale != 0 else { return }
        layoutStructure.onPinch(scale: sender.scale)
        sender.scale = 1
    }
 
    func reload() {
        itemInsetClosure = { [weak self] frame in
            guard let self = self else { return nil }
            let view = self.getView(frame: frame)
            return view
        }
        layoutStructure.reload()
        viewProvider.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        initialLoad()
    }
    
    private func initialLoad() {
        layoutStructure.initialLoad(height: bounds.height, width: bounds.width) { [weak self] frame in
            guard let self = self else { return nil }
            let view = self.getView(frame: frame)
            return view
        }
    }

    @discardableResult
    private func getView(frame: CGRect) -> ReusableView {
        let view = viewProvider.dequeueView()
        view.prepareForReuse()
        view.frame = frame
        let indexPath = layoutStructure.frameToIndexPath(frame)
        if let content = dataSource?.content(for: indexPath) {
            view.addSubview(content)
            content.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            content.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        addSubview(view)
        return view
    }
    
    private func newRegion(for direction: ScrollDirection) {
        switch direction {
        case .up:
            let views = layoutStructure.insertRowUp { [weak self] frame in
                guard let self = self else { return nil }
                let view = self.getView(frame: frame)
                return view
            }
            remove(views: views)
        case .down:
            let views = layoutStructure.insertRowDown { [weak self] frame in
                guard let self = self else { return nil }
                let view = self.getView(frame: frame)
                return view
            }
            remove(views: views)
        case .left:
            let views = layoutStructure.insertRowLeft { [weak self] frame in
                guard let self = self else { return nil }
                let view = self.getView(frame: frame)
                return view
            }
            remove(views: views)
        case .right:
            let views = layoutStructure.insertRowRight { [weak self] frame in
                guard let self = self else { return nil }
                let view = self.getView(frame: frame)
                return view
            }
            remove(views: views)
        case .upLeft:
            newRegion(for: .up)
            newRegion(for: .left)
        case .upRight:
            newRegion(for: .up)
            newRegion(for: .right)
        case .downLeft:
            newRegion(for: .down)
            newRegion(for: .left)
        case .downRight:
            newRegion(for: .down)
            newRegion(for: .right)
        }
    }
    
    private func remove(views: [ReusableView]) {
        views.forEach {
            viewProvider.remove(view: $0)
            $0.removeFromSuperview()
        }
    }
}

struct MapLikeScrollSwiftUIView: UIViewRepresentable {
    func makeUIView(context: Context) -> MapLikeScrollView {
        MapLikeScrollView()
    }
    
    func updateUIView(_ uiView: MapLikeScrollView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            uiView.reload()
        }
    }
}
