//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
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
