//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit
import Combine
import Variablur

struct MusicSearchView: View {
    @State private var musicSearch = MusicSearch()

    @State private var headerDimension = 60.0
    @State private var footerDimension = 60.0

    @FocusState private var searchfieldFocused: Bool

    private typealias MusicPlayerType = ApplicationMusicPlayer

    private typealias ResultItem = MusicSearch.ResultItem
    @State private var selectedResultItem: ResultItem? = nil
    @State private var selectedEntry: ResultItem.Entry? = nil

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
        }
        .onAppear {
            musicSearch.term = "love"
            searchfieldFocused = true
        }
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
            TextField("", text: $musicSearch.term, prompt: Text("Cappella"))
                .disableAutocorrection(true)

                .textFieldStyle(.plain)

                .focused($searchfieldFocused)

                .onKeyPress(.downArrow) {
                    .handled
                }
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
                width: CGFloat(MusicSearchView.artworkDimension)
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
            width: CGFloat(MusicSearchView.artworkDimension),
            height: CGFloat(MusicSearchView.artworkDimension)
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

    private func play(_ resultItem: ResultItem, startingAt entry: ResultItem.Entry) {
        let player = MusicPlayerType.shared

        player.queue = MusicPlayerType.Queue(
            resultItem.entries,
            startingAt: entry
        )

        Task {
            try await player.play()
        }
    }
}

#Preview {
    MusicSearchView()
}
