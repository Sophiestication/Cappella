//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import WidgetKit
import SwiftUI
import MusicKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NowPlayingEntry {
        NowPlayingEntry()
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping @Sendable (NowPlayingEntry) -> Void
    ) {
        completion(NowPlayingEntry())
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<NowPlayingEntry>) -> Void
    ) {
        Task {
            do {
                let entry = try await NowPlayingEntry(album: "Future Nostalgia", date: Date())
                let timeline = Timeline(entries: [entry], policy: .never)

                completion(timeline)
            } catch {
                print("Error fetching timeline entry: \(error)")
            }
        }
    }
}

struct CappellaWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "StaticWidget",
            provider: Provider()
        ) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Now Playing")
        .description("Displays the current track and album artwork.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    CappellaWidget()
} timeline: {
    NowPlayingEntry()
}
