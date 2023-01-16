//
//  MapLikeScrollView.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 15.01.23.
//

import UIKit
import SwiftUI

protocol MapLikeScrollViewDataSource: AnyObject {
    func view(for point: Coordinate, view: UIView?) -> UIView
}


class MapLikeScrollView: UIView {
    
    private let initialTileSideSize: CGFloat = 200
    
    private(set) var currentCenter: Coordinate = .zero
    private var maxX: Int = 0
    private var maxY: Int = 0
    private var minX: Int = 0
    private var minY: Int = 0
    
    private var isInsertingUp = false
    private var isInsertingDown = false
    private var isInsertingLeft = false
    private var isInsertingRight = false
    
    private var coordinateManager = CoordinateManager()
    
    weak var dataSource: MapLikeScrollViewDataSource?
    
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
    
    private func addGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panDidMove(_ :)))
        addGestureRecognizer(panGesture)
    }
    
    @objc private func panDidMove(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self)
        let direction = ScrollDirection(point: translation)
        newRegion(for: direction)
        let newX = CGFloat(Int(translation.x))
        let newY = CGFloat(Int(translation.y))
        
        minX += Int(newX)
        maxX += Int(newY)
        minY += Int(newY)
        maxY += Int(newY)
        currentCenter.point.x += newX
        currentCenter.point.y += newY
        
        for view in subviews {
            view.center = CGPoint(x: view.center.x + newX, y: view.center.y + newY)
        }
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
 
    func reload() {
        currentCenter =  .init(point: center)
        maxX = 0
        maxY = 0
        minX = 0
        minY = 0
        initialLoad()
    }
    
    private func initialLoad() {
        let numberOfRows = Int(bounds.height / initialTileSideSize) + 3
        let numberOfCols = Int(bounds.width / initialTileSideSize) + 3
        
        for col in 0..<numberOfCols {
            for row in 0..<numberOfRows {
                let x = CGFloat(col)*(initialTileSideSize) - 2 * initialTileSideSize
                let y = CGFloat(row)*(initialTileSideSize) - 2 * initialTileSideSize
                changeMaxMinPointsIfNeeded(x: x, y: y)
                
                let frame = CGRect(x: x, y: y, width: initialTileSideSize, height: initialTileSideSize)
                let thisItemCoordinates = Coordinate(point: frame.origin)
                let view = getView(frame: frame)
                coordinateManager.insert(view: view, for: thisItemCoordinates)
            }
        }
    }

    private func getView(frame: CGRect) -> UIView {
        let view = coordinateManager.view(for: .init(point: frame.origin))
        view.backgroundColor = UIColor.random()
        view.frame = frame
            let label = UILabel()
        label.numberOfLines = 0
        label.text = "x: \(frame.origin.x)\ny: \(frame.origin.y)"
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 80).isActive = true
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        addSubview(view)
        return view
    }
    
    private func isCenterCloseToBorder() -> Bool {
     return true
    }
    
    
    
    private func newRegion(for direction: ScrollDirection) {
        
        switch direction {
        case .up:
            insertRegionUp()
            removeDown()
        case .down:
            insertRegionDown()
            removeUp()
        case .left:
            insertRegionLeft()
            removeRight()
        case .right:
            insertRegionRight()
            removeLeft()
        case .upLeft:
            insertRegionUp()
            insertRegionLeft()
            removeDown()
            removeRight()
        case .upRight:
            insertRegionUp()
            insertRegionRight()
            removeDown()
            removeLeft()
        case .downLeft:
            insertRegionDown()
            insertRegionLeft()
            removeUp()
            removeRight()
        case .downRight:
            insertRegionDown()
            insertRegionRight()
            removeUp()
            removeLeft()
        }
    }
    
    // MARK: - Inserters
    
    private func insertRegionUp() {
        guard !isInsertingUp else { return }
        isInsertingUp = true
        var startPoint = CGPoint(x: CGFloat(minX), y: CGFloat(minY) - initialTileSideSize)
        let count = abs(Int(CGFloat(minX - maxX) / initialTileSideSize))
        for _ in 0..<count {
            let frame = CGRect(origin: startPoint, size: .init(width: initialTileSideSize, height: initialTileSideSize))
            startPoint.x += initialTileSideSize
            let thisItemCoordinates = Coordinate(point: frame.origin)
            let view = getView(frame: frame)
            view.alpha = 0.5
            coordinateManager.insert(view: view, for: thisItemCoordinates)
            changeMaxMinPointsIfNeeded(x: frame.origin.x, y: frame.origin.y)
        }
        isInsertingUp = false
    }
    
    private func insertRegionDown() {
        guard !isInsertingDown else { return }
        isInsertingDown = true
        var startPoint = CGPoint(x: CGFloat(minX), y: CGFloat(maxY) + initialTileSideSize)
        let count = abs(Int(CGFloat(minX - maxX) / initialTileSideSize))
        for _ in 0..<count {
            let frame = CGRect(origin: startPoint, size: .init(width: initialTileSideSize, height: initialTileSideSize))
            startPoint.x += initialTileSideSize
            let thisItemCoordinates = Coordinate(point: frame.origin)
            let view = getView(frame: frame)
            view.alpha = 0.5
            coordinateManager.insert(view: view, for: thisItemCoordinates)
            changeMaxMinPointsIfNeeded(x: frame.origin.x, y: frame.origin.y)
        }
        isInsertingDown = false
    }
    
    private func insertRegionLeft() {
        guard !isInsertingLeft else { return }
        isInsertingLeft = true
        var startPoint = CGPoint(x: CGFloat(minX) - initialTileSideSize, y: CGFloat(minY))
        let count = abs(Int(CGFloat(minY - maxY) / initialTileSideSize))
        for _ in 0..<count {
            let frame = CGRect(origin: startPoint, size: .init(width: initialTileSideSize, height: initialTileSideSize))
            startPoint.y += initialTileSideSize
            let thisItemCoordinates = Coordinate(point: frame.origin)
            let view = getView(frame: frame)
            view.alpha = 0.5
            coordinateManager.insert(view: view, for: thisItemCoordinates)
            changeMaxMinPointsIfNeeded(x: frame.origin.x, y: frame.origin.y)
        }
        isInsertingLeft = false
    }
    
    private func insertRegionRight() {
        guard !isInsertingRight else { return }
        isInsertingRight = true
        var startPoint = CGPoint(x: CGFloat(maxX) + initialTileSideSize, y: CGFloat(minY))
        let count = abs(Int(CGFloat(minY - maxY) / initialTileSideSize))
        for _ in 0..<count {
            let frame = CGRect(origin: startPoint, size: .init(width: initialTileSideSize, height: initialTileSideSize))
            startPoint.y += initialTileSideSize
            let thisItemCoordinates = Coordinate(point: frame.origin)
            let view = getView(frame: frame)
            view.alpha = 0.5
            coordinateManager.insert(view: view, for: thisItemCoordinates)
            changeMaxMinPointsIfNeeded(x: frame.origin.x, y: frame.origin.y)
        }
        isInsertingRight = false
    }
    
    // MARK: - Removers
    
    private func removeUp() {
//        let coordinate = getTopestCoordinate()
//        let views = coordinateManager.viewsUpperThan(coordinate: coordinate)
//        views.forEach { $0.removeFromSuperview() }
//        minY = Int(coordinate.point.y)
    }
    
    private func removeDown() {
//        let coordinate = getLowestCoordinate()
//        let views = coordinateManager.viewsDownThan(coordinate: coordinate)
//        views.forEach { $0.removeFromSuperview() }
//        maxY = Int(coordinate.point.y)
    }
    
    private func removeLeft() {
//        let coordinate = getLeftestCoordinate()
//        let views = coordinateManager.viewsLefterThan(coordinate: coordinate)
//        views.forEach { $0.removeFromSuperview() }
//        minX = Int(coordinate.point.x)
    }
    
    private func removeRight() {
//        let coordinate = getRightestCoordiante()
//        let views = coordinateManager.viewsRighterThan(coordinate: coordinate)
//        views.forEach { $0.removeFromSuperview() }
//        maxX = Int(coordinate.point.x)
    }
    
    // MARK: - EdgeCoordinateGetter
    
    private func getLowestCoordinate() -> Coordinate {
        var currentCenter = currentCenter.point
        let numberOfRows = bounds.height / initialTileSideSize / 2 + 6
        currentCenter.y += initialTileSideSize * numberOfRows
        return Coordinate(point: currentCenter)
    }
     
    private func getTopestCoordinate() -> Coordinate {
        var currentCenter = currentCenter.point
        let numberOfRows = bounds.height / initialTileSideSize / 2 + 6
        currentCenter.y -= initialTileSideSize * numberOfRows
        return Coordinate(point: currentCenter)
    }
    
    private func getLeftestCoordinate() -> Coordinate {
        var currentCenter = currentCenter.point
        let numberOfColumns = bounds.width / initialTileSideSize / 2 + 6
        currentCenter.x -= initialTileSideSize * numberOfColumns
        return Coordinate(point: currentCenter)
    }
    
    private func getRightestCoordiante() -> Coordinate {
        var currentCenter = currentCenter.point
        let numberOfColumns = bounds.width / initialTileSideSize / 2 + 6
        currentCenter.x += initialTileSideSize * numberOfColumns
        return Coordinate(point: currentCenter)
    }
    
    private func changeMaxMinPointsIfNeeded(x: CGFloat, y: CGFloat) {
        let x = Int(x)
        let y = Int(y)
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


struct CoordinateManager {
    private var currentItems: [Coordinate: UIView] = [:]
    private var rowCoordinates: [CGFloat: [Coordinate]] = [:]
    private var colCoordinates: [CGFloat: [Coordinate]] = [:]
    private var viewPool = [UIView]()
    
    mutating
    func insert(view: UIView, for coordinate: Coordinate) {
        currentItems[coordinate] = view
        if rowCoordinates[coordinate.point.y] == nil {
            rowCoordinates[coordinate.point.y] = [coordinate]
        } else {
            var arr = rowCoordinates[coordinate.point.y]
            arr?.append(coordinate)
            rowCoordinates[coordinate.point.y] = arr
        }
        if colCoordinates[coordinate.point.x] == nil {
            colCoordinates[coordinate.point.x] = [coordinate]
        } else {
            var arr = colCoordinates[coordinate.point.x]
            arr?.append(coordinate)
            colCoordinates[coordinate.point.x] = arr
        }
    }
    
    mutating
    func view(for coordinate: Coordinate) -> UIView {
        if let view = currentItems[coordinate] {
            return view
        }
        let view = createNewView()
        currentItems[coordinate] = view
        return view
    }
    
    mutating
    private func createNewView() -> UIView {
        if let view = viewPool.last {
            viewPool.removeLast()
            return view
        }
        return UIView()
    }
    
    mutating
    func remove(for coordinate: Coordinate) {
        guard let view = currentItems[coordinate] else { return }
        view.removeFromSuperview()
        viewPool.append(view)
        currentItems[coordinate] = nil
    }
    
    func viewsUpperThan(coordinate: Coordinate) -> [UIView] {
        var coordinates = [Coordinate]()
        return []
        
        let rows = rowCoordinates.keys.filter { $0 < coordinate.point.y }
        
        for item in rows {
            coordinates.append(contentsOf: rowCoordinates[item] ?? [])
        }
        
        var arr = [UIView]()
        coordinates.forEach {
            if let view = currentItems[$0] {
                arr.append(view)
            }
        }
        
        return arr
    }
    
    func viewsDownThan(coordinate: Coordinate) -> [UIView] {
        var arr = [UIView]()
        
        return arr
    }
    
    
    func viewsRighterThan(coordinate: Coordinate) -> [UIView] {
        var arr = [UIView]()
        
        return arr
    }
    
    
    func viewsLefterThan(coordinate: Coordinate) -> [UIView] {
        var arr = [UIView]()
        
        return arr
    }
    
}
