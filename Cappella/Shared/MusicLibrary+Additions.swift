//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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

    static func fetchAlbums(
        artist: String,
        preferredSource: MusicPropertySource = .library
    ) async throws -> [Album] {
        var request = MusicLibraryRequest<Album>()

        request.filter(matching: \.artistName, equalTo: artist)
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
