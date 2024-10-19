//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation
import SwiftUI
import MusicKit
import Combine

@Observable
final class CappellaMusicPlayer {
    typealias MusicPlayerType = ApplicationMusicPlayer

    private var player: MusicPlayerType { MusicPlayerType.shared }

    typealias State = MusicPlayerType.State
    var playbackState: State { player.state }

    var playbackTime: TimeInterval = .nan
    var playbackDuration: TimeInterval {
        guard let item = currentEntry?.item else { return .nan }

        var duration: TimeInterval? = nil

        switch item {
        case .song(let song):
            duration = song.duration
            break
        default:
            break
        }

        return duration ?? .nan
    }

    typealias Queue = MusicPlayerType.Queue
    var queue: Queue { player.queue }

    typealias Entry = MusicPlayerType.Queue.Entry
    var currentEntry: Entry? { player.queue.currentEntry }

    typealias PressPhases = KeyPress.Phases

    private(set) var scheduledPlaybackStatus: MusicPlayerType.PlaybackStatus = .stopped

    private var timerCancellable: AnyCancellable?

    init() {
        updatePlaybackTime(every: 1.0)
    }

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
            updatePlaybackTime(every: 1.0)

            if playbackStatus == .seekingForward {
                player.endSeeking()
                player.pause()
                schedulePlay()
            } else {
                playbackTime = .zero

                Task {
                    try await MusicPlayerType.shared.skipToNextEntry()
                }
            }
        } else if phases == .down {
            updatePlaybackTime(every: 0.1)
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
            updatePlaybackTime(every: 1.0)

            if playbackStatus == .seekingBackward {
                player.endSeeking()
                player.pause()
                schedulePlay()
            } else {
                playbackTime = .zero

                Task {
                    try await MusicPlayerType.shared.skipToPreviousEntry()
                }
            }
        } else if phases == .down {
            updatePlaybackTime(every: 0.1)
        } else if phases.contains(.repeat) {
            if playbackStatus != .seekingBackward {
                scheduledPlaybackStatus = .seekingBackward
                player.beginSeekingBackward()
            }
        }
    }

    func seek(to timeInterval: TimeInterval) {
        player.playbackTime = timeInterval
        playbackTime = timeInterval
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

    private func updatePlaybackTime(every: TimeInterval) {
        if let timerCancellable {
            timerCancellable.cancel()
        }

        timerCancellable = Timer.publish(every: every, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.playbackTime = self.player.playbackTime

                print("\(self.player.playbackTime)")
            }
    }

    func stopPlaybackTimeObservation() {
        timerCancellable?.cancel()
    }
}

extension EnvironmentValues {
    @Entry var musicPlayer: CappellaMusicPlayer = .init()
}
