//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine
import MusicKit

struct KeyboardShortcutBezelView : View {
    let eventPublisher: AnyPublisher<GlobalKeyboardShortcutHandler.Event, Never>
    @State private var currentEvent: GlobalKeyboardShortcutHandler.Event? = nil

    @Environment(\.musicPlayer) var musicPlayer: CappellaMusicPlayer?

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
                makePlaybackContentView()
            case .nextSong,
                 .previousSong:
                makePlaybackContentView()
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
    private func makePlaybackContentView() -> some View {
        Color.clear
    }

    @ViewBuilder
    private func makeRepeatModeContentView() -> some View {
        if let repeatMode = musicPlayer?.playbackState.repeatMode {
            switch repeatMode {
            case .none:
                makeImageView(for: Image(systemName: "questionmark"))
            case .one:
                makeImageView(for: Image(systemName: "repeat.1"))
            case .all:
                makeImageView(for: Image(systemName: "repeat"))
            default:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func makeShuffleModeContentView() -> some View {
        Color.clear
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
