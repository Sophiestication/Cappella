//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import MusicKit

@Observable @MainActor
class CappellaMusicPlayer {
    private var cancellables = Set<AnyCancellable>()

    private var scheduledPlayback: ScheduledPlayback? = nil
    private var scheduledCurrentEntry: MusicPlayerType.Queue.Entry? = nil

    typealias MusicPlayerType = ApplicationMusicPlayer
    private(set) var currentEntry: MusicPlayerType.Queue.Entry? = nil

    init() {
        observePlaybackQueue() // TODO
    }

    func playPause() {
        let player = MusicPlayerType.shared

        if player.state.playbackStatus != .playing {
            Task {
                print("\(MusicPlayerType.shared.queue.currentEntry!)")
                try await MusicPlayerType.shared.play()
            }
        } else {
            player.pause()
        }
    }

    private struct ScheduledPlayback {
        let item: ResultItem
        let currentEntryIndex: Int?
    }

    typealias ResultItem = MusicSearch.ResultItem
    func schedulePlayback(for resultItem: ResultItem, startingAt currentEntry: ResultItem.Entry? = nil) {
        let newQueue = MusicPlayerType.Queue([resultItem.collection])

//        let newQueue = MusicPlayerType.Queue(resultItem.entries, startingAt: currentEntry)
//        MusicPlayerType.shared.queue = newQueue

        var scheduledEntryIndex: Int? = nil

        if let currentEntry {
            scheduledEntryIndex = resultItem
                .entries
                .firstIndex(of: currentEntry)
        }

        self.scheduledPlayback = ScheduledPlayback(
            item: resultItem,
            currentEntryIndex: scheduledEntryIndex
        )

        MusicPlayerType.shared.queue = newQueue

        Task {
            try await MusicPlayerType.shared.prepareToPlay()
        }
    }

    private func observePlaybackQueue() {
        let player = MusicPlayerType.shared

        player.queue
            .objectWillChange
            .sink { [weak self] in
                guard let self else { return }

                self.onCurrentEntryChange()
                self.scheduleCurrentEntryIfNeeded()
                self.playScheduledEntryIfNeeded()
            }
            .store(in: &cancellables)
    }

    private func onCurrentEntryChange() {
        if self.scheduledPlayback != nil {
            return
        }

        if self.scheduledCurrentEntry != nil {
            return
        }

        let queue = MusicPlayerType.shared.queue

        if let currentEntry = queue.currentEntry {
            if self.currentEntry == currentEntry {
                return
            }

            if currentEntry.isTransient == true {
                return
            }

            if MusicPlayerType.shared.isPreparedToPlay {
                print("\(currentEntry.title)")
                self.currentEntry = currentEntry

//                Task {
//                    print("\(MusicPlayerType.shared.queue.currentEntry!.title)")
//                    try await MusicPlayerType.shared.play()
//                }
            }
        }
    }

    private func scheduleCurrentEntryIfNeeded() {
        guard let scheduledPlayback = self.scheduledPlayback else {
            return
        }

        guard (self.scheduledCurrentEntry == nil) else {
            return
        }

        let queue = MusicPlayerType.shared.queue

        let scheduledEntries = scheduledPlayback.item.entries
        let entriesAreEqual = queue
            .entries
            .elementsEqual(scheduledEntries, by: { entry, scheduledEntry in
            guard (entry.isTransient == false) else { return false }
            return entry.title == scheduledEntry.title
        })

        guard (entriesAreEqual == true) else {
            return
        }

        if let index = scheduledPlayback.currentEntryIndex {
            let scheduledCurrentEntry = queue.entries[index]

            if queue.currentEntry != scheduledCurrentEntry {
                self.scheduledCurrentEntry = scheduledCurrentEntry
                self.scheduledPlayback = nil

                print("\(scheduledCurrentEntry.title)")
                print("transient \(scheduledCurrentEntry.isTransient)")

                queue.currentEntry = scheduledCurrentEntry
            }
        }
    }

    private func playScheduledEntryIfNeeded() {
        guard self.scheduledPlayback == nil else {
            return
        }

        guard let scheduledCurrentEntry = self.scheduledCurrentEntry else {
            return
        }

        let player = MusicPlayerType.shared
        let queue = player.queue

        if scheduledCurrentEntry.isTransient == false &&
           queue.currentEntry == scheduledCurrentEntry {
            self.scheduledCurrentEntry = nil

            Task {
                print("\(MusicPlayerType.shared.queue.titles)")
//                try await MusicPlayerType.shared.play()
            }
        }
    }
}

extension ApplicationMusicPlayer.Queue {
    var titles: [String] {
        return self.entries.map { entry in
            if self.currentEntry?.title == entry.title {
                "* " + entry.title
            } else {
                entry.title
            }
        }
    }
}
