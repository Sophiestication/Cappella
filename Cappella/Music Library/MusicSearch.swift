//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import MusicKit

@Observable @MainActor
class MusicSearch {
    var term: String = "" {
        didSet {
            termSubject.send((term, requestToken()))
        }
    }

    private(set) var results: [ResultItem] = []

    private typealias TermSubjectType = CurrentValueSubject <
        (String, Int),
        Never
    >
    private let termSubject = TermSubjectType(("", -1))
    private var cancellable: AnyCancellable? = nil

    private var currentToken: Int = 0
    private var maximumToken: Int = 0

    init() {
        self.cancellable = termSubject
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

    private func performSearch(for searchTerm: String, token: Int) async throws {
        var libraryRequest = MusicLibraryRequest<Album>()

        libraryRequest.limit = 15
        libraryRequest.filter(matching: \.title, contains: searchTerm)
        libraryRequest.sort(by: \.libraryAddedDate, ascending: true)

        let response = try await libraryRequest.response()
    }

    private func requestToken() -> Int {
        if maximumToken == .max {
            maximumToken = 0
        }

        maximumToken = maximumToken + 1
        return maximumToken
    }

    private func updateSearchResults(with items: [ResultItem], token: Int) {
        if token < currentToken { return } // ignore update

        self.currentToken = token
        self.results = items
    }
}

extension MusicSearch {
    struct ResultItem {
        typealias Entry = MusicPlayer.Queue.Entry

        var collectionEntry: Entry
        var entries: [Entry]

        init(with album: Album) async throws {
            let detailedAlbum = try await album.with([ .tracks ])

            guard let tracks = detailedAlbum.tracks else {
                self.collectionEntry = Entry(album)
                self.entries = []

                return
            }

            let entries = tracks.compactMap { track -> Entry? in
                switch track {
                case .song(let song):
                    return Entry(song)
                default:
                    return nil
                }
            }

            self.collectionEntry = Entry(album)
            self.entries = entries
        }
    }
}
