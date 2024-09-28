//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MenuAccessoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
                .frame(width: length, height: length)

                .opacity(configuration.isPressed ? 0.50 : 1.0)
                .animation(.smooth, value: configuration.isPressed)

                .scaleEffect(
                    x: scale(for: configuration),
                    y: scale(for: configuration),
                    anchor: .center
                )
                .animation(.interactiveSpring, value: configuration.isPressed)
        }
        .padding(10.0)
        .contentShape(.interaction, contentShape)
    }

    private let length: CGFloat = 16.0

    private func scale(for configuration: Configuration) -> CGFloat {
        configuration.isPressed ? 0.88 : 1.0
    }

    @ViewBuilder
    private var contentShape: some Shape {
        Circle()
    }
}

extension ButtonStyle where Self == MenuAccessoryButtonStyle {
    static var menuAccessory: Self { Self() }
}
