//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusicSearchView: View {
    typealias MusicPlayerType = ApplicationMusicPlayer
    @State private var musicSearch = MusicSearch()

    @Environment(\.platterGeometry) var platterGeometry

    @State private var footerDimension = 60.0

    private typealias ResultItem = MusicSearch.ResultItem

    @State private var lastHoverLocation: CGPoint? = nil

    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack(spacing: 0.0) {
                LazyVStack(
                    spacing: 0.0
                ) {
                    ForEach(musicSearch.results) { resultItem in
                        makeView(
                            for: resultItem,
                            containerWidth: platterGeometry.containerSize.width
                        )
                        .padding(.top, 10.0)
                        .scrollTargetLayout()
                    }
                }
                .padding(.bottom, footerDimension)
                .id("scroll-container")
            }

            .onAppear {
                musicSearch.term = "dead"
            }

            .platterContent(id: "search-field", placement: .header) {
                MusicSearchField(with: musicSearch)
            }

            .onChange(of: musicSearch.scheduledToPlay, initial: false) { _, newSelection in
                if let newSelection {
                    play(newSelection)
                }
            }
        }
    }

    @ViewBuilder
    private func makeView(
        for resultItem: ResultItem,
        containerWidth: CGFloat
    ) -> some View {
        HStack(alignment: .top, spacing: 0.0) {
            Group {
                VStack(alignment: .trailing) {
                    MusicSearchArtworkImage(entry: resultItem.collection)
                    Text(resultItem.collection.title)
                        .font(.headline)
                        .lineLimit(4)

                    if let subtitle = resultItem.collection.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 5.0)
            }
            .frame(width: containerWidth * 0.35, alignment: .trailing)
            .multilineTextAlignment(.trailing)

            Group {
                VStack(alignment: .leading, spacing: 0.0) {
                    ForEach(resultItem.entries, id: \.id) { entry in
                        makeMenuItem(for: entry, in: resultItem)
                    }
                }
                .padding(.trailing, 5.0)
            }
            .frame(width: containerWidth * 0.65, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
    }

    @ViewBuilder
    private func makeMenuItem(
        for entry: ResultItem.Entry,
        in resultItem: ResultItem
    ) -> some View {
        Button(action: {
            play(resultItem, startingAt: entry)
        }, label: {
            Text(entry.title)
        })
        .buttonStyle(.menu)
        .onContinuousHover(coordinateSpace: .global) { phase in
            switch phase {
            case .active(let point):
                if point != lastHoverLocation {
                    lastHoverLocation = point

                    musicSearch.selection = MusicSearch.Selection(
                        collection: resultItem,
                        entry: entry
                    )
                }
            case .ended:
                musicSearch.selection = nil
            }
        }
        .environment(\.isHighlighted, musicSearch.selection?.entry == entry)
        .environment(\.isTriggered, musicSearch.scheduledToPlay?.entry == entry)
    }

    private func play(_ selection: MusicSearch.Selection) {
        play(selection.collection, startingAt: selection.entry)
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

#Preview {
    MusicSearchView()
}
