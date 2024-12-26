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

struct KeyboardShortcutBezelView : View {
    let eventPublisher: AnyPublisher<GlobalKeyboardShortcutHandler.Event, Never>
    @State private var currentEvent: GlobalKeyboardShortcutHandler.Event? = nil

    typealias MusicPlayerType = CappellaMusicPlayer

    @Environment(\.musicPlayer) var musicPlayer: MusicPlayerType
    @ObservedObject private var queue = ApplicationMusicPlayer.shared.queue

    var body: some View {
        makeContentView()
            .frame(width: bezelDimension, height: bezelDimension)
            .background(
                makeBackgroundView()
            )
            .onReceive(eventPublisher) { event in
                currentEvent = event
            }
    }

    @ViewBuilder
    private func makeContentView() -> some View {
        if let event = currentEvent {
            switch event.id {
            case .playPause:
                makePlayPauseView(event.phase)
            case .fastForward:
                makeFastForwardContentView(event.phase)
            case .rewind:
                makeRewindContentView(event.phase)
            case .toggleRepeatMode:
                makeRepeatModeContentView()
            case .shuffleOnOff:
                makeShuffleModeContentView()
            case .increaseSoundVolume,
                 .decreaseSoundVolume,
                 .toggleMute:
                makeSoundVolumeContentView()
            default:
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func makePlayPauseView(_ phase: KeyPress.Phases) -> some View {
        VStack {
            switch musicPlayer.scheduledPlaybackStatus {
            case .paused:
                makePlaybackView(for: Image("pauseTemplate"), phase)
            case .playing, .seekingForward, .seekingBackward:
                makePlaybackView(for: Image("playTemplate"), phase)
            case .interrupted, .stopped:
                makePlaybackView(for: Image("stopTemplate"), phase)
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func makeFastForwardContentView(_ phase: KeyPress.Phases) -> some View {
        makePlaybackView(for: Image("fastForwardTemplate"), phase)
    }

    @ViewBuilder
    private func makeRewindContentView(_ phase: KeyPress.Phases) -> some View {
        makePlaybackView(for: Image("rewindTemplate"), phase)
    }

    @ViewBuilder
    private func makePlaybackView(for image: Image, _ phase: KeyPress.Phases) -> some View {
        VStack {
            makeImageView(for: image)

            if let entry = queue.currentEntry {
                Text(entry.title)
                    .lineLimit(1)
                    .padding(.horizontal, 10.0)
            }
        }
    }

    @ViewBuilder
    private func makeRepeatModeContentView() -> some View {
        if let repeatMode = musicPlayer.playbackState.repeatMode {
            switch repeatMode {
            case .none:
                makeImageView(for: Image("repeatModeOffTemplate"))
            case .one:
                makeImageView(for: Image("repeatModeOneTemplate"))
            case .all:
                makeImageView(for: Image("repeatModeAllTemplate"))
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func makeShuffleModeContentView() -> some View {
        if let shuffleMode = musicPlayer.playbackState.shuffleMode {
            switch shuffleMode {
            case .off:
                makeImageView(for: Image("shuffleOffTemplate"))
            case .songs:
                makeImageView(for: Image("shuffleOnTemplate"))
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func makeSoundVolumeContentView() -> some View {
        Color.clear
    }

    private static let bezelImageDimension: CGFloat = 134.0

    @ViewBuilder
    private func makeImageView(for image: Image) -> some View {
        image
            .resizable(resizingMode: .stretch)
            .aspectRatio(contentMode: .fit)
            .frame(width: Self.bezelImageDimension, height: Self.bezelImageDimension)
    }

    @ViewBuilder
    private func makeBackgroundView() -> some View {
        VisualEffectView(
            material: .hudWindow,
            blendingMode: .behindWindow,
            state: .active
        )
        .clipShape(bezelShape)
    }

    private var bezelDimension: CGFloat { 200.0 }
    private var bezelShape: some Shape {
        RoundedRectangle(
            cornerRadius: 18.0,
            style: .continuous
        )
    }
}
