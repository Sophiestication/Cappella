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

import Foundation
import Combine
import SwiftUI
import MusicKit
import Algorithms

@Observable @MainActor
final class MusicSearch {
    enum Scope: CaseIterable {
        case all
        case album
        case artist
        case song
    }

    var scope: Scope = .all {
        didSet {
            scheduleSearch()
        }
    }

    var term: String = "" {
        didSet {
            scheduleSearch()
        }
    }

    var isSearching: Bool = false
    private var searchCancellable: AnyCancellable?
    private var isSearchingPublisher = PassthroughSubject<Bool, Never>()

    private(set) var results: [ResultItem] = []
    var allResultEntries: any Sequence<(ResultItem, ResultItem.Entry)> {
        self.resultEntries
    }

    var selection: Selection? = nil

    var scheduledToPlay: Selection? = nil

    private struct RequestParameters {
        let scope: Scope
        let term: String

        typealias TokenType = Int
        let token: TokenType

        init() {
            self.term = ""
            self.scope = .all
            self.token = -1
        }

        init(_ term: String, in scope: Scope, token: TokenType) {
            self.term = term
            self.scope = scope
            self.token = token
        }
    }

    private typealias TermSubjectType = CurrentValueSubject <
        RequestParameters,
        Never
    >
    private let termSubject = TermSubjectType(RequestParameters())
    private var cancellable: AnyCancellable? = nil

    private var currentToken: Int = 0
    private var maximumToken: Int = 0

    init() {
        self.cancellable = termSubject
            .debounce(
                for: .milliseconds(500),
                scheduler: RunLoop.main
            )
            .sink { requestParameters in
                if requestParameters.term.isEmpty {
                    self.updateSearchResults(with: [], token: requestParameters.token)
                } else {
                    Task { [weak self] in
                        guard let self else { return }

                        try await self.performSearch(for: requestParameters)
                    }
                }
            }

        self.searchCancellable = isSearchingPublisher
            .debounce(
                for: .milliseconds(250),
                scheduler: RunLoop.main
            )
            .sink { [weak self] isSearching in
                self?.isSearching = isSearching
            }
    }

    private func performSearch(for requestParameters: RequestParameters) async throws {
        guard requestParameters.term.count > 1 else {
            self.updateSearchResults(with: [], token: requestParameters.token)
            return
        }

        isSearchingPublisher.send(true)
        defer {
            isSearchingPublisher.send(false)
        }

        let termComponents = requestParameters
            .term
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 1 }
        let preparedTerm = requestParameters
            .term
            .components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: " ")

        let scope = requestParameters.scope

        let limit = 10
        var results = [ResultItem]()

        if preparedTerm.isEmpty == false {
            switch scope {
            case .all:
                results = try await resultItems(
                    matching: requestParameters.term,
                    limit: limit
                )
                break
            case .album:
                results = try await resultItems(
                    matching: termComponents,
                    scope: scope,
                    limit: limit
                )
                break
            case .artist:
                results = try await resultItems(
                    for: preparedTerm,
                    scope: scope,
                    limit: limit
                )
                break
            case .song:
                results = try await resultItems(
                    for: preparedTerm,
                    scope: scope,
                    limit: limit
                )
                break
            }
        }

        results = results.sorted(using: [
            KeyPathComparator(\.collection.artistName, order: .forward),
            KeyPathComparator(\.collection.releaseDate, order: .forward),
            KeyPathComparator(\.collection.title, order: .forward)
        ])

        self.updateSearchResults(with: results, token: requestParameters.token)
    }

    private func resultItems(
        matching term: String,
        limit: Int
    ) async throws -> [ResultItem] {
        var request = MusicLibrarySearchRequest(
            term: term,
            types: [Album.self, Song.self]
        )
        request.limit = limit
        request.includeTopResults = false

        let response = try await request.response()

        var results: [ResultItem] = []

        for album in response.albums.prefix(limit) {
            if let resultItem = try await makeResultItem(for: album) {
                results.append(resultItem)
            }
        }

        for song in response.songs.prefix(limit) {
            if let resultItem = try await makeResultItem(for: song) {
                results.append(resultItem)
            }
        }

        results = results.uniqued(on: \.id)
        return results
    }

    private func resultItems(
        matching terms: [String],
        scope: Scope,
        limit: Int
    ) async throws -> [ResultItem] {
        var resultSets = [[ResultItem]]()

        for term in terms {
            let items = try await resultItems(for: term, scope: scope, limit: limit)
            resultSets.append(items)
        }

        guard let firstSet = resultSets.first else { return [] }

        var commonItems = [ResultItem]()

        for item in firstSet {
            if resultSets.dropFirst().allSatisfy({ $0.contains(where: { $0.id == item.id }) }) {
                commonItems.append(item)
            }
        }

        return commonItems
    }

    private func resultItems(
        for term: String,
        scope: Scope,
        limit: Int
    ) async throws -> [ResultItem] {
        var libraryRequest = MusicLibraryRequest<Album>()

        libraryRequest.limit = limit

        switch scope {
        case .all:
            libraryRequest.filter(text: term)
            break
        case .album:
            libraryRequest.filter(matching: \.title, contains: term)
            break
        case .artist:
            libraryRequest.filter(matching: \.artistName, contains: term)
            break
        case .song:
            return try await resultItemsBySong(
                for: term,
                limit: limit
            )
        }

        libraryRequest.sort(
            by: \.releaseDate,
            ascending: true
        )

        let response = try await libraryRequest.response()

        var results: [ResultItem] = []

        for album in response.items {
            if let resultItem = try await makeResultItem(for: album) {
                results.append(resultItem)
            }
        }

        return results
    }

    private func resultItemsBySong(
        for term: String,
        limit: Int
    ) async throws -> [ResultItem] {
        var libraryRequest = MusicLibraryRequest<Song>()

        libraryRequest.limit = limit

        libraryRequest.filter(matching: \.title, contains: term)

        libraryRequest.sort(
            by: \.artistName,
            ascending: true
        )

        let response = try await libraryRequest.response()

        var results: [ResultItem] = []

        for song in response.items {
            let detailedSong = try await song.with(
                [ .albums ],
                preferredSource: .library
            )

            if let albums = detailedSong.albums {
                for album in albums {
                    if let resultItem = try await makeResultItem(
                        for: album,
                        artwork: detailedSong.artwork
                    ) {
                        results.append(resultItem)
                    }
                }
            }
        }

        results = results.uniqued(on: \.id)
        return results
    }

    private func makeResultItem(for song: Song) async throws -> ResultItem? {
        let detailedSong = try await song.with(
            [ .albums ],
            preferredSource: .library
        )

        if let album = detailedSong.albums?.first {
            if let resultItem = try await makeResultItem(for: album, artwork: song.artwork) {
                return resultItem
            }
        }

        return nil

//        return ResultItem(
//            id: song.id,
//            collection: ResultItem.Entry(song),
//            entries: [ResultItem.Entry(song)],
//            artwork: song.artwork
//        )
    }

    private func makeResultItem(
        for album: Album,
        artwork: Artwork? = nil
    ) async throws -> ResultItem? {
        let detailedAlbum = try await album.with([ .tracks ], preferredSource: .library)

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
            id: detailedAlbum.id,
            collection: detailedAlbum,
            entries: entries,
            artwork: artwork ?? album.artwork
        )
    }

    private func scheduleSearch() {
        let request = RequestParameters(
            term,
            in: scope,
            token: requestToken()
        )
        termSubject.send(request)
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

        // TODO: Check if the current selection is still part of the result set
        self.selection = nil
    }
}

extension MusicSearch {
    typealias MusicPlayerType = ApplicationMusicPlayer
    typealias Entry = MusicPlayerType.Queue.Entry
}

extension MusicSearch {
    struct ResultItem: Identifiable {
        typealias Entry = MusicSearch.Entry

        var id: MusicItemID

        var collection: Album
        var entries: [Entry]

        var artwork: Artwork?

        init(
            id: MusicItemID,
            collection: Album,
            entries: [Entry],
            artwork: Artwork?
        ) {
            self.id = id

            self.collection = collection
            self.entries = entries

            self.artwork = artwork
        }
    }
}

extension MusicSearch {
    struct Selection: Equatable {
        enum Group {
            case collection
            case entry
        }

        enum Interactor {
            case pointer
            case keyboard
        }

        let item: ResultItem
        let entry: ResultItem.Entry?
        let interactor: Interactor

        init(
            item: ResultItem,
            entry: ResultItem.Entry? = nil,
            _ interactor: Interactor
        ) {
            self.item = item
            self.entry = entry
            self.interactor = interactor
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.item.id == rhs.item.id &&
            lhs.entry == rhs.entry &&
            lhs.interactor == rhs.interactor
        }
    }

    func selectNext(
        _ group: Selection.Group,
        using interactor: Selection.Interactor = .keyboard
    ) -> Bool {
        guard let selection else {
            guard let firstResultItem = results.first else {
                return false
            }
            
            self.selection = Selection(
                item: firstResultItem,
                entry: firstResultItem.entries.first,
                interactor
            )

            return true
        }

        var nextSelection: Selection? = nil

        if group == .collection {
            if let nextItem = results.firstAfter(where: { $0.id == selection.item.id }) {
                nextSelection = Selection(
                    item: nextItem,
                    entry: nextItem.entries.first,
                    interactor
                )
            } else {
                nextSelection = Selection(
                    item: selection.item,
                    entry: selection.item.entries.last,
                    interactor
                )
            }
        } else {
            if let nextItem = resultEntries.firstAfter(where: { $0.1 == selection.entry }) {
                nextSelection = Selection(
                    item: nextItem.0,
                    entry: nextItem.1,
                    interactor
                )
            }
        }

        if let nextSelection {
            self.selection = nextSelection
        } else if selection.entry == nil {
            guard let resultItem = results.first else {
                return false
            }

            self.selection = Selection(
                item: resultItem,
                entry: resultItem.entries.first,
                interactor
            )
        }

        return true
    }

    func selectPrevious(
        _ group: Selection.Group,
        using interactor: Selection.Interactor = .keyboard
    ) -> Bool {
        guard let selection else { return false }

        var newSelection: Selection? = nil

        if group == .collection {
            if selection.entry != selection.item.entries.first {
                newSelection = Selection(
                    item: selection.item,
                    entry: selection.item.entries.first,
                    interactor
                )
            } else {
                if let nextItem = results.firstBefore(where: { $0.id == selection.item.id }) {
                    newSelection = Selection(
                        item: nextItem,
                        entry: nextItem.entries.first,
                        interactor
                    )
                }
            }
        } else {
            if let nextItem = resultEntries.firstBefore(where: { $0.1 == selection.entry }) {
                newSelection = Selection(
                    item: nextItem.0,
                    entry: nextItem.1,
                    interactor
                )
            }
        }

        if let newSelection {
            self.selection = newSelection
            return true
        }

        return false
    }
}

fileprivate extension MusicSearch {
    struct EntrySequence<
        S: Sequence,
        T: Sequence
    >: Sequence, IteratorProtocol where S.Element == ResultItem, T.Element == S.Element.Entry {
        private var items: S.Iterator
        private var currentItem: S.Element? = nil

        private var entries: T.Iterator? = nil

        init(sequence: S) {
            self.items = sequence.makeIterator()
        }

        typealias Element = (ResultItem, ResultItem.Entry)

        mutating func next() -> Element? {
            if currentItem == nil {
                currentItem = self.items.next()
                entries = nil
            }

            guard let item = currentItem else { return nil }

            if entries == nil {
                entries = item.entries.makeIterator() as? T.Iterator
            }

            if entries == nil { return nil }

            guard let entry = entries!.next() else {
                self.currentItem = nil
                return next()
            }

            return (item, entry)
        }
    }

    var resultEntries: EntrySequence<[ResultItem], [ResultItem.Entry]> {
        return EntrySequence(sequence: self.results)
    }
}

fileprivate extension Sequence {
    func firstBefore(where predicate: (Self.Element) -> Bool) -> Element? {
        var previous: Element? = nil

        for element in self {
            if predicate(element) {
                break
            }

            previous = element
        }

        return previous
    }

    func firstAfter(where predicate: (Self.Element) -> Bool) -> Element? {
        var iterator = makeIterator()

        while let currentElement = iterator.next() {
            if predicate(currentElement) {
                return iterator.next()
            }
        }

        return nil
    }
}
