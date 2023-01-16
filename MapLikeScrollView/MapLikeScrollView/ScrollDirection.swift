//
//  ScrollDirection.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 15.01.23.
//

import Foundation

enum ScrollDirection {
    case up
    case down
    case left
    case right
    case upLeft
    case upRight
    case downLeft
    case downRight
    
    init(point: CGPoint) {
        switch (point.x, point.y) {
        case let (x, 0):
            if x > 0 {
                self = .left
            } else {
                self = .right
            }
        case let (0, y):
            if y > 0 {
                self = .up
            } else {
                self = .down
            }
        case let (x, y):
            if x > 0 {
                if y > 0 {
                    self = .upLeft
                } else {
                    self = .downLeft
                }
            } else {
                if y > 0 {
                    self = .upRight
                } else {
                    self = .downRight
                }
            }
        }
    }
}
