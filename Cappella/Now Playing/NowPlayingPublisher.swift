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
