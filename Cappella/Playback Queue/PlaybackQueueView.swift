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
                            HStack {
                                HStack {
                                    reorderControl
                                    deleteControl
                                }
                                .frame(width: leadingPadding - 10.0, height: 28.0)

                                ArtworkView(length: 40)
                            }
                            .padding(.trailing, 5.0)
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

    @ViewBuilder
    private var reorderControl: some View {
        Button(action: {

        }, label: {
            Image("reorderTemplate")
                .resizable()
                .aspectRatio(contentMode: .fit)
        })
    }

    @ViewBuilder
    private var deleteControl: some View {
        Button(action: {

        }, label: {
            Image("deleteTemplate")
                .resizable()
                .aspectRatio(contentMode: .fit)
        })
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 0.0
        }

        return platterGeometry.contentFrame.width * 0.20
    }
}
