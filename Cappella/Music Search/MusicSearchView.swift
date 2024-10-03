//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusicSearchView: View {
    typealias MusicPlayerType = ApplicationMusicPlayer
    @State private var musicSearch = MusicSearch()

    @State private var menuSelection: ResultItem.Entry.ID? = nil

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
                    PlatterMenu(selection: $menuSelection) {
                        ForEach(musicSearch.results) { resultItem in
                            makeView(
                                for: resultItem,
                                containerWidth: contentSize.width
                            )
                            .padding(.bottom, 10.0)
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

            .onChange(of: musicSearch.selection, initial: true) { _, newSelection in
                guard let newSelection else { return }
                guard newSelection.interactor == .keyboard else { return }

                self.menuSelection = newSelection.entry?.id

                withAnimation(.smooth) {
                    scrollProxy.scrollTo(
                        "group-\(newSelection.item.collection.id)",
                        anchor: .top
                    )
                }
            }

            .onChange(of: menuSelection, initial: false) { _, newMenuSelection in
                guard let resultItem = musicSearch.allResultEntries.first(where: {
                    $1.id == newMenuSelection
                }) else {
                    musicSearch.selection = nil
                    return
                }

                let newSelection = MusicSearch.Selection(
                    item: resultItem.0,
                    entry: resultItem.1,
                    .pointer
                )
                musicSearch.selection = newSelection
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

    private var headerDimension: CGFloat {
        guard let platterGeometry else {
            return 0.0
        }

        return platterGeometry.headerDimension
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
                        .lineLimit(1)
                }
            }
        } label: {
            Group {
                ArtworkView(length: 64)
                Text(resultItem.collection.title)
                    .lineLimit(4)

                if let subtitle = resultItem.collection.subtitle {
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .id("group-\(resultItem.collection.id)")
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
