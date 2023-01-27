//
//  Extensions.swift
//  MapLikeScrollView
//
//  Created by Davit Ghushchyan on 15.01.23.
//

import UIKit

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}

extension Double {
    func dropDecimalsAfter(amountOfDecimals: Int) -> Double {
        let stringValue = String(format: "%.\(amountOfDecimals)f", self)
        return Double(stringValue) ?? self
    }
}

extension CGFloat {
    func dropDecimalsAfter(amountOfDecimals: Int) -> CGFloat {
        CGFloat(Double(self).dropDecimalsAfter(amountOfDecimals: amountOfDecimals))
    }
}
