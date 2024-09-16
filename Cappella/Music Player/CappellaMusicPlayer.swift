//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import SwiftUI
import MusicKit

@Observable @MainActor
final class CappellaMusicPlayer {
    typealias MusicPlayerType = ApplicationMusicPlayer

    private var player: MusicPlayerType { MusicPlayerType.shared }
    var playbackState: MusicPlayerType.State { player.state }

    typealias KeyboardShortcutEvent = GlobalKeyboardShortcutHandler.Event
    func perform(using event: KeyboardShortcutEvent) {
        switch event.id {
        case .playPause:
            playPause(using: event)

        case .nextSong:
            nextSong(using: event)

        case .previousSong:
            previousSong(using: event)

        case .toggleRepeatMode:
            toggleRepeatMode(using: event)

        case .shuffleOnOff:
            toggleShuffle(using: event)

        default:
            break
        }
    }

    private func playPause(using event: KeyboardShortcutEvent) {
    }

    private func nextSong(using event: KeyboardShortcutEvent){
    }

    private func previousSong(using event: KeyboardShortcutEvent) {
    }

    private func toggleShuffle(using event: KeyboardShortcutEvent) {
    }

    private func toggleRepeatMode(using event: KeyboardShortcutEvent) {
        guard event.phase == .down else {
            return
        }

        let playbackState = playbackState
        var newRepeatMode: MusicPlayer.RepeatMode = .all

        if let repeatMode = playbackState.repeatMode {
            if repeatMode == .all {
                newRepeatMode = .one
            } else if repeatMode == .one {
                newRepeatMode = MusicPlayer.RepeatMode.none
            } else if repeatMode == .none {
                newRepeatMode = .all
            }
        }

        playbackState.repeatMode = newRepeatMode
    }
}

extension EnvironmentValues {
    @Entry var musicPlayer: CappellaMusicPlayer? = nil
}

