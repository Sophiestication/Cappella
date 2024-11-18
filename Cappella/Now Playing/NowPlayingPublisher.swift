//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import MusicKit

final class NowPlayingPublisher: Publisher {
    typealias Output = Item
    typealias Failure = Never

    typealias MusicPlayer = ApplicationMusicPlayer
    typealias Queue = MusicPlayer.Queue

    private let subject = PassthroughSubject<Item, Never>()
    private var cancellable: AnyCancellable?

    init() {
        self.cancellable = musicPlayer.queue
            .objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                let item = Item(entry: self?.musicPlayer.queue.currentEntry, event: .change)
                self?.subject.send(item)
            }
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }

    private var musicPlayer: MusicPlayer {
        MusicPlayer.shared
    }
}

extension NowPlayingPublisher {
    struct Item {
        let entry: MusicPlayer.Queue.Entry?
        let event: Event
    }
}

extension NowPlayingPublisher {
    enum Event {
        case selection
        case change
        case `repeat`
    }
}

extension ApplicationMusicPlayer {
    typealias NowPlaying = NowPlayingPublisher

    func nowPlayingPublisher() -> NowPlaying {
        return NowPlayingPublisher()
    }
}
