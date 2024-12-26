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
import Combine
import MusicKit
import WidgetKit

struct NowPlayingView: View {
    @State private var authorizationStatus = MusicAuthorization.currentStatus

    typealias MusicPlayerType = CappellaMusicPlayer
    private let musicPlayer: MusicPlayerType

    private typealias PlaybackState = CappellaMusicPlayer.MusicPlayerType.State

    @ObservedObject private var playbackState: MusicPlayerType.State
    @ObservedObject private var queue: MusicPlayerType.Queue

    private let nowPlayingStore: NowPlayingStore

    init(using musicPlayer: MusicPlayerType) {
        self.musicPlayer = musicPlayer
        self.playbackState = musicPlayer.playbackState
        self.queue = musicPlayer.queue

        self.nowPlayingStore = NowPlayingStore()
    }

    var body: some View {
        Group {
            switch authorizationStatus {
            case .authorized:
                content
            default:
                Color.red
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 20.0) {
            HStack {
                if let entry = queue.currentEntry {
                    Label {
                        Text("\(entry.title)")

                        if let subtitle = entry.subtitle {
                            Text("\(subtitle)")
                        }
                    } icon: {
                        ArtworkView(length: 40)
                    }
                    .environment(\.cornerRadius, 7.0)
                    .environment(\.artworkProvider, entry.artwork)

                    .lineLimit(1)

                    .font(.system(size: 13))
                    .labelStyle(PlatterMenuLabelStyle())

                    .padding(.trailing, 5.0)
                }

                Spacer()

                playbackControls
            }

            PlayerPositionView()
        }
        .padding(.horizontal, 20.0)
        .padding(.vertical, 15.0)

        .contentShape(.interaction, ContainerRelativeShape())
        .disabled(queue.currentEntry == nil)

        .onChange(of: queue.currentEntry) { oldValue, newValue in
            updateWidget()
        }
    }

    private func updateWidget() {
        nowPlayingStore.update(entry: queue.currentEntry)
        WidgetCenter.shared.reloadAllTimelines()
    }

    @ViewBuilder
    private var playbackControls: some View {
        HStack {
            Button(action: {
            }, label: {
                Image("rewindTemplate")
            })
            .buttonRepeatAction { phases in
                musicPlayer.rewind(using: phases)
            }

            Button(action: {
            }, label: {
                Image(imageName(for: playbackState))
            })
            .buttonRepeatAction { phases in
                musicPlayer.playPause(using: phases)
            }

            Button(action: {
            }, label: {
                Image("fastForwardTemplate")
            })
            .buttonRepeatAction { phases in
                musicPlayer.fastForward(using: phases)
            }
        }
        .buttonStyle(RepeatButtonStyle())
    }

    private func imageName(for playbackState: PlaybackState) -> String {
        switch playbackState.playbackStatus {
        case .playing, .seekingBackward, .seekingForward:
            "pauseTemplate"
        case .paused:
            "playTemplate"
        default:
            "stopTemplate"
        }
    }
}

#Preview {
    NowPlayingView(using: CappellaMusicPlayer())
        .scenePadding()
}
