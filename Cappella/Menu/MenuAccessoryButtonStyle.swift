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
