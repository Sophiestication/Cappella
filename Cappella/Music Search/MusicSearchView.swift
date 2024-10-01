//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusicSearchView: View {
    typealias MusicPlayerType = ApplicationMusicPlayer
    @State private var musicSearch = MusicSearch()

    @State private var selection: ResultItem.Entry.ID? = nil

    private typealias ResultItem = MusicSearch.ResultItem

    @Environment(\.platterProxy) var platterProxy
    @Environment(\.platterGeometry) var platterGeometry

    @Environment(\.musicPlayer) private var musicPlayer

    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack(
                spacing: 0.0
            ) {
                if hasSearchTerm {
                    PlatterMenu(selection: $selection) {
                        ForEach(musicSearch.results) { resultItem in
                            makeView(
                                for: resultItem,
                                containerWidth: contentSize.width
                            )
                            .padding(.vertical, 10.0)
                        }
                    }
                } else {
                    PlaybackQueueView()
                }
            }
            .padding(.horizontal)

            .onAppear {
                musicSearch.term = "Zombie"
            }

            .platterContent(id: "search-field", placement: .header) {
                MusicSearchField(with: musicSearch)
            }

            .platterContent(id: "now-playing", placement: .docked) {
                if let musicPlayer {
                    NowPlayingView(using: musicPlayer)
                }
            }

            .onChange(of: musicSearch.scheduledToPlay, initial: false) { _, newSelection in
                if let newSelection {
                    play(newSelection)
                }
            }

            .onChange(of: musicSearch.selection) { _, newSelection in
                guard let newSelection else { return }
                guard newSelection.interactor == .keyboard else { return }

                withAnimation(.smooth) {
                    scrollProxy.scrollTo(newSelection.item.id)
                }
            }

            .platterKeyboardShortcut(using: .musicSearch)
        }
    }

    private var hasSearchTerm: Bool {
        musicSearch.term.isEmpty == false
    }

    private var contentSize: CGSize {
        guard let platterGeometry else {
            return .zero
        }

        return platterGeometry.contentFrame.size
    }

    @ViewBuilder
    private func makeView(
        for resultItem: ResultItem,
        containerWidth: CGFloat
    ) -> some View {
        LabeledContent {
            ForEach(resultItem.entries) { entry in
                Button {
                    invokeMenuItem(for: entry, in: resultItem)
                } label: {
                    Text(entry.title)
                }
                .tag(entry.id)
            }
        } label: {
            ArtworkView(length: 64)
            Text(resultItem.collection.title)
                .lineLimit(4)

            if let subtitle = resultItem.collection.subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .environment(\.artworkProvider, resultItem.collection.artwork)
    }

    private func invokeMenuItem(
        for entry: ResultItem.Entry,
        in resultItem: ResultItem
    ) {
        play(resultItem, startingAt: entry)
        musicSearch.selection = nil
    }

    private func play(_ selection: MusicSearch.Selection) {
        play(selection.item, startingAt: selection.entry)
    }

    private func play(_ resultItem: ResultItem, startingAt currentEntry: ResultItem.Entry?) {
        musicSearch.scheduledToPlay = nil

        let newQueue = MusicPlayerType.Queue(resultItem.entries, startingAt: currentEntry)
        MusicPlayerType.shared.queue = newQueue

        Task {
            try await MusicPlayerType.shared.play()
        }
    }
}
