//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import MusicKit

@Observable @MainActor
class MusicSearch {
    enum Scope: CaseIterable {
        case all
        case album
        case artist
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

    private(set) var results: [ResultItem] = []

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
            .throttle(
                for: .milliseconds(300),
                scheduler: RunLoop.main,
                latest: true
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
    }

    private func performSearch(for requestParameters: RequestParameters) async throws {
        let termComponents = requestParameters
            .term
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 1 }
        let preparedTerm = termComponents
            .joined(separator: " ")

        let scope = requestParameters.scope

        var results = [ResultItem]()

        if preparedTerm.isEmpty == false {
            switch scope {
            case .all:
                let albumResults = try await resultItems(matching: termComponents, scope: .album)
                let artistResults = try await resultItems(for: preparedTerm, scope: .artist)

                results = [albumResults, artistResults]
                    .flatMap { $0 }
                    .reduce(into: [ResultItem]()) { newValue, item in
                        if newValue.contains(where: {
                            $0.id == item.id
                        }) == false {
                            newValue.append(item)
                        }
                    }
                break
            case .album:
                results = try await resultItems(matching: termComponents, scope: scope)
                break
            case .artist:
                results = try await resultItems(for: preparedTerm, scope: scope)
                break
            }
        }

        results = results.sorted(by: { first, second in
            guard let firstSubtitle = first.collection.subtitle,
                  let secondSubtitle = second.collection.subtitle else {
                return first.collection.title < second.collection.title
            }

            return firstSubtitle < secondSubtitle
        })

        self.updateSearchResults(with: results, token: requestParameters.token)
    }

    private func resultItems(
        matching terms: [String],
        scope: Scope,
        limit: Int = 15
    ) async throws -> [ResultItem] {
        var resultSets = [[ResultItem]]()

        for term in terms {
            let items = try await resultItems(for: term, scope: scope, limit: limit)
//            print("\(term): \(items.map { $0.collection.title })")
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
        limit: Int = 15
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
        }

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

        return results
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
            id: detailedAlbum.id,
            collection: ResultItem.Entry(detailedAlbum),
            entries: entries
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
    }
}

extension MusicSearch {
    struct ResultItem: Identifiable {
        typealias Entry = ApplicationMusicPlayer.Queue.Entry

        var id: MusicItemID

        var collection: Entry
        var entries: [Entry]

        init(id: MusicItemID, collection: Entry, entries: [Entry]) {
            self.id = id

            self.collection = collection
            self.entries = entries
        }
    }
}

extension MusicSearch {
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

    var allEntries: EntrySequence<[ResultItem], [ResultItem.Entry]> {
        return EntrySequence(sequence: self.results)
    }
}

extension Sequence {
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
