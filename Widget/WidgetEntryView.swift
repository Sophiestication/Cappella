//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetContentView(
            title: nil,
            artist: artist,
            album: album
        )
        .environment(\.artworkProvider, entry.collection?.artwork)
    }

    private var artist: String {
        entry.collection?.artistName ?? ""
    }

    private var album: String {
        entry.collection?.title ?? ""
    }
}

#Preview {
    WidgetEntryView(entry: NowPlayingEntry())
}
