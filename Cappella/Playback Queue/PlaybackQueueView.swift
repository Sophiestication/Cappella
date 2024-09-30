//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackQueueView: View {
    private typealias MusicPlayerType = ApplicationMusicPlayer
    @ObservedObject private var queue = MusicPlayerType.shared.queue

    private typealias Entry = MusicPlayerType.Queue.Entry

    @State private var selection: Entry.ID? = nil

    @Environment(\.platterProxy) var platterProxy
    @Environment(\.platterGeometry) var platterGeometry

    @Environment(\.playbackQueue) var playbackQueue

    var body: some View {
        PlatterMenu(selection: $selection) {
            ForEach(queue.entries) { entry in
                LabeledContent {
                    Button {

                    } label: {
                        Label {
                            Text("\(entry.title)")

                            if let subtitle = entry.subtitle {
                                Text("\(subtitle)")
                            }
//                            Text("\(collection.subtitle) – \(collection.title)")
                        } icon: {
                            ArtworkView(length: 40)
                        }
                    }
                    .tag(entry.id)
                } label: {
                }
                .environment(\.artworkProvider, entry.artwork)
                .labelsVisibility(.hidden)
            }
        }
    }
}
