//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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
        RoundedRectangle(cornerRadius: 24.0, style: .continuous)
            .fill(.primary)
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
    .padding(120.0)
    .background(.secondary)
}
