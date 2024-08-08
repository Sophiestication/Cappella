//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusicSearchView: View {
    typealias MusicPlayerType = ApplicationMusicPlayer
    @State private var musicSearch = MusicSearch()

    @State private var footerDimension = 60.0

    @FocusState private var searchFieldFocused: Bool

    private typealias ResultItem = MusicSearch.ResultItem
    @State private var selectedResultItem: ResultItem? = nil
    @State private var selectedEntry: ResultItem.Entry? = nil

    @State private var lastHoverLocation: CGPoint? = nil

    @State private var triggerdEntry: ResultItem.Entry? = nil

    @State private var currentEventModifier: EventModifiers = []

    var body: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                VStack(spacing: 0.0) {
                    makeHeaderView(for: geometry)

                    Divider()
                        .background(.thinMaterial)

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(
                            spacing: 0.0
                        ) {
                            ForEach(musicSearch.results, id: \.collection.id) { resultItem in
                                makeView(for: resultItem, containerWidth: geometry.size.width)
                                    .id(resultItem.collection.id)
                                    .padding(.top, 10.0)
                                    .scrollTargetLayout()
                            }
                        }
                        .padding(.bottom, footerDimension)
                    }
                }

                .onAppear {
                    musicSearch.term = "hell"
                    searchFieldFocused = true
                }

                .onChange(of: musicSearch.term, initial: false) {
                    self.selectedResultItem = nil
                    self.selectedEntry = nil
                }
//                .onChange(of: selectedResultItem?.collection, initial: true) {
//                    if let anchor = selectedResultItem?.collection.id {
//                        scrollProxy.scrollTo(anchor)
//                    }
//                }

                .onModifierKeysChanged({ old, new in
                    self.currentEventModifier = new
                })
                .onKeyPress(.upArrow) { onUpArrowPress(.upArrow) }
                .onKeyPress(.downArrow) { onDownArrowPress(.downArrow) }
                .onKeyPress(.return) { onReturnPress(.return) }
            }
        }
    }

    private func onUpArrowPress(_ keyEquivalent: KeyEquivalent) -> KeyPress.Result {
        let nextSelection = musicSearch.allEntries.firstBefore(where: { element in
            element.1 == self.selectedEntry
        })

        if let nextSelection {
            self.selectedResultItem = nextSelection.0
            self.selectedEntry = nextSelection.1
        }

        return .handled
    }

    private func onDownArrowPress(_ keyEquivalent: KeyEquivalent) -> KeyPress.Result {
        let nextSelection = musicSearch.allEntries.firstAfter(where: { element in
            element.1 == self.selectedEntry
        })

        if let nextSelection {
            self.selectedResultItem = nextSelection.0
            self.selectedEntry = nextSelection.1
        } else if self.selectedEntry == nil {
            guard let resultItem = musicSearch.results.first else {
                return .ignored
            }

            self.selectedResultItem = resultItem
            self.selectedEntry = resultItem.entries.first
        }

        return .handled
    }

    private func onReturnPress(_ keyEquivalent: KeyEquivalent) -> KeyPress.Result {
        if let entry = self.selectedEntry {
            self.triggerdEntry = entry
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

                .focused($searchFieldFocused)

                .onKeyPress(.tab, action: {
                    print("tab")
                    return .handled
                })
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

                    selectedResultItem = resultItem
                    selectedEntry = entry
                }
            case .ended:
                selectedResultItem = nil
                selectedEntry = nil
            }
        }
        .environment(\.isHighlighted, selectedEntry == entry)
        .environment(\.isTriggered, triggerdEntry == entry)
    }

    private func play(_ resultItem: ResultItem, startingAt currentEntry: ResultItem.Entry) {
        self.triggerdEntry = nil

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
