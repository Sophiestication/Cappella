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

    typealias Entry = MusicPlayerType.Queue.Entry
    var currentEntry: Entry? { player.queue.currentEntry }

    private(set) var scheduledPlaybackStatus: MusicPlayerType.PlaybackStatus = .stopped

    typealias KeyboardShortcutEvent = GlobalKeyboardShortcutHandler.Event
    func perform(using event: KeyboardShortcutEvent) {
        switch event.id {
        case .playPause:
            playPause(using: event)

        case .fastForward:
            fastForward(using: event)

        case .rewind:
            rewind(using: event)

        case .toggleRepeatMode:
            toggleRepeatMode(using: event)

        case .shuffleOnOff:
            toggleShuffle(using: event)

        default:
            break
        }
    }

    func play(_ entry: Entry) {
        player.queue.currentEntry = entry
        schedulePlay()
    }

    private func playPause(using event: KeyboardShortcutEvent) {
        guard event.phase == .down else {
            return
        }

        let playbackStatus = playbackState.playbackStatus

        switch playbackStatus {
        case .playing, .seekingBackward, .seekingForward:
            scheduledPlaybackStatus = .paused
            player.pause()
        case .paused, .stopped:
            schedulePlay()
        case .interrupted:
            schedulePlay()
        default:
            break
        }
    }

    private func schedulePlay() {
        scheduledPlaybackStatus = .playing

        Task {
            try await MusicPlayerType.shared.play()
        }
    }

    private func fastForward(using event: KeyboardShortcutEvent){
        let playbackStatus = playbackState.playbackStatus

        if event.phase == .up {
            if playbackStatus == .seekingForward {
                player.endSeeking()
                player.pause()
                schedulePlay()
            } else {
                Task {
                    try await MusicPlayerType.shared.skipToNextEntry()
                }
            }
        } else if event.phase == .down {

        } else if event.phase == .repeat {
            if playbackStatus != .seekingForward {
                scheduledPlaybackStatus = .seekingForward
                player.beginSeekingForward()
            }
        }
    }

    private func rewind(using event: KeyboardShortcutEvent) {
        let playbackStatus = playbackState.playbackStatus

        if event.phase == .up {
            if playbackStatus == .seekingBackward {
                player.endSeeking()
                player.pause()
                schedulePlay()
            } else {
                Task {
                    try await MusicPlayerType.shared.skipToPreviousEntry()
                }
            }
        } else if event.phase == .down {

        } else if event.phase == .repeat {
            if playbackStatus != .seekingBackward {
                scheduledPlaybackStatus = .seekingBackward
                player.beginSeekingBackward()
            }
        }
    }

    private func toggleShuffle(using event: KeyboardShortcutEvent) {
        guard event.phase == .down else {
            return
        }

        let playbackState = playbackState
        var newShuffleMode: MusicPlayerType.ShuffleMode = .off

        if let shuffleMode = playbackState.shuffleMode {
            if shuffleMode == .off {
                newShuffleMode = .songs
            } else if shuffleMode == .songs {
                newShuffleMode = .off
            }
        }

        playbackState.shuffleMode = newShuffleMode
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

