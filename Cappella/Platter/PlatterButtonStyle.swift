//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterButtonStyle: ButtonStyle {
    @State private var isHighlighted = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: 16.0, weight: .semibold, design: .rounded))
            .foregroundStyle(.primary)

            .padding(.horizontal, 30.0)
            .padding(.vertical, 10.0)

            .background(makeBackground(for: configuration))

            .scaleEffect(
                x: isHighlighted ? 0.92 : 1.0,
                y: isHighlighted ? 0.92 : 1.0,
                anchor: .center
            )
            .onChange(of: configuration.isPressed, { oldValue, newValue in
                withAnimation(.smooth(duration: newValue ? 0.20 : 0.50)) {
                    isHighlighted = newValue
                }
            })
    }

    @ViewBuilder
    private func makeBackground(for configuration: Self.Configuration) -> some View {
        Capsule(style: .continuous)
            .fill(.regularMaterial)
            .fill(Color.primary.opacity(1.0 / 7.0))
    }
}

extension ButtonStyle where Self == PlatterButtonStyle {
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
