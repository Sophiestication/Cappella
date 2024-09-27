//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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
                ArtworkView(dimension: 40)
                    .environment(\.artworkProvider, entry.artwork)

                Text("\(entry.title)")
                    .lineLimit(1)
            }

            Spacer()

            PlaybackControlsView()
                .disabled(queue.currentEntry == nil)
        }
        .padding(.horizontal, 10.0)
    }
}

#Preview {
    NowPlayingView()
        .scenePadding()
}
