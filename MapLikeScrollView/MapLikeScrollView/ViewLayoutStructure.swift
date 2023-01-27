//
//  ViewLayoutStructure.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 19.01.23.
//

import UIKit

class ViewLayoutStructure<T: IReusableView> {
    private var maxX: CGFloat = 0
    private var maxY: CGFloat = 0
    private var minX: CGFloat = 0
    private var minY: CGFloat = 0
    private var offset = CGPoint.zero

    private var scaleFactor: CGFloat = 1
    private let minimumScale: CGFloat = 0.7
    private let maximumScale: CGFloat = 2
    
    private var isInsertingUp = false
    private var isInsertingDown = false
    private var isInsertingLeft = false
    private var isInsertingRight = false
    
    // indicates amount of rows and cols rendered out of frame
    private var numberOfExtraItems = 4
    
    private var itemSize: CGFloat
    private var containerSize: CGSize = .zero
   
    private var views = [[T]]()
    
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
        
        offset.x += newX
        offset.y += newY
        for row in views {
            for item in row {
                let newCenter = CGPoint(x: item.center.x + newX, y: item.center.y + newY)
                item.center = newCenter
            }
        }
        updateMinMaxPoints()
    }
     
    func onPinch(scale: CGFloat) {
        
        print("curent scale is \(scale) and scaleFactor \(scaleFactor)")
        scaleFactor *= scale
        var effectiveScale: CGFloat = 1
        if scaleFactor > maximumScale {
            effectiveScale = maximumScale/scaleFactor
            scaleFactor = maximumScale
        }
        if scaleFactor < minimumScale {
            effectiveScale = minimumScale/scaleFactor
            scaleFactor = minimumScale
        }
        itemSize *= (effectiveScale * scale)
        for row in views {
            for item in row {
                var frame = item.frame
                frame.origin.x *= (effectiveScale * scale)
                frame.origin.y *= (effectiveScale * scale)
                frame.size.height *= (effectiveScale * scale)
                frame.size.width *= (effectiveScale * scale)
                item.frame = frame
            }
        }
        updateMinMaxPoints()
    }
    
    func frameToIndexPath(_ frame: CGRect) -> IndexPath {
        let realX = frame.origin.x - offset.x
        let realY = frame.origin.y - offset.y

        let row = Int(realY/itemSize)
        let col = Int(realX/itemSize)
        return IndexPath(row: row, section: col)
    }
    
    func initialLoad(height: CGFloat, width: CGFloat, itemFor: (CGRect) -> T?) {
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
    
    @discardableResult
    /// returns removed Views for reuse them
    func insertRowUp(removeOpposite: Bool = true, itemFor: (CGRect) -> T?) -> [T] {
        guard let firstItemInView = views[numberOfExtraItems-1].first,
              firstItemInView.frame.origin.y > 0
        else {
            return []
        }
        
        let numberOfItems = views.first?.count ?? 0
        var rowViews = [T]()
        var x = minX
        let y = minY - itemSize
        
        for _ in 0...numberOfItems {
            let frame = CGRect(x: x, y: y, width: itemSize, height: itemSize)
            guard let view = itemFor(frame) else { return [] }
            rowViews.append(view)
            x += itemSize
        }
        views.insert(rowViews, at: 0)
        if removeOpposite {
            return removeDown()
        }
        return []
    }
    
    @discardableResult
    /// returns removed Views for reuse them
    func insertRowDown(removeOpposite: Bool = true, itemFor: (CGRect) -> T?) -> [T] {
        guard let lastItemInView = views[views.count-numberOfExtraItems-1].first,
              lastItemInView.frame.origin.y < containerSize.height - itemSize
        else {
            return []
        }
        
        let numberOfItems = views.first?.count ?? 0
        var rowViews = [T]()
        var x = minX
        let y = maxY + itemSize
        
        for _ in 0...numberOfItems {
            let frame = CGRect(x: x, y: y, width: itemSize, height: itemSize)
            guard let view = itemFor(frame) else { return []}
            rowViews.append(view)
            x += itemSize
        }
        views.append(rowViews)
        if removeOpposite {
            return removeUp()
        }
        return []
    }
    
    @discardableResult
    /// returns removed Views for reuse them
    func insertRowLeft(removeOpposite: Bool = true, itemFor: (CGRect) -> T?) -> [T] {
        let firstItemInView = views[numberOfExtraItems-1][numberOfExtraItems-1]
        guard firstItemInView.frame.origin.x > 0  else { return [] }
        
        let numberOfItems = views.count
        var colViews = [T]()
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
        if removeOpposite {
            return removeRight()
        }
        return []
    }
    
    @discardableResult
    /// returns removed Views for reuse them
    func insertRowRight(removeOpposite: Bool = true, itemFor: (CGRect) -> T?) -> [T] {
        let lastItemInView = views[views.count-numberOfExtraItems-1][views.count-numberOfExtraItems-1]
        guard lastItemInView.frame.origin.x + itemSize < containerSize.width else { return [] }
        
        let numberOfItems = views.count
        var colViews = [T]()
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
        if removeOpposite {
            return removeLeft()
        }
        return []
    }
    
    // MARK: - Removers
    
    func removeUp() -> [T] {
        let views = views.removeFirst()
        updateMinMaxPoints()
        return views
    }
    
    func removeDown() -> [T] {
        let views = views.removeLast()
        updateMinMaxPoints()
        return views
    }
    
    func removeLeft() -> [T] {
        var views = [T]()
        for index in 0..<self.views.count {
            let firstItem = self.views[index].removeFirst()
            views.append(firstItem)
        }
        updateMinMaxPoints()
        return views
    }
    
    func removeRight() -> [T] {
        var views = [T]()
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
