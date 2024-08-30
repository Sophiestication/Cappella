//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackQueueView: View {
    private typealias MusicPlayerType = ApplicationMusicPlayer
    @ObservedObject private var queue = MusicPlayerType.shared.queue

    @Environment(\.playbackQueue) var playbackQueue

    var body: some View {
        VStack {
            ForEach(queue.entries) { entry in
                Text("\(entry.title)")
            }
        }
    }
}
