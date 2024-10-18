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

    @State private var playerPosition: Double = .zero

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

    private func format(_ playbackTime: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = playbackTime >= 3600 ?
            [.hour, .minute, .second] :
            [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: playbackTime) ?? "0:00"
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 20.0) {
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

            PlayerPositionView(
                $playerPosition, 
                action: { position, shouldCommit in
                    updatePlaybackTime(from: position, shouldCommit: shouldCommit)
                },
                leadingLabel: {
                    Text("\(format(musicPlayer.playbackTime))")
                },
                trailingLabel: {
                    Text("\(format(musicPlayer.playbackDuration))")
                }
            )
        }

        .onChange(of: musicPlayer.playbackTime, initial: true) { _, newValue in
            guard let _ = queue.currentEntry else {
                playerPosition = .zero
                return
            }

            let duration = musicPlayer.playbackDuration
            playerPosition = duration * newValue
        }

        .padding(.horizontal, 20.0)
        .padding(.vertical, 15.0)

        .contentShape(.interaction, ContainerRelativeShape())
    }

    private func updatePlaybackTime(from newPosition: Double, shouldCommit: Bool) {
        guard let _ = queue.currentEntry else { return }

        let duration = musicPlayer.playbackDuration
        let playbackTime = duration * newPosition

        if shouldCommit {
            musicPlayer.seek(to: playbackTime)
        }
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
        case .playing, .seekingBackward, .seekingForward:
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
