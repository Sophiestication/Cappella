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
