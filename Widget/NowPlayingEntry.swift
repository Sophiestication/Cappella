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

import WidgetKit
import MusicKit
import CoreGraphics

struct NowPlayingEntry: TimelineEntry {
    var date: Date = Date()

    var title: String? { item.title }
    var albumTitle: String? { item.albumTitle }
    var artistName: String? { item.artistName }

    var artwork: URL? { item.artwork }

    private let item: NowPlayingStore.Item

    init() {
        let store = NowPlayingStore()
        self.item = store.item
    }
}

extension NowPlayingEntry: ArtworkProviding {
    var backgroundColor: CGColor? {
        nil
    }
    
    func url(width: Int, height: Int) -> URL? {
        artwork
    }
}
