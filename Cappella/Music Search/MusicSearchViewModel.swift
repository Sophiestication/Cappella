//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine
import MusicKit

@Observable @MainActor
class MusicSearchViewModel: ObservableObject {
    var term: String = "" {
        didSet {
            searchTermSubject.send((term, requestToken()))
        }
    }

    var results: [Album] = []

    private typealias SubjectType = CurrentValueSubject<(String, Int), Never>
    private var searchTermSubject = SubjectType(("", -1))

    private var cancellable: AnyCancellable? = nil

    private var currentToken: Int = 0
    private var maximumToken: Int = 0

    init() {
        cancellable = searchTermSubject
            .throttle(
                for: .milliseconds(300),
                scheduler: RunLoop.main,
                latest: true
            )
            .sink { value in
                let term = value.0
                let token = value.1

                if term.isEmpty {
                    self.updateSearchResults(with: [], token: token)
                } else {
                    Task { [weak self] in
                        guard let self else { return }

                        try await self.performSearch(for: term, token: token)
                    }
                }
            }
    }

    private func requestToken() -> Int {
        maximumToken = maximumToken + 1
        return maximumToken
    }

    private func performSearch(for searchTerm: String, token: Int) async throws {
        var searchRequest = MusicLibrarySearchRequest(
            term: searchTerm,
            types: [Album.self]
        )

        searchRequest.limit = 10
        searchRequest.includeTopResults = false

        let response = try await searchRequest.response()

        var albums = [Album]()

        for album in response.albums.prefix(10) {
            let fullAlbum = try await album.with(
                .tracks,
                preferredSource: .library
            )
            albums.append(fullAlbum)
        }

        updateSearchResults(with: albums, token: token)
    }

    private func updateSearchResults(with albums: [Album], token: Int) {
        if token < currentToken { return } // ignore update

        self.currentToken = token
        self.results = albums
    }
}
