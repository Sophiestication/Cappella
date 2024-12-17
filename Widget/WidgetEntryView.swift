//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct WidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        WidgetContentView(
            widgetFamily: widgetFamily,
            title: entry.title,
            artist: entry.artistName,
            album: entry.albumTitle
        )
        .environment(\.artworkProvider, entry)
    }
}

#Preview {
    WidgetEntryView(entry: NowPlayingEntry())
}
