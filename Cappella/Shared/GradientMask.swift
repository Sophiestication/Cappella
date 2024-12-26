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

struct GradientMask: View {
    let curve: UnitCurve

    let start: UnitPoint
    let end: UnitPoint

    init(
        _ curve: UnitCurve = .easeInOut,
        start: UnitPoint = .bottom,
        end: UnitPoint = .top
    ) {
        self.curve = curve

        self.start = start
        self.end = end
    }

    var body: some View {
        LinearGradient(
            gradient: gradient,
            startPoint: start,
            endPoint: end
        )
    }

    private var gradient: Gradient {
        let colors = stride(from: 0.0, to: 1.0, by: 1.0 / 25.0).map { value -> Color in
            let opacity = curve.value(at: value)
            return Color.red.opacity(opacity)
        }

        return Gradient(colors: colors)
    }
}

#Preview {
    VStack(spacing: 44.0) {
        ArtworkView(length: 240)
            .overlay(GradientMask(start: .init(x: 0.0, y: 0.0), end: .init(x: 0.0, y: 0.75)))
    }
    .padding(60.0)

    .environment(\.artworkProvider, PreviewArtworkProvider())
}
