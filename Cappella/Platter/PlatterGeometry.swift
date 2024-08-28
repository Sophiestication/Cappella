//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

@Observable
class PlatterGeometry {
    var containerFrame: CGRect

    var contentFrame: CGRect {
        let frame = containerFrame
        let inset = Self.contentInset

        return CGRect(
            x: inset.left,
            y: inset.top,
            width: frame.width - (inset.left + inset.right),
            height: frame.height - (inset.top + inset.bottom)
        )
    }

    var headerDimension: CGFloat
    var footerDimension: CGFloat

    init(
        containerFrame: CGRect = .zero,
        headerDimension: CGFloat = 70.0,
        footerDimension: CGFloat = 44.0
    ) {
        self.containerFrame = containerFrame

        self.headerDimension = headerDimension
        self.footerDimension = footerDimension
    }

    private static var contentInset: NSEdgeInsets {
        let horizontalInset = horizontalInset

        return NSEdgeInsets(
            top: 6.0,
            left: horizontalInset,
            bottom: 240.0,
            right: horizontalInset
        )
    }

    static let horizontalInset: CGFloat = 120.0
}

extension EnvironmentValues {
    @Entry var platterGeometry: PlatterGeometry? = nil
}
