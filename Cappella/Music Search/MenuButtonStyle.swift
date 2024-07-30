//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var isHighlighted: Bool = false
}

struct MenuButtonStyle: PrimitiveButtonStyle {
    @Environment(\.isHighlighted) var isHighlighted

    @State private var isTriggeringAction = false
    @State private var isHighlightedForTriggerAnimation = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 13.0, weight: .medium, design: .rounded))
            .lineLimit(1)

            .frame(maxWidth: .infinity, alignment: .leading)

            .padding(.vertical, 4.0)
            .padding(.horizontal, 10.0)

            .background(
                makeRoundedRectBackground(for: configuration, cornerRadius: 4.0)
            )

            .onTapGesture {
                performTrigger(with: configuration)
            }
            .onKeyPress(.return) {
                performTrigger(with: configuration)
                return .handled
            }
    }

    private func performTrigger(with configuration: Self.Configuration) {
        isTriggeringAction = true
        isHighlightedForTriggerAnimation = true

        withAnimation(.linear(duration: 0.075).repeatCount(4)) {
            isHighlightedForTriggerAnimation = false
        } completion: {
            isTriggeringAction = false
            configuration.trigger()
        }
    }

    @ViewBuilder
    private func makeRoundedRectBackground(
        for configuration: Self.Configuration,
        cornerRadius: CGFloat
    ) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.selection)
            .opacity((isTriggeringAction ? isHighlightedForTriggerAnimation : isHighlighted) ? 1.0 : 0.0)
    }
}

extension PrimitiveButtonStyle where Self == MenuButtonStyle {
    static var menu: Self { Self() }
}
