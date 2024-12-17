//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine

struct WidgetButtonStyle: ButtonStyle {
    @State private var isHighlighted: Bool = false
    @State private var isPressed: Bool = false

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: length, height: length)
            .opacity(isEnabled ? 1.0 : 0.50)
            .contentShape(contentShape)
            .background(background)

            .scaleEffect(
                x: isPressed ? 0.88 : 1.0,
                y: isPressed ? 0.88 : 1.0,
                anchor: .center
            )

            .onHover { isHovering in
                withAnimation(.smooth(duration: isHovering ? 0.20 : 0.50)) {
                    isHighlighted = isHovering
                }
            }

            .onChange(of: configuration.isPressed) {
                withAnimation(.smooth(duration: configuration.isPressed ? 0.20 : 0.50)) {
                    isPressed = configuration.isPressed
                }
            }
    }

    private let length = 36.0

    @ViewBuilder
    private var contentShape: some Shape {
        Circle()
    }

    @ViewBuilder
    private var background: some View {
        contentShape
            .fill(Color.red.opacity(isHighlighted ? 0.25 : 0.10))
    }
}

#Preview {
    return Button {
        
    } label: {
        Image(systemName: "pause.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 10.0, height: 10.0)
            .padding(14.0)
    }
    .buttonStyle(WidgetButtonStyle())
    .scenePadding()
}
