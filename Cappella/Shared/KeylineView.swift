//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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
