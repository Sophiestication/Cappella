//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct TextButtonStyle: PrimitiveButtonStyle {
    enum ContentShape {
        case capsule
        case roundedRect(CGFloat)
    }
    let contentShape: ContentShape

    @State private var isHighlighted = false
    @State private var isLongPressed = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(
                x: isHighlighted ? 0.92 : 1.0,
                y: isHighlighted ? 0.92 : 1.0,
                anchor: .center
            )
            .background(makeBackground(for: configuration))
            .onTapGesture {
                configuration.trigger()
            }
            .onLongPressGesture {
                isLongPressed = true
                configuration.trigger()
            } onPressingChanged: { isPressed in
                isLongPressed = false

                withAnimation(.smooth(duration: isPressed ? 0.20 : 0.50)) {
                    isHighlighted = isPressed
                }
            }
            .sensoryFeedback(.impact(weight: .heavy), trigger: isLongPressed) { _, newValue in
                newValue
            }
    }

    @ViewBuilder
    private func makeBackground(for configuration: Self.Configuration) -> some View {
        switch contentShape {
        case .capsule:
            makeCapsuleBackground(for: configuration)
        case .roundedRect(let cornerRadius):
            makeRoundedRectBackground(for: configuration, cornerRadius: cornerRadius)
        }
    }

    @ViewBuilder
    private func makeCapsuleBackground(for configuration: Self.Configuration) -> some View {
        Capsule(style: .continuous)
            .padding(-3.0)
            .foregroundColor(.white)
            .opacity(isHighlighted ? 1.0 : 0.0)
    }

    @ViewBuilder
    private func makeRoundedRectBackground(
        for configuration: Self.Configuration,
        cornerRadius: CGFloat) -> some View
    {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .padding(-3.0)
            .foregroundColor(.white)
            .opacity(isHighlighted ? 1.0 : 0.0)
    }
}

extension PrimitiveButtonStyle where Self == TextButtonStyle {
    static var text: Self { Self(contentShape: .capsule) }
}
