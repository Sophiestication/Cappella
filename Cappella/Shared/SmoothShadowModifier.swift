//
// MIT License
//
// Copyright (c) 2024 Sophiestication Software, Inc.
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

struct RecursiveShadowModifier: ViewModifier {
    let color: Color

    let layers: Int
    let currentLayer: Int

    let baseRadius: CGFloat
    let baseX: CGFloat
    let baseY: CGFloat

    let curve: UnitCurve

    func body(content: Content) -> some View {
        if currentLayer >= layers {
            return AnyView(content)
        }

        let progress = CGFloat(currentLayer) / CGFloat(layers)
        let radius = baseRadius * curve.value(at: progress)

        let x = baseX * curve.value(at: progress)
        let y = baseY * curve.value(at: progress)

        return AnyView(
            content
                .shadow(color: color, radius: radius, x: x, y: y)
                .modifier(
                    RecursiveShadowModifier(
                        color: color,
                        layers: layers,
                        currentLayer: currentLayer + 1,
                        baseRadius: baseRadius,
                        baseX: baseX,
                        baseY: baseY,
                        curve: curve
                    )
                )
        )
    }
}

extension View {
    func smoothShadow(
        color: Color = .init(white: 0.0, opacity: 1.0 / 3.0),
        layers: Int = 3,
        curve: UnitCurve = .easeInOut,
        radius: CGFloat,
        x: CGFloat = 0.0,
        y: CGFloat = 0.0
    ) -> some View {
        self.modifier(
            RecursiveShadowModifier(
                color: color,
                layers: layers,
                currentLayer: 0,
                baseRadius: radius,
                baseX: x,
                baseY: y,
                curve: curve
            )
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        RoundedRectangle(cornerRadius: 37.0, style: .continuous)
            .fill(.white)
            .smoothShadow(
                color: .black.opacity(0.2),
                layers: 5,
                curve: .easeInOut,
                radius: 24.0,
                x: 0.0,
                y: 32.0
            )
            .frame(width: 200.0, height: 200.0)
    }
    .padding(160.0)
    .background(.white.opacity(0.70))
}
