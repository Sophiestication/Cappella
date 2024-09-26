//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MenuAccessoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            configuration.label
                .frame(width: 20.0, height: 20.0)

                .opacity(configuration.isPressed ? 0.50 : 1.0)
                .animation(.smooth, value: configuration.isPressed)

                .scaleEffect(
                    x: scale(for: configuration),
                    y: scale(for: configuration),
                    anchor: .center
                )
                .animation(.interactiveSpring, value: configuration.isPressed)
        }
        .shadow(radius: 1.0, y: 1.0)
        .padding(10.0)
        .contentShape(.interaction, contentShape)

//        .background(.red.opacity(0.25))
    }

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
