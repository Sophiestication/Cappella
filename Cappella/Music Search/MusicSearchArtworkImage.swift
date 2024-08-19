//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine
import MusicKit

struct MusicSearchArtworkImage: View {
    typealias Entry = MusicSearch.Entry
    @State var entry: Entry?

    private let dimension: Int = 64
    @Environment(\.pixelLength) var pixelLength

    var body: some View {
        Group {
            if let entry {
                makeArtworkImage(for: entry)
            } else {
                makePlaceholderView()
            }
        }
        .frame(width: CGFloat(dimension), height: CGFloat(dimension))
    }

    @ViewBuilder
    private func makeArtworkImage(for entry: Entry) -> some View {
        if let artwork = entry.artwork,
           let url = makeURL(for: artwork) {
            makeArtworkImage(for: artwork, url)
        } else {
            makePlaceholderView()
        }
    }

    @ViewBuilder
    private func makeArtworkImage(
        for artwork: Artwork,
        _ url: URL
    ) -> some View {
        AsyncImage(url: url) { image in
            image
                .interpolation(.high)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(makeContentShape())
                .overlay(
                    makeContentShape()
                        .stroke(lineWidth: pixelLength)
                        .fill(.quaternary)
                        .padding(EdgeInsets(
                            top: pixelLength,
                            leading: pixelLength,
                            bottom: pixelLength,
                            trailing: pixelLength
                        ))
                )
                .shadow(
                    color: Color.black.opacity(0.25),
                    radius: 2.0,
                    y: 1.0
                )
        } placeholder: {
            if let backgroundColor = artwork.backgroundColor {
                Color(cgColor: backgroundColor)
                    .clipShape(makeContentShape())
            } else {
                makePlaceholderView()
            }
        }
    }

    private func makeURL(for artwork: Artwork) -> URL? {
        artwork.url(width: dimension, height: dimension)
    }

    private func makeContentShape() -> some Shape {
        RoundedRectangle(
            cornerSize: CGSize(width: 7.0, height: 7.0),
            style: .continuous
        )
    }

    @ViewBuilder
    private func makePlaceholderView() -> some View {
        makeContentShape()
            .fill(.quaternary)
    }
}

#Preview {
    NowPlayingView()
}
