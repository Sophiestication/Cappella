//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackView: View {
    private typealias MusicPlayerType = ApplicationMusicPlayer
    @ObservedObject private var playbackState = MusicPlayerType.shared.state

    var body: some View {
        HStack {
            Button(action: {
            }, label: {
                Image(systemName: "backward.fill")
            })

            Button(action: {
                playPause()
            }, label: {
                switch playbackState.playbackStatus {
                case .playing:
                    Image(systemName: "pause.fill")
                case .paused:
                    Image(systemName: "play.fill")
                default:
                    Image(systemName: "stop.fill")
                }
            })

            Button(action: {

            }, label: {
                Image(systemName: "forward.fill")
            })
        }
    }

    private func playPause() {
        let player = MusicPlayerType.shared
        let playbackStatus = playbackState.playbackStatus

        if playbackStatus == .playing {
            player.pause()
        } else {
            Task {
                try await player.play()
            }
        }
    }
}

#Preview {
    PlaybackView()
}
