//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import MusicKit

extension MusicLibrary {
    static func fetchAlbums(
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
