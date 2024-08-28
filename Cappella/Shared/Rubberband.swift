//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation

public func rubberband(
    value: CGFloat,
    range: ClosedRange<CGFloat>,
    interval: CGFloat,
    c: CGFloat = 0.55
) -> CGFloat {
    // * x = distance from the edge
    // * c = constant value, UIScrollView uses 0.55
    // * d = dimension, either width or height
    // b = (1.0 – (1.0 / ((x * c / d) + 1.0))) * d
    if range.contains(value) {
        return value
    }

    let d: CGFloat = interval

    if value > range.upperBound {
        let x = value - range.upperBound
        let b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d
        return range.upperBound + b
    } else {
        let x = range.lowerBound - value
        let b = (1.0 - (1.0 / ((x * c / d) + 1.0))) * d
        return range.lowerBound - b
    }
}
