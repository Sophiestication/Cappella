//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusicSearchView: View {
    typealias MusicPlayerType = ApplicationMusicPlayer
    @State private var musicSearch = MusicSearch()

    @State private var menuSelection: ResultItem.Entry.ID? = nil
    @State private var triggeredMenuItem: ResultItem.Entry.ID? = nil

    private typealias ResultItem = MusicSearch.ResultItem

    @Environment(\.platterProxy) var platterProxy
    @Environment(\.platterGeometry) var platterGeometry

    @Environment(\.pointerBehavior) var pointerBehavior

    @Environment(\.musicPlayer) private var musicPlayer

    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack(
                spacing: 0.0
            ) {
                PlatterMenu(
                    selection: $menuSelection,
                    triggered: $triggeredMenuItem
                ) {
                    ForEach(musicSearch.results) { resultItem in
                        makeView(
                            for: resultItem,
                            containerWidth: contentSize.width
                        )
                        .padding(.bottom, 10.0)
                    }
                }
            }
            .padding(.horizontal)

            .onAppear {
                musicSearch.term = ""
            }

            .platterContent(id: "search-field", placement: .header) {
                HStack(spacing: 0.0) {
                    MusicSearchField(with: musicSearch)
                    ApplicationMenuButton(using: musicPlayer)
                }
            }

            .platterContent(id: "now-playing", placement: .docked) {
                NowPlayingView(using: musicPlayer)
            }

            .onChange(of: musicSearch.scheduledToPlay, initial: false) { _, newSelection in
                if let newSelection {
                    triggeredMenuItem = newSelection.entry?.id
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
                        anchor: .zero
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
                    MusicSearchMenuItem(for: entry)
                }
            }
        } label: {
            VStack(alignment: .trailing) {
                ArtworkView(length: 96)
                    .environment(\.cornerRadius, 12.0)
                    .background(content: {
                        Color.clear
                            .id("group-\(resultItem.collection.id)")
                    })

                Text(resultItem.collection.title)
                    .lineLimit(4)

                if let subtitle = resultItem.collection.subtitle {
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.bottom, 20.0)
        }
        .environment(\.artworkProvider, resultItem.artwork)
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
