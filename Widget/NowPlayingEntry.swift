//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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
