//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import SwiftUI
import MusicKit
import Combine
import WidgetKit

@Observable
final class CappellaMusicPlayer {
    typealias MusicPlayerType = ApplicationMusicPlayer

    private var player: MusicPlayerType { MusicPlayerType.shared }

    typealias State = MusicPlayerType.State
    var playbackState: State { player.state }

    typealias Queue = MusicPlayerType.Queue
    var queue: Queue { player.queue }

    typealias Entry = MusicPlayerType.Queue.Entry
    var currentEntry: Entry? { player.queue.currentEntry }

    typealias PressPhases = KeyPress.Phases

    private(set) var scheduledPlaybackStatus: MusicPlayerType.PlaybackStatus = .stopped

    typealias KeyboardShortcutEvent = GlobalKeyboardShortcutHandler.Event
    func perform(using event: KeyboardShortcutEvent) {
        switch event.id {
        case .playPause:
            playPause(using: event.phase)

        case .fastForward:
            fastForward(using: event.phase)

        case .rewind:
            rewind(using: event.phase)

        case .toggleRepeatMode:
            toggleRepeatMode(using: event.phase)

        case .shuffleOnOff:
            toggleShuffle(using: event.phase)

        default:
            break
        }
    }

    func play(_ entry: Entry) {
        player.queue.currentEntry = entry
        schedulePlay()
    }

    func playPause() {
        playPause(using: .down)
    }

    func playPause(using phases: PressPhases) {
        guard phases == .down else {
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

    func fastForward() {
        fastForward(using: .up)
    }

    func fastForward(using phases: PressPhases) {
        let playbackStatus = playbackState.playbackStatus

        if phases == .up {
            if playbackStatus == .seekingForward {
                player.endSeeking()
                player.pause()
                schedulePlay()
            } else {
                Task {
                    try await MusicPlayerType.shared.skipToNextEntry()
                }
            }
        } else if phases == .down {

        } else if phases.contains(.repeat) {
            if playbackStatus != .seekingForward {
                scheduledPlaybackStatus = .seekingForward
                player.beginSeekingForward()
            }
        }
    }

    func rewind() {
        rewind(using: .up)
    }

    func rewind(using phases: PressPhases) {
        let playbackStatus = playbackState.playbackStatus

        if phases == .up {
            if playbackStatus == .seekingBackward {
                player.endSeeking()
                player.pause()
                schedulePlay()
            } else {
                Task {
                    try await MusicPlayerType.shared.skipToPreviousEntry()
                }
            }
        } else if phases == .down {

        } else if phases.contains(.repeat) {
            if playbackStatus != .seekingBackward {
                scheduledPlaybackStatus = .seekingBackward
                player.beginSeekingBackward()
            }
        }
    }

    func toggleShuffle() {
        toggleShuffle(using: .down)
    }

    func toggleShuffle(using phases: PressPhases) {
        guard phases == .down else {
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

    func toggleRepeatMode() {
        toggleRepeatMode(using: .down)
    }

    func toggleRepeatMode(using phases: PressPhases) {
        guard phases == .down else {
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
    @Entry var musicPlayer: CappellaMusicPlayer = .init()
}
