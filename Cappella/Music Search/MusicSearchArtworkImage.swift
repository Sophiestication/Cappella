//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine
import MusicKit

struct MusicSearchArtworkImage: View {
    typealias Entry = ApplicationMusicPlayer.Queue.Entry
    @State var entry: Entry?

    private let dimension: Int = 64

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
        _ url: URL
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
    }

    private func makeURL(for artwork: Artwork) -> URL? {
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
