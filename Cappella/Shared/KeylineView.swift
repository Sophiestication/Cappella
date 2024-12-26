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

struct KeylineView: View {
    @Environment(\.pixelLength) var pixelLength

    var body: some View {
        VStack(spacing: 0.0) {
            ContainerRelativeShape()
                .fill(Material.bar)
                .frame(height: pixelLength)
            ContainerRelativeShape()
                .fill(.white.opacity(1.0 / 7.0))
                .frame(height: 1.0)
        }
        .padding(.horizontal, 1.0)
        .mask {
            LinearGradient(
                colors: [.clear, .black, .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

#Preview {
    VStack {
        ArtworkView(length: 240)
    }
    .padding(60.0)
    .overlay(alignment: .bottom) {
        ContainerRelativeShape()
            .fill(Material.ultraThin)
            .frame(height: 200.0)
            .overlay(alignment: .top) {
                KeylineView()
            }
    }

    .environment(\.artworkProvider, PreviewArtworkProvider())
}
