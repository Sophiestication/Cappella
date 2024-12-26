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
        EmptyView()

//        PlatterMenu(selection: $selection) {
//            ForEach(queue.entries) { entry in
//                LabeledContent {
//                    Button {
//
//                    } label: {
//                        Label {
//                            Text("\(entry.title)")
//
//                            if let subtitle = entry.subtitle {
//                                Text("\(subtitle)")
//                            }
////                            Text("\(collection.subtitle) – \(collection.title)")
//                        } icon: {
//                            HStack {
//                                HStack {
//                                    reorderControl
//                                    deleteControl
//                                }
//                                .frame(width: leadingPadding - 10.0, height: 28.0)
//
//                                ArtworkView(length: 40)
//                            }
//                            .padding(.trailing, 5.0)
//                        }
//                    }
//                    .tag(entry.id)
//                } label: {
//                }
//                .environment(\.artworkProvider, entry.artwork)
//                .labelsVisibility(.hidden)
//            }
//        }
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
