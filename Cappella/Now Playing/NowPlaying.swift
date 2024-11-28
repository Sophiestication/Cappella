//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import MusicKit

@Observable
final class NowPlaying {
    typealias MusicPlayer = ApplicationMusicPlayer
    typealias Queue = MusicPlayer.Queue

    var queue: Queue = [] {
        didSet {
            // TODO
        }
    }

    private var musicPlayer: MusicPlayer {
        MusicPlayer.shared
    }
}

extension NowPlaying {
    struct Item {
        let entry: MusicPlayer.Queue.Entry?
        let event: Event
    }
}

extension NowPlaying {
    enum Event {
        case selection
        case change
        case `repeat`
    }
}
