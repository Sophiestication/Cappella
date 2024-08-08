//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine
import MusicKit

struct MusicSearchArtworkImage: View {
    typealias Entry = ApplicationMusicPlayer.Queue.Entry
    @State var entry: Entry?

    var body: some View {
        if let entry {
            makeArtworkImage(for: entry)
        } else {
            makePlaceholderView()
        }
    }

    private static let artworkDimension: Int = 64

    @ViewBuilder
    private func makeArtworkImage(for entry: ApplicationMusicPlayer.Queue.Entry) -> some View {
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
        _ url: URL,
        dimension: Int = Self.artworkDimension
    ) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(makeContentShape())
        } placeholder: {
            if let backgroundColor = artwork.backgroundColor {
                Color(cgColor: backgroundColor)
                    .clipShape(makeContentShape())
            } else {
                makePlaceholderView()
            }
        }
        .frame(width: CGFloat(dimension), height: CGFloat(dimension))
    }

    private func makeURL(for artwork: Artwork, dimension: Int = Self.artworkDimension) -> URL? {
        artwork.url(width: dimension, height: dimension)
    }

    private func makeContentShape() -> some Shape {
        RoundedRectangle(
            cornerSize: CGSize(width: 4.0, height: 4.0),
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
