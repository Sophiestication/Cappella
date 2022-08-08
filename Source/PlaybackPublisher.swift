//
// Copyright © 2022 Sophiestication Software. All rights reserved.
//

import SwiftUI

class PlaybackPublisher: ObservableObject {
    @Published var repeatMode: RepeatMode = .all

    @Published var shuffle: Bool = true
    @Published var shuffleMode: ShuffleMode = .song
}

extension PlaybackPublisher {
    enum RepeatMode: String, CaseIterable, Identifiable {
        case off
        case all
        case one
        
        var id: Self { self }
    }
}

extension PlaybackPublisher {
    enum ShuffleMode: String, CaseIterable, Identifiable {
        case song
        case album
        case grouping
        
        var id: Self { self }
    }
}
