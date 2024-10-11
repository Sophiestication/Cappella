//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import AppKit

final class StatusItemMenu {
    typealias MusicPlayerType = CappellaMusicPlayer
    private let musicPlayer: MusicPlayerType

    init(using musicPlayer: MusicPlayerType) {
        self.musicPlayer = musicPlayer
    }

    func build() -> NSMenu {
        let menu = NSMenu()

        menu.addItem(
            withTitle: playPauseTitle,
            action: #selector(playPause),
            keyEquivalent: ""
        )

        menu.addItem(
            withTitle: "Next Track",
            action: #selector(fastForward),
            keyEquivalent: ""
        )

        menu.addItem(
            withTitle: "Previous Track",
            action: #selector(rewind),
            keyEquivalent: ""
        )

        menu.addItem(NSMenuItem.separator())



        return menu
    }

    private var applicationName: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleDisplayName"
        ) as! String
    }

    private var playPauseTitle: String {
        if musicPlayer.playbackState.playbackStatus == .playing {
            return "Pause"
        }

        return "Play"
    }

    private var playbackEnabled: Bool {
        musicPlayer.queue.currentEntry != nil
    }

    @objc private func playPause() {
        musicPlayer.playPause()
    }

    @objc private func fastForward() {
        musicPlayer.fastForward()
    }

    @objc private func rewind() {
        musicPlayer.rewind()
    }
}
