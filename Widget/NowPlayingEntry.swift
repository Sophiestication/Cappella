//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import WidgetKit
import MusicKit

struct NowPlayingEntry: TimelineEntry {
    var date: Date = Date()

    var collection: Album? = nil
    var item: MusicItem? = nil
}

extension NowPlayingEntry {
    init(album: String, date: Date) async throws {
        let albums = try await Self.fetchAlbums(
            matchting: album
        )

        var album = albums.first!

        album = try await album.with([ .tracks ])

        self.collection = album
        self.item = album.tracks!.first!

        self.date = date
    }

    private static func fetchAlbums(
        matchting title: String,
        preferredSource: MusicPropertySource = .library
    ) async throws -> [Album] {
        var request = MusicLibraryRequest<Album>()

        request.filter(matching: \.title, equalTo: title)
        request.sort(by: \.releaseDate, ascending: false)

        var albums: [Album] = []

        for item in try await request.response().items {
            let detailedAlbum = try await item.with(
                [ .tracks ],
                preferredSource: preferredSource
            )

            albums.append(detailedAlbum)
        }

        return albums
    }
}
