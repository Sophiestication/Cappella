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
