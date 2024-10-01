//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine
import MusicKit

struct NowPlayingView: View {
    @State private var authorizationStatus = MusicAuthorization.currentStatus

    typealias MusicPlayerType = CappellaMusicPlayer
    private let musicPlayer: MusicPlayerType

    private typealias PlaybackState = CappellaMusicPlayer.MusicPlayerType.State

    @ObservedObject private var playbackState: MusicPlayerType.State
    @ObservedObject private var queue: MusicPlayerType.Queue

    init(using musicPlayer: MusicPlayerType) {
        self.musicPlayer = musicPlayer
        self.playbackState = musicPlayer.playbackState
        self.queue = musicPlayer.queue
    }

    var body: some View {
        Group {
            switch authorizationStatus {
            case .authorized:
                content
            default:
                Color.red
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        HStack {
            if let entry = queue.currentEntry {
                Label {
                    Text("\(entry.title)")

                    if let subtitle = entry.subtitle {
                        Text("\(subtitle)")
                    }
                } icon: {
                    ArtworkView(length: 40)
                }
                .environment(\.artworkProvider, entry.artwork)

                .lineLimit(1)

                .font(.system(size: 13))
                .labelStyle(PlatterMenuLabelStyle())

                .padding(.trailing, 5.0)
            }

            Spacer()

            playbackControls
                .disabled(queue.currentEntry == nil)
        }
        .padding(.horizontal, 10.0)
    }

    @ViewBuilder
    private var playbackControls: some View {
        HStack {
            Button(action: {
            }, label: {
                Image("rewindTemplate")
            })
            .buttonRepeatAction { phases in
                musicPlayer.rewind(using: phases)
            }

            Button(action: {
            }, label: {
                Image(imageName(for: playbackState))
            })
            .buttonRepeatAction { phases in
                musicPlayer.playPause(using: phases)
            }

            Button(action: {
            }, label: {
                Image("fastForwardTemplate")
            })
            .buttonRepeatAction { phases in
                musicPlayer.fastForward(using: phases)
            }
        }
        .buttonStyle(RepeatButtonStyle())
    }

    private func imageName(for playbackState: PlaybackState) -> String {
        switch playbackState.playbackStatus {
        case .playing:
            "pauseTemplate"
        case .paused:
            "playTemplate"
        default:
            "stopTemplate"
        }
    }
}

#Preview {
    NowPlayingView(using: CappellaMusicPlayer())
        .scenePadding()
}
