//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackQueueView: View {
    private typealias MusicPlayerType = ApplicationMusicPlayer
    @ObservedObject private var queue = MusicPlayerType.shared.queue

    private typealias Entry = MusicPlayerType.Queue.Entry

    @State private var draggedEntry: Entry? = nil
    @State private var draggedEntryOffset: CGSize = .zero

    @Environment(\.platterProxy) var platterProxy
    @Environment(\.platterGeometry) var platterGeometry

    @Environment(\.playbackQueue) var playbackQueue

    var body: some View {
        VStack {
            ForEach(queue.entries) { entry in
                makeMenuItem(for: entry)
            }
        }
        .padding(.horizontal, 10.0)
    }

    @ViewBuilder
    private func makeMenuItem(
        for entry: Entry
    ) -> some View {
        Button(action: {

        }, label: {
            HStack {
                HStack {
                    makeReorderView(for: entry)
                    makeDeleteView()
                    makeArtworkImage(for: entry)
                        .frame(
                            width: CGFloat(Self.artworkDimension),
                            height: CGFloat(Self.artworkDimension)
                        )
                }
                .frame(width: leadingPadding)

                VStack(alignment: .leading) {
                    Text(entry.title)

                    if let subtitle = entry.subtitle {
                        Text(subtitle)
                    }
                }
                .background(.red)
            }
        })
        .buttonStyle(.menu)

        .offset(entry == draggedEntry ? draggedEntryOffset : .zero)
        .zIndex(draggedEntry == entry ? 1 : 0)
    }

    private func makeDragGesture(for entry: Entry) -> some Gesture {
        DragGesture(
            minimumDistance: 0.0,
            coordinateSpace: .global
        )
        .onChanged { value in
            withAnimation(.interactiveSpring) {
                draggedEntry = entry
                draggedEntryOffset = CGSize(
                    width: 0.0,
                    height: value.translation.height
                )
            }
        }
        .onEnded { _ in
            withAnimation(.smooth) {
                draggedEntry = nil
                draggedEntryOffset = .zero
            }
        }
    }

    @ViewBuilder
    private func makeReorderView(for entry: Entry) -> some View {
        Image("reorderTemplate")
            .resizable()
            .frame(width: 18.0, height: 18.0)
            .gesture(makeDragGesture(for: entry))
    }

    @ViewBuilder
    private func makeDeleteView() -> some View {
        Button(action: {

        }, label: {
            Image("deleteTemplate")
                .resizable()
                .frame(width: 18.0, height: 18.0)
        })
        .buttonStyle(.plain)
    }

    private static let artworkDimension: Int = 42

    @ViewBuilder
    private func makeArtworkImage(for entry: Entry) -> some View {
        if let artwork = entry.artwork,
           let url = makeURL(for: artwork) {
            makeArtworkImage(for: artwork, url)
        } else {
            makePlaceholderView()
        }
    }

    @ViewBuilder
    private func makeArtworkImage(
        for artwork: Artwork,
        _ url: URL,
        dimension: Int = Self.artworkDimension
    ) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
                .clipShape(makeContentShape())
        } placeholder: {
            if let backgroundColor = artwork.backgroundColor {
                Color(cgColor: backgroundColor)
                    .clipShape(makeContentShape())
            } else {
                makePlaceholderView()
            }
        }
    }

    private func makeURL(for artwork: Artwork, dimension: Int = Self.artworkDimension) -> URL? {
        artwork.url(width: dimension, height: dimension)
    }

    private func makeContentShape() -> some Shape {
        RoundedRectangle(
            cornerSize: CGSize(width: 4.0, height: 4.0),
            style: .continuous
        )
    }

    @ViewBuilder
    private func makePlaceholderView() -> some View {
        makeContentShape()
            .fill(.quaternary)
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 0.0
        }

        return platterGeometry.contentFrame.width * 0.35 + 8.0
    }
}
