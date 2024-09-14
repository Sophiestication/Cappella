//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine
import MusicKit

struct NowPlayingView: View {
    typealias MusicPlayerType = ApplicationMusicPlayer
    @ObservedObject private var queue = MusicPlayerType.shared.queue

    @State private var authorizationStatus = MusicAuthorization.currentStatus

    var body: some View {
        Group {
            switch authorizationStatus {
            case .authorized:
                makeContentView()
            default:
                Color.red
            }
        }
        .platterKeyboardShortcut(using: .nowPlaying)
    }

    @ViewBuilder
    private func makeContentView() -> some View {
        HStack {
            if let entry = queue.currentEntry {
                makeArtworkImage(for: entry)
                    .frame(
                        width: CGFloat(Self.artworkDimension),
                        height: CGFloat(Self.artworkDimension)
                    )

                Text("\(entry.title)")
                    .lineLimit(1)
            }

            Spacer()

            PlaybackView()
                .disabled(queue.currentEntry == nil)
        }
        .padding(.horizontal, 10.0)
    }

    private static let artworkDimension: Int = 32

    @ViewBuilder
    private func makeArtworkImage(for entry: MusicPlayerType.Queue.Entry) -> some View {
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

#Preview {
    NowPlayingView()
}
