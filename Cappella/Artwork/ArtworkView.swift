//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct ArtworkView: View {
    @Environment(\.artworkProvider) var artwork: ArtworkProviding?
    @Environment(\.pixelLength) var pixelLength
    @Environment(\.cornerRadius) var cornerRadius

    @State var length: Int = 64

    var body: some View {
        artworkImage
            .frame(width: CGFloat(length), height: CGFloat(length))
    }

    @ViewBuilder
    private var contentShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: cornerRadius,
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
                    .aspectRatio(contentMode: .fit)
                    .background(placeholder)
                    .overlay(
                        contentShape
                            .inset(by: pixelLength)
                            .stroke(lineWidth: pixelLength)
                            .fill(.white.opacity(1.0 / 10.0))
                            .blendMode(.screen)
                    )
                    .clipShape(contentShape)
                    .smoothShadow(
                        color: Color.black.opacity(1.0 / 4.0),
                        radius: 3.0,
                        y: 4.0
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
            width: length,
            height: length
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

extension EnvironmentValues {
    @Entry var cornerRadius: CGFloat = .zero
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 44.0) {
        ArtworkView(length: 40)
        ArtworkView(length: 64)
        ArtworkView(length: 128)
        ArtworkView(length: 240)
    }
    .padding(60.0)

    .environment(\.artworkProvider, PreviewArtworkProvider())
    .environment(\.cornerRadius, 8.0)
}
