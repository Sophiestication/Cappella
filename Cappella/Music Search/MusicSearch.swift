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
        libraryRequest.filter(
            matching: \.title,
            contains: searchTerm
        )
        libraryRequest.sort(
            by: \.libraryAddedDate,
            ascending: true
        )

        let response = try await libraryRequest.response()
        var results: [ResultItem] = []

        for album in response.items {
            if let resultItem = try await makeResultItem(for: album) {
                results.append(resultItem)
            }
        }

        self.updateSearchResults(with: results, token: token)
    }

    private func makeResultItem(for album: Album) async throws -> ResultItem? {
        let detailedAlbum = try await album.with([ .tracks ])

        guard let tracks = detailedAlbum.tracks else {
            return nil
        }

        let entries = tracks.compactMap { track -> ResultItem.Entry? in
            switch track {
            case .song(let song):
                return ResultItem.Entry(song)
            default:
                return nil
            }
        }

        return ResultItem(
            ResultItem.Entry(detailedAlbum),
            entries
        )
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
        typealias Entry = ApplicationMusicPlayer.Queue.Entry

        var collection: Entry
        var entries: [Entry]

        init(_ collection: Entry, _ entries: [Entry]) {
            self.collection = collection
            self.entries = entries
        }
    }
}
