//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import MusicKit

final class PlayerPosition: ObservableObject {
    @Published var playbackTime: TimeInterval = .nan
    @Published var playbackDuration: TimeInterval = .nan

    private var cancellables = Set<AnyCancellable>()

    private typealias MusicPlayerType = ApplicationMusicPlayer
    private typealias PlaybackTimePublisher = AnyPublisher<TimeInterval, Never>
    private typealias NowPlayingPublisher = AnyPublisher<MusicPlayerType.Queue.Entry?, Never>

    init() {
        observePlaybackState()
    }

    func seek(to playbackTime: TimeInterval) {
        self.playbackTime = playbackTime
        MusicPlayerType.shared.playbackTime = playbackTime
    }

    private func observePlaybackState() {
        let state = MusicPlayerType.shared.state

        state.objectWillChange
            .receive(on: RunLoop.main)
            .map { _ in
                state.playbackStatus
            }
            .removeDuplicates()
            .map { [weak self] status -> PlaybackTimePublisher in
                guard let self = self else {
                    return Just(.nan).eraseToAnyPublisher()
                }

                return self.publisher(for: status)
            }
            .switchToLatest()
            .merge(with: nowPlayingPublisher())
            .map { playbackTime in
                playbackTime.rounded(.toNearestOrAwayFromZero)
            }
            .removeDuplicates()
            .combineLatest(playbackDurationPublisher())
            .sink { [weak self] update in
                self?.playbackTime = update.0
                self?.playbackDuration = update.1
            }
            .store(in: &cancellables)
    }

    private func publisher(for status: MusicPlayerType.PlaybackStatus) -> PlaybackTimePublisher {
        let currentPlaybackTime = Just(MusicPlayerType.shared.playbackTime)

        switch status {
        case .playing:
            return currentPlaybackTime
                .append(pollingPlaybackTimePublisher(every: 1.0))
                .eraseToAnyPublisher()

        case .seekingForward, .seekingBackward:
            return currentPlaybackTime
                .append(pollingPlaybackTimePublisher(every: 0.25))
                .eraseToAnyPublisher()

        default:
            return currentPlaybackTime
                .eraseToAnyPublisher()
        }
    }

    private func pollingPlaybackTimePublisher(
        every: TimeInterval,
        in mode: RunLoop.Mode = .common
    ) -> PlaybackTimePublisher {
        Timer.publish(every: every, on: .main, in: mode)
            .autoconnect()
            .receive(on: RunLoop.main)
            .map { _ in
                MusicPlayerType.shared.playbackTime
            }
            .eraseToAnyPublisher()
    }

    private func nowPlayingPublisher() -> PlaybackTimePublisher {
        let queue = MusicPlayerType.shared.queue

        return queue
               .objectWillChange
               .receive(on: RunLoop.main)
               .map {
                   queue.currentEntry?.startTime ?? .zero
               }
               .eraseToAnyPublisher()
    }

    private func playbackDurationPublisher() -> PlaybackTimePublisher {
        let queue = MusicPlayerType.shared.queue

        return queue
            .objectWillChange
            .receive(on: RunLoop.main)
            .map { [weak self] in
                guard let self else { return TimeInterval.nan }
                return self.playbackDuration(for: queue.currentEntry)
            }
            .eraseToAnyPublisher()
    }

    private func playbackDuration(for entry: MusicPlayerType.Queue.Entry?) -> TimeInterval {
        var duration: TimeInterval? = nil

        if let item = entry?.item {
            switch item {
            case .song(let song):
                duration = song.duration
                break
            default:
                break
            }
        }

        return duration ?? .nan
    }
}
