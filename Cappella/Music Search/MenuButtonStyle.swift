//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MenuButtonStyle: PrimitiveButtonStyle {
    @State private var isHighlighted = false

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
                withAnimation(.linear(duration: 0.075).repeatCount(4)) {
                    isHighlighted = false
                } completion: {
                    isHighlighted = true
                    configuration.trigger()
                }
            }
            .onHover { isHovering in
                isHighlighted = isHovering
            }
    }

    @ViewBuilder
    private func makeRoundedRectBackground(
        for configuration: Self.Configuration,
        cornerRadius: CGFloat) -> some View
    {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.selection)
            .opacity(isHighlighted ? 1.0 : 0.0)
    }
}

extension PrimitiveButtonStyle where Self == MenuButtonStyle {
    static var menu: Self { Self() }
}
