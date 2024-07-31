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

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0.0) {
                makeHeaderView(for: geometry)

                Divider()
                    .background(.thinMaterial)

                VStack {
                    ForEach(MusicPlayerType.shared.queue.entries) { entry in
                        Text("\(entry.title)")
                    }
                }

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

    @MainActor
    private func test() async {
        do {
            var libraryRequest = MusicLibraryRequest<Album>()

            libraryRequest.limit = 15
            libraryRequest.filter(
                matching: \.title,
                contains: "love"
            )
            libraryRequest.sort(
                by: \.libraryAddedDate,
                ascending: true
            )

            let response = try await libraryRequest.response()
            let firstAlbum = response.items.first!
            let secondAlbum = response.items[1]

            let player = ApplicationMusicPlayer.shared

            let detailedAlbum = try await firstAlbum.with([.tracks], preferredSource: .library)
//            let secondTrack = detailedAlbum.tracks![1]

            if let albumTracks = detailedAlbum.tracks {
                let songs = albumTracks.compactMap { track in
                    switch track {
                    case .song(let song):
                        return song
                    default:
                        return nil
                    }
                }

                let entries = songs.map { song in
                    ApplicationMusicPlayer.Queue.Entry(song)
                }

                let newQueue = ApplicationMusicPlayer.Queue([
                    ApplicationMusicPlayer.Queue.Entry(firstAlbum)
                ])

                player.queue = newQueue

                Task {
                    if player.isPreparedToPlay == false {
                        try await player.prepareToPlay()

                        print("\(player.queue.entries)")
                        player.queue.currentEntry = entries[3] // player.queue.entries[3]
                    }
                }

//                try await ApplicationMusicPlayer.shared.play()

                Task {
                    let queue = ApplicationMusicPlayer.shared.queue

                    let titles = queue.entries.map { entry in
                        entry.title
                    }
                    print("\(titles)")
                }
            }

//            let titles = detailedAlbum.tracks!.map { track in
//                switch track {
//                case .song(let song):
//                    return song.title
//                default:
//                    return "video"
//                }
//            }
//            print("\(titles)")
        } catch {
            print("\(error)")
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
            TextField("", text: $musicSearch.term, prompt: Text("Search"))
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
//        if player.queue.entries.isEmpty {
//            let newQueue = MusicPlayerType.Queue([resultItem.collection])
//            player.queue = newQueue
//        }

        Task {
            do {
//                player.queue = []
//                player.queue.entries.append(contentsOf: resultItem.entries)

//                for entry in resultItem.entries {
//                    if let item = entry.item {
//                        try await player.prepareToPlay()
//                        try await player.queue.insert(
//                            item,
//                            position: .tail
//                        )
//                    }
//                }

//                do {
//                    try await player.prepareToPlay()
//                } catch {
//
//                }

                let player = MusicPlayerType.shared

                let album = resultItem.album
                print("\(album)")

                let titles = resultItem.entries.map { entry in
                    entry.title
                }
                print("\(titles)")

                for song in resultItem.songs {
                    if let parameters = song.playParameters {
                        print("\(parameters)")
//                        MusicPlayerType.shared.queue = [ parameters ]
                    }
                }

                let newQueue = MusicPlayerType.Queue(resultItem.entries, startingAt: currentEntry)

//                let playable: PlayableMusicItem = album
//
//                var albums = [album]
//
//                let tracks = album.tracks!
//                let track = album.tracks!.last!
//
//                let newQueue = MusicPlayerType.Queue(for: tracks)
                player.queue = newQueue

//                let songs = resultItem.entries.compactMap { entry in
//                    entry.transientItem
//                }

//                let newQueue = MusicPlayerType.Queue(for: resultItem.songs, startingAt: resultItem.songs.last)
//                try await player.queue.insert(resultItem.songs.last!, position: .tail)

                Task {
                    try await player.play()

                }

//                if player.isPreparedToPlay == false {
//                    try await MusicPlayerType.shared.prepareToPlay()
//
//                    let index = MusicPlayerType.shared.queue.entries.firstIndex { entry in
//                        entry.
//                    }
//                    MusicPlayerType.shared.queue.currentEntry = MusicPlayerType.shared.queue.entries[index]
//
//                    print("play \(player.queue.currentEntry?.title)")
//                    try await MusicPlayerType.shared.play()
//                } else {
//                    MusicPlayerType.shared.queue.currentEntry = currentEntry
//
//                    print("play \(player.queue.currentEntry?.title)")
//                    try await MusicPlayerType.shared.play()
//                }

//                await MainActor.run {
//                    let newQueue = MusicPlayerType.Queue([resultItem.collection])
//                    player.queue = newQueue
//
//                    Task {
//                        if player.isPreparedToPlay == false {
//                            try await player.prepareToPlay()
//
//                            player.queue.currentEntry = player.queue.entries[3]
//                        } else {
//                            player.queue.currentEntry = currentEntry
//                        }
//                    }
//                }



//                try await player.queue.insert(
//                    resultItem.collection,
//                    position: .afterCurrentEntry
//                )


            } catch {
                print("\(error)")
            }
        }

//        Task {
//            do {
//                let player = MusicPlayerType.shared
//
//                if player.isPreparedToPlay == false {
//                    Task { try await player.prepareToPlay() }
//                }
//
//                player.queue.currentEntry = entry
//            } catch {
//                print("\(error)")
//            }
//        }
    }
}

#Preview {
    MusicSearchView()
}
