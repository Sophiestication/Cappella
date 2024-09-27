//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct ArtworkView: View {
    @Environment(\.artworkProvider) var artwork: ArtworkProviding?
    @Environment(\.pixelLength) var pixelLength

    @State var dimension: Int = 64

    var body: some View {
        artworkImage
            .frame(width: CGFloat(dimension), height: CGFloat(dimension))
    }

    @ViewBuilder
    private var contentShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: ceil(CGFloat(dimension) * 0.11),
            style: .continuous
        )
    }

    @ViewBuilder
    private var artworkImage: some View {
        if let url {
            AsyncImage(url: url) { image in
                image
                    .interpolation(.high)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        contentShape
                            .inset(by: pixelLength)
                            .stroke(lineWidth: pixelLength)
                            .fill(.white.opacity(1.0 / 4.0))
                            .blendMode(.overlay)
                    )
                    .clipShape(contentShape)
                    .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 4.0,
                        y: 2.0
                    )
            } placeholder: {
                placeholder
            }
        } else {
            placeholder
        }
    }

    private var url: URL? {
        artwork?.url(
            width: dimension,
            height: dimension
        )
    }

    @ViewBuilder
    private var placeholder: some View {
        if let backgroundColor = artwork?.backgroundColor {
            Color(cgColor: backgroundColor)
                .clipShape(contentShape)
        } else {
            contentShape
                .fill(.placeholder)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 44.0) {
        ArtworkView(dimension: 40)
        ArtworkView(dimension: 64)
        ArtworkView(dimension: 128)
        ArtworkView(dimension: 240)
    }
    .padding(60.0)

    .environment(\.artworkProvider, PreviewArtworkProvider())
}
