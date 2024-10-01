//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterButtonStyle: PrimitiveButtonStyle {
    @State private var isHighlighted = false
    @State private var isLongPressed = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 16.0, weight: .semibold))
            .foregroundStyle(.black)
            .padding(.horizontal, 8.0)
            .background(makeBackground(for: configuration))
            .scaleEffect(
                x: isHighlighted ? 0.92 : 1.0,
                y: isHighlighted ? 0.92 : 1.0,
                anchor: .center
            )
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
    }

    @ViewBuilder
    private func makeBackground(for configuration: Self.Configuration) -> some View {
        Capsule(style: .continuous)
            .padding(.horizontal, -5.0)
            .padding(.vertical, -8.0)
            .background(.regularMaterial)
    }
}

extension PrimitiveButtonStyle where Self == PlatterButtonStyle {
    static var platter: Self { Self() }
}

#Preview {
    Button(action: {

    }, label: {
        Text("Authorize")
    })
    .buttonStyle(.platter)
    .frame(width: 320.0, height: 480.0)
}
