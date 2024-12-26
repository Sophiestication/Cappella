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
import AppKit
import WidgetKit
import MusicKit

struct NowPlayingStore {
    private let userDefaults: UserDefaults
    private let nowPlayingURL: URL

    private let artworkLength = 400

    init() {
        let fileManager = FileManager.default

        let applicationGroupIdentifier = Bundle.main.object(
            forInfoDictionaryKey: "SOSO_APPLICATION_GROUP_IDENTIFIER"
        ) as? String
        let applicationGroupURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: applicationGroupIdentifier!
        )!

        self.nowPlayingURL = applicationGroupURL.appendingPathComponent("NowPlaying")
        self.userDefaults = UserDefaults(suiteName: applicationGroupIdentifier)!
    }

    func update(entry: ApplicationMusicPlayer.Queue.Entry?) {
        do {
            try update(item: entry?.item)
            try update(artwork: entry?.artwork)
        } catch {
            print("Cannot update Now Playing for \(String(describing: entry))")
        }
    }

    private func update(item: ApplicationMusicPlayer.Queue.Entry.Item?) throws {
        guard let item else {
            userDefaults.removeObject(forKey: "title")
            userDefaults.removeObject(forKey: "albumTitle")
            userDefaults.removeObject(forKey: "artistName")

            return
        }

        switch item {
        case .song(let song):
            userDefaults.set(song.title, forKey: "title")
            userDefaults.set(song.albumTitle, forKey: "albumTitle")
            userDefaults.set(song.artistName, forKey: "artistName")
            break
        default:
            break
        }
    }

    private func store(color: CGColor?, forKey key: String) throws {
        if let color {
            let data = try JSONEncoder()
                .encode(CodableColor(cgColor: color))
            userDefaults.set(data, forKey: key)
        } else {
            userDefaults.removeObject(forKey: key)
        }
    }

    private func loadColor(forKey key: String) -> CGColor? {
        let data = userDefaults.data(forKey: key)

        guard let data else {
            return nil
        }

        do {
            let color = try JSONDecoder().decode(CodableColor.self, from: data)
            return color.cgColor
        } catch {
            return nil
        }
    }

    private func update(artwork: Artwork?) throws {
        let fileManager = FileManager.default

        if let artwork,
           let url = artwork.url(width: artworkLength, height: artworkLength),
           let image = NSImage(contentsOf: url) {

            try fileManager.createDirectory(
                at: nowPlayingURL,
                withIntermediateDirectories: true
            )
            try image.tiffRepresentation?.write(to: artworkURL)

            try store(color: artwork.backgroundColor, forKey: "backgroundColor")
        } else {
            do {
                try fileManager.removeItem(at: artworkURL)
            } catch {
                // ignore
            }

            userDefaults.removeObject(forKey: "backgroundColor")
        }
    }

    private var artworkURL: URL {
        nowPlayingURL.appendingPathComponent("Artwork")
    }
}

extension NowPlayingStore {
    struct Item {
        var title: String?
        var albumTitle: String?
        var artistName: String?

        var artwork: URL?

        var backgroundColor: CGColor?
    }

    var item: Item {
        Item(
            title: userDefaults.string(forKey: "title"),
            albumTitle: userDefaults.string(forKey: "albumTitle"),
            artistName: userDefaults.string(forKey: "artistName"),
            artwork: artworkURL,
            backgroundColor: loadColor(forKey: "backgroundColor")
        )
    }
}
