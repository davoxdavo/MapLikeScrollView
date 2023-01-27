//
//  ViewProvider.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 17.01.23.
//

import UIKit

struct ViewProvider<T: IReusableView> {
    private var visibleViews: Set<T> = []
    private var viewPool = [T]()
    var poolCapacity = 100
    
    mutating
    func dequeueView() -> T {
        let view = getView()
        insert(view: view)
        return view
    }
    
    mutating
    private func insert(view: T) {
        visibleViews.insert(view)
    }
    
    mutating
    private func getView() -> T {
        if let view = viewPool.last {
            viewPool.removeLast()
            view.prepareForReuse()
            return view
        }
        return T()
    }
    
    // MARK: - REMOVERS
    
    mutating
    func remove(view: T) {
        if viewPool.count < poolCapacity {
            viewPool.append(view)
        }
        visibleViews.remove(view)
    }
    
    mutating
    func removeAll() {
        visibleViews.removeAll()
        viewPool.removeAll()
    }
}
