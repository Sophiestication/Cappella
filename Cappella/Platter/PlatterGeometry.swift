//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
        headerDimension: CGFloat = 80.0,
        footerDimension: CGFloat = 120.0
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

    static let horizontalInset: CGFloat = 200.0
}

extension EnvironmentValues {
    @Entry var platterGeometry: PlatterGeometry? = nil
}
