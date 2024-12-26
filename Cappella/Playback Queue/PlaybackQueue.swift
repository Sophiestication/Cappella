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
import MusicKit
import SwiftUI

@Observable @MainActor
final class PlaybackQueue {
    private typealias MusicPlayerType = ApplicationMusicPlayer

    private var queue = MusicPlayerType.shared.queue
    private var cancellable: AnyCancellable? = nil

    init() async throws {
        try await restoreState()

        cancellable = queue
            .objectWillChange
            .throttle(
                for: .seconds(1),
                scheduler: RunLoop.main,
                latest: true
            )
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                if let self {
                    self.saveState()
                }
            }
    }

    func saveState() {
        let defaults = UserDefaults.standard
        let entries = queue.entries

        let identifiers = entries.compactMap { (entry) -> String? in
            guard let item = entry.item else { return nil }
            return item.id.rawValue
        }
        defaults.set(identifiers, forKey: Self.entriesKey)

        if let currentEntry = queue.currentEntry,
           let currentEntryIndex = entries.firstIndex(where: { $0.id == currentEntry.id }) {
            defaults.set(currentEntryIndex, forKey: Self.currentEntryKey)
        } else {
            defaults.removeObject(forKey: Self.currentEntryKey)
        }
    }

    func restoreState() async throws {
        let defaults = UserDefaults.standard

        let rawIdentifiers = defaults.stringArray(forKey: Self.entriesKey)
        guard let rawIdentifiers else { return }
        guard rawIdentifiers.isEmpty == false else { return }

        let identifiers = rawIdentifiers.map {
            MusicItemID($0)
        }

        var libraryRequest = MusicLibraryRequest<Song>()

        libraryRequest.filter(matching: \.id, memberOf: identifiers)

        let entries = try await libraryRequest
            .response()
            .items
            .map { song in
                MusicPlayerType.Queue.Entry(song)
            }

        var currentEntry: MusicPlayerType.Queue.Entry? = nil

        if let indexString = defaults.string(forKey: Self.currentEntryKey),
           let index = Int(indexString) {
            if entries.indices.contains(index) {
                currentEntry = entries[index]
            }
        }

        MusicPlayerType.shared.queue = MusicPlayerType.Queue(entries, startingAt: currentEntry)

        do {
            try await MusicPlayerType.shared.prepareToPlay()
        } catch {
            print("\(error)")

            MusicPlayerType.shared.queue = []
        }
    }

    private static let entriesKey = "playbackQueue.entries"
    private static let currentEntryKey = "playbackQueue.currentEntry"
}

extension EnvironmentValues {
    @Entry var playbackQueue: PlaybackQueue? = nil
}
