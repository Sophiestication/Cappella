//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusicSearchView: View {
    @State private var musicSearch = MusicSearch()

    @State private var footerDimension = 60.0

    @FocusState private var searchfieldFocused: Bool

    private typealias MusicPlayerType = ApplicationMusicPlayer

    private typealias ResultItem = MusicSearch.ResultItem
    @State private var selectedResultItem: ResultItem? = nil
    @State private var selectedEntry: ResultItem.Entry? = nil

    @State private var currentEventModifier: EventModifiers = []

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0.0) {
                makeHeaderView(for: geometry)

                Divider()
                    .background(.thinMaterial)

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(
                        spacing: 10.0
                    ) {
                        ForEach(musicSearch.results, id: \.collection.id) { resultItem in
                            makeView(for: resultItem, containerWidth: geometry.size.width)
                        }
                    }
                    .padding(.top, 20.0)
                    .padding(.bottom, footerDimension)
                }
            }
            .onModifierKeysChanged({ old, new in
                self.currentEventModifier = new
            })
            .onKeyPress(.upArrow) { onUpArrowPress(.upArrow) }
            .onKeyPress(.downArrow) { onDownArrowPress(.downArrow) }
            .onKeyPress(.return) { onReturnPress(.return) }
        }
        .onAppear {
            musicSearch.term = "love"
            searchfieldFocused = true
        }
    }

    private func onUpArrowPress(_ keyEquivalent: KeyEquivalent) -> KeyPress.Result {
        return .handled
    }

    private func onDownArrowPress(_ keyEquivalent: KeyEquivalent) -> KeyPress.Result {
        let results = musicSearch.results

        var resultItem = self.selectedResultItem
        if resultItem == nil { resultItem = results.first }

        guard let resultItem else { return .ignored }

        var entry = self.selectedEntry

        guard let entry else {
            self.selectedResultItem = resultItem
            self.selectedEntry = resultItem.entries.first

            return .handled
        }

        guard let entryIndex = resultItem.entries.firstIndex(of: entry) else { return .ignored }

        let nextEntryIndex = resultItem.entries.index(after: entryIndex)

        return .handled
    }

    private func onReturnPress(_ keyEquivalent: KeyEquivalent) -> KeyPress.Result {
        if let resultItem = self.selectedResultItem,
           let entry = self.selectedEntry {
            play(resultItem, startingAt: entry)
            return .handled
        }

        return .ignored
    }

    @ViewBuilder
    private func makeHeaderView(for geometry: GeometryProxy) -> some View {
        Group {
            makeSearchField()
                .padding(.leading, geometry.size.width * 0.35)
        }
    }

    @ViewBuilder
    private func makeFooterView() -> some View {
        Group {
            HStack {
                Spacer()
                PlaybackView()
            }
            .padding(10.0)
            .background(
                RoundedRectangle(cornerRadius: 14.0, style: .continuous)
                    .fill(.bar)
            )
            .padding(10.0)
        }
        .containerRelativeFrame(.horizontal)
    }

    @ViewBuilder
    private func makeSearchField() -> some View {
        HStack(alignment: .center) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14.0)
                .padding(.leading, 15.0)
            TextField("", text: $musicSearch.term, prompt: Text("Search"))
                .disableAutocorrection(true)

                .textFieldStyle(.plain)

                .focused($searchfieldFocused)
        }
        .font(.system(size: 15.0, weight: .regular, design: .rounded))
        .padding(.vertical, 4.0)
        .background (
            RoundedRectangle(cornerRadius: 14.0, style: .continuous)
                .fill(.quaternary)
        )
        .padding(.vertical)
        .padding(.trailing, 15.0)
    }

    @ViewBuilder
    private func makeView(
        for resultItem: ResultItem,
        containerWidth: CGFloat
    ) -> some View {
        HStack(alignment: .top, spacing: 0.0) {
            Group {
                VStack(alignment: .trailing) {
                    makeArtworkView(for: resultItem.collection)
                    Text(resultItem.collection.title)
                        .font(.headline)
                        .lineLimit(4)

                    if let subtitle = resultItem.collection.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                .focusSection()
                .padding(.trailing, 5.0)
            }
            .frame(width: containerWidth * 0.35, alignment: .trailing)
            .multilineTextAlignment(.trailing)

            Group {
                VStack(alignment: .leading, spacing: 0.0) {
                    ForEach(resultItem.entries, id: \.id) { entry in
                        makeMenuItem(for: entry, in: resultItem)
                    }
                }
                .focusSection()
                .padding(.trailing, 5.0)
            }
            .frame(width: containerWidth * 0.65, alignment: .leading)
            .multilineTextAlignment(.leading)
        }
    }

    private static let artworkDimension: Int = 64

    @ViewBuilder
    private func makeArtworkView(for entry: ResultItem.Entry) -> some View {
        if let artwork = entry.artwork {
            ArtworkImage(
                artwork,
                width: CGFloat(Self.artworkDimension)
            )
            .cornerRadius(4.0)
        } else {
            makeArtworkPlaceholderView()
        }
    }

    @ViewBuilder
    private func makeArtworkPlaceholderView() -> some View {
        RoundedRectangle(
            cornerSize: CGSize(width: 4.0, height: 4.0),
            style: .continuous
        )
        .fill(.quaternary)
        .frame(
            width: CGFloat(Self.artworkDimension),
            height: CGFloat(Self.artworkDimension)
        )
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
        .onHover { isHovering in
            if isHovering {
                selectedResultItem = resultItem
                selectedEntry = entry
            } else {
                selectedResultItem = nil
                selectedEntry = nil
            }
        }
        .environment(\.isHighlighted, selectedEntry == entry)
    }

    private func play(_ resultItem: ResultItem, startingAt currentEntry: ResultItem.Entry) {
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
