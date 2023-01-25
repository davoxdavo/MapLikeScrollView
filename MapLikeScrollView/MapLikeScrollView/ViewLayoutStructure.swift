//
//  ViewLayoutStructure.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 19.01.23.
//

import UIKit

class ViewLayoutStructure {
    private var maxX: CGFloat = 0
    private var maxY: CGFloat = 0
    private var minX: CGFloat = 0
    private var minY: CGFloat = 0
    
    private var isInsertingUp = false
    private var isInsertingDown = false
    private var isInsertingLeft = false
    private var isInsertingRight = false
    
    // indicates amount of rows and cols rendered out of frame
    private var numberOfExtraItems = 2
    private var itemSize: CGFloat
    private var containerSize: CGSize = .zero
    
    private var views = [[ReusableView]]()
    
    init(itemSize: CGFloat) {
        self.itemSize = itemSize
    }
    
    func reload() {
        maxX = 0
        maxY = 0
        minX = 0
        minY = 0
        views.removeAll()
    }
    
    // MARK: - Gesture handlers
    
    func onScroll(translation: CGPoint) {
        let newX = CGFloat(Int(translation.x * 10000)/10000)
        let newY = CGFloat(Int(translation.y * 10000)/10000)
        
        for row in views {
            for item in row {
                let newCenter = CGPoint(x: item.center.x + newX, y: item.center.y + newY)
                item.center = newCenter
            }
        }
        updateMinMaxPoints()
        
        for row in views {
            for item in row {
                item.prepareForReuse()
            }
        }
    }
    
    func initialLoad(height: CGFloat, width: CGFloat, itemFor: (CGRect) -> ReusableView?) {
        let numberOfRows = Int(height / itemSize) + 2 * numberOfExtraItems
        let numberOfCols = Int(width / itemSize) + 2 * numberOfExtraItems
        containerSize = CGSize(width: width, height: height)
        
        for row in 0..<numberOfRows {
            views.append([])
            for col in 0..<numberOfCols {
                
                let x = CGFloat(col)*(itemSize) - CGFloat(numberOfExtraItems) * itemSize
                let y = CGFloat(row)*(itemSize) - CGFloat(numberOfExtraItems) * itemSize
                let frame = CGRect(x: x, y: y, width: itemSize, height: itemSize)
                guard let view = itemFor(frame) else { return }
                views[row].append(view)
                self.changeMaxMinPointsIfNeeded(x: x, y: y)
            }
        }
    }
    
    /// returns removed Views for reuse them
    func insertRowUp(itemFor: (CGRect) -> ReusableView?) -> [ReusableView] {
        guard let firstItemInView = views[numberOfExtraItems-1].first,
              firstItemInView.frame.origin.y > 0
        else {
            return []
        }
        
        let numberOfItems = views.first?.count ?? 0
        var rowViews = [ReusableView]()
        var x = minX
        let y = minY - itemSize
        
        for _ in 0...numberOfItems {
            let frame = CGRect(x: x, y: y, width: itemSize, height: itemSize)
            guard let view = itemFor(frame) else { return [] }
            rowViews.append(view)
            x += itemSize
        }
        views.insert(rowViews, at: 0)
        return removeDown()
    }
    
    /// returns removed Views for reuse them
    func insertRowDown(itemFor: (CGRect) -> ReusableView?) -> [ReusableView] {
        guard let lastItemInView = views[views.count-numberOfExtraItems-1].first,
              lastItemInView.frame.origin.y < containerSize.height - itemSize
        else {
            return []
        }
        
        let numberOfItems = views.first?.count ?? 0
        var rowViews = [ReusableView]()
        var x = minX
        let y = maxY + itemSize
        
        for _ in 0...numberOfItems {
            let frame = CGRect(x: x, y: y, width: itemSize, height: itemSize)
            guard let view = itemFor(frame) else { return []}
            rowViews.append(view)
            x += itemSize
        }
        views.append(rowViews)
        return removeUp()
    }
    
    /// returns removed Views for reuse them
    func insertRowLeft(itemFor: (CGRect) -> ReusableView?) -> [ReusableView] {
        let firstItemInView = views[numberOfExtraItems-1][numberOfExtraItems-1]
        guard firstItemInView.frame.origin.x > 0  else { return [] }
        
        let numberOfItems = views.count
        var colViews = [ReusableView]()
        let x = minX - itemSize
        var y = minY
        
        for _ in 0..<numberOfItems {
            let frame = CGRect(x: x, y: y, width: itemSize, height: itemSize)
            guard let view = itemFor(frame) else { return []}
            colViews.append(view)
            y += itemSize
        }
        for i in 0..<views.count {
            views[i].insert(colViews[i], at: 0)
        }
        return removeRight()
    }
    
    /// returns removed Views for reuse them
    func insertRowRight(itemFor: (CGRect) -> ReusableView?) -> [ReusableView] {
        let lastItemInView = views[views.count-numberOfExtraItems-1][views.count-numberOfExtraItems-1]
        guard lastItemInView.frame.origin.x + itemSize < containerSize.width else { return [] }
        
        let numberOfItems = views.count
        var colViews = [ReusableView]()
        let x = maxX + itemSize
        var y = minY
        
        for _ in 0...numberOfItems {
            let frame = CGRect(x: x, y: y, width: itemSize, height: itemSize)
            guard let view = itemFor(frame) else { return [] }
            colViews.append(view)
            y += itemSize
        }
        
        for i in 0..<views.count {
            views[i].append(colViews[i])
        }
        return removeLeft()
    }
    
    // MARK: - Removers
    
    func removeUp() -> [ReusableView] {
        let views = views.removeFirst()
        updateMinMaxPoints()
        return views
    }
    
    func removeDown() -> [ReusableView] {
        let views = views.removeLast()
        updateMinMaxPoints()
        return views
    }
    
    func removeLeft() -> [ReusableView] {
        var views = [ReusableView]()
        for index in 0..<self.views.count {
            let firstItem = self.views[index].removeFirst()
            views.append(firstItem)
        }
        updateMinMaxPoints()
        return views
    }
    
    func removeRight() -> [ReusableView] {
        var views = [ReusableView]()
        for index in 0..<self.views.count {
            let firstItem = self.views[index].removeLast()
            views.append(firstItem)
        }
        updateMinMaxPoints()
        return views
    }
    
    private func changeMaxMinPointsIfNeeded(x: CGFloat, y: CGFloat) {
        if x > maxX {
            maxX = x
        }
        
        if x < minX {
            minX = x
        }
        
        if y > maxY {
            maxY = y
        }
        
        if y < minY {
            minY = y
        }
    }
    
    private func updateMinMaxPoints() {
        guard let firstItem = views.first?.first,
              let lastItem = views.last?.last else {
            return
        }
        
        minX = firstItem.frame.origin.x
        minY = firstItem.frame.origin.y
        maxX = lastItem.frame.origin.x
        maxY = lastItem.frame.origin.y
    }
}
