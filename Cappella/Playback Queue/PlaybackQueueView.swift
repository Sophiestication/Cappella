//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackQueueView: View {
    private typealias MusicPlayerType = ApplicationMusicPlayer
    @ObservedObject private var queue = MusicPlayerType.shared.queue

    private typealias Entry = MusicPlayerType.Queue.Entry

    @Environment(\.playbackQueue) var playbackQueue

    var body: some View {
        VStack {
            ForEach(queue.entries) { entry in
                makeMenuItem(for: entry)
            }
        }
        .padding(.horizontal, 10.0)
    }

    @ViewBuilder
    private func makeMenuItem(
        for entry: Entry
    ) -> some View {
        Button(action: {

        }, label: {
            HStack {
                makeArtworkImage(for: entry)
                    .frame(
                        width: CGFloat(Self.artworkDimension),
                        height: CGFloat(Self.artworkDimension)
                    )

                VStack(alignment: .leading) {
                    Text(entry.title)

                    if let subtitle = entry.subtitle {
                        Text(subtitle)
                    }
                }
            }
        })
        .buttonStyle(.menu)
    }

    private static let artworkDimension: Int = 32

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
        _ url: URL,
        dimension: Int = Self.artworkDimension
    ) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .interpolation(.high)
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
