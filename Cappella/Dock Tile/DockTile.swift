//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import MusicKit
import SwiftUI
import AppKit

@Observable @MainActor
final class DockTile: NSObject, NSMenuDelegate {
    var menu: NSMenu? {
        makeMenu(for: queue)
    }

    typealias MusicPlayerType = CappellaMusicPlayer
    private var musicPlayer: MusicPlayerType

    private typealias MusicPlayerQueue = ApplicationMusicPlayer.Queue
    private var queue = ApplicationMusicPlayer.shared.queue
    private var cancellable: AnyCancellable? = nil

    init(using musicPlayer: MusicPlayerType) {
        self.musicPlayer = musicPlayer
//        self.cancellable = queue
//            .objectWillChange
//            .receive(on: RunLoop.main)
//            .sink { [weak self] in
//                if let self {
//                    print("dock tile needs update")
//                }
//            }
    }

    private func makeMenu(for queue: MusicPlayerQueue) -> NSMenu? {
        let entries = queue.entries
        let currentEntry = queue.currentEntry

        let headerItems = makeHeaderItems(for: entries, currentEntry)

        let entryItems = entries.compactMap { entry in
            makeEntryMenuItem(for: entry, currentEntry)
        }

        let menu = NSMenu(title: "")

        menu.items = [
            headerItems,
            entryItems
        ]
        .flatMap { $0 }

        menu.delegate = self

        return menu
    }

    private func makeHeaderItems(
        for entries: MusicPlayerQueue.Entries,
        _ currentEntry: MusicPlayerQueue.Entry? = nil
    ) -> [NSMenuItem] {
        guard entries.isEmpty == false else { return [] }

        var headerItems: [NSMenuItem] = []

        let nowPlayingTitle = NSMenuItem(
            title: NSLocalizedString("NOWPLAYING_MENUITEM", comment: "Now Playing"),
            action: nil,
            keyEquivalent: ""
        )
        headerItems.append(nowPlayingTitle)

        if let currentEntry,
           let item = currentEntry.item {
            switch item {
            case .song(let song):
                if let albumTitle = song.albumTitle {
                    let albumItem = NSMenuItem(
                        title: "  \(albumTitle)",
                        action: nil,
                        keyEquivalent: ""
                    )
                    headerItems.append(albumItem)
                }

                let artistItem = NSMenuItem(
                    title: "  \(song.artistName)",
                    action: nil,
                    keyEquivalent: ""
                )
                headerItems.append(artistItem)
            default:
                break
            }
        }

        headerItems.append(NSMenuItem.separator())

        return headerItems
    }

    private func makeEntryMenuItem(
        for entry: MusicPlayerQueue.Entry,
        _ currentEntry: MusicPlayerQueue.Entry? = nil
    ) -> NSMenuItem? {
        let menuItem = NSMenuItem(
            title: entry.title,
            action: #selector(ApplicationDelegate.playEntry(_:)),
            keyEquivalent: ""
        )

        menuItem.representedObject = entry

        if let currentEntry {
            menuItem.state = entry.id == currentEntry.id ? .on : .off
        }

        return menuItem
    }
}
