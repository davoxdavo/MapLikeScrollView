//
//  ViewProvider.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 17.01.23.
//

import UIKit

struct ViewProvider {
    private var visibleViews: Set<ReusableView> = []
    private var viewPool = [ReusableView]()
    
    mutating
    func dequeueView() -> ReusableView {
        let view = getView()
        view.alpha = 1
        insert(view: view)
        return view
    }
    
    mutating
    private func insert(view: ReusableView) {
        visibleViews.insert(view)
    }
    
    mutating
    private func getView() -> ReusableView {
        if let view = viewPool.last {
            viewPool.removeLast()
            view.prepareForReuse()
            return view
        }
        return ReusableView()
    }
    
    // MARK: - REMOVERS
    
    mutating
    func remove(view: ReusableView) {
        viewPool.append(view)
        visibleViews.remove(view)
    }
    
    mutating
    func removeAll() {
        visibleViews.removeAll()
        viewPool.removeAll()
    }
}
