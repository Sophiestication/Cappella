//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

extension Shape {
    fileprivate func makeInnerShadowMask(
        radius: CGFloat,
        x: CGFloat,
        y: CGFloat
    ) -> some View {
        self
            .fill(.black)
            .overlay(
                self
                    .fill(.white)
                    .blur(radius: radius)
                    .offset(x: x, y: y)
                    .blendMode(.destinationOut)
            )
    }

    public func innerShadow(
        color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33),
        radius: CGFloat,
        x: CGFloat = 0,
        y: CGFloat = 0
    ) -> some View {
        self
            .fill(color)
            .mask(makeInnerShadowMask(radius: radius, x: x, y: y))
    }
}
