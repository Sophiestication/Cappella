//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct NowPlayingView: View {
    private typealias MusicPlayerType = ApplicationMusicPlayer

    @State private var authorizationStatus = MusicAuthorization.currentStatus

    @ObservedObject private var queue = MusicPlayerType.shared.queue

    var body: some View {
        switch authorizationStatus {
        case .authorized:
            makeContentView()
        default:
            Color.red
        }
    }

    @ViewBuilder
    private func makeContentView() -> some View {
        HStack {
//            if let entry = queue.currentEntry {
//                makeArtworkView(for: entry)
//                Text("\(entry.title)")
//                    .lineLimit(1)
//            }

            Spacer()

            PlaybackView()
//                .disabled(queue.currentEntry == nil)
        }
        .padding(.horizontal)
    }

    private static let artworkDimension: Int = 24

    @ViewBuilder
    private func makeArtworkView(for entry: MusicPlayerType.Queue.Entry?) -> some View {
        if  let entry,
            let artwork = entry.artwork {
            ArtworkImage(
                artwork,
                width: CGFloat(Self.artworkDimension)
            )
            .cornerRadius(4.0)
        } else {
            makeArtworkPlaceholderView()
        }
    }

    @ViewBuilder
    private func makeArtworkPlaceholderView() -> some View {
        RoundedRectangle(
            cornerSize: CGSize(width: 4.0, height: 4.0),
            style: .continuous
        )
        .fill(.quaternary)
        .frame(
            width: CGFloat(Self.artworkDimension),
            height: CGFloat(Self.artworkDimension)
        )
    }
}

#Preview {
    NowPlayingView()
}
