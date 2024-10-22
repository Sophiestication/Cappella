//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusicSearchMenuItem: View {
    private var title: String
    private var variant: String?

    init(for entry: MusicSearch.Entry) {
        let (title, variant) = Self.parseSongTitle(entry.title)
        self.title = title
        self.variant = variant
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .lineLimit(1)

            if let variant {
                Text(variant)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private static func parseSongTitle(_ title: String) -> (String, String?) {
        let regexPattern = #"\(([^)]+)\)"#

        if let regex = try? NSRegularExpression(pattern: regexPattern) {
            let nsRange = NSRange(title.startIndex..<title.endIndex, in: title)

            if let match = regex.firstMatch(in: title, options: [], range: nsRange) {
                let rangeBeforeMatch = title.startIndex..<Range(match.range, in: title)!.lowerBound

                let mainTitle = String(title[rangeBeforeMatch])
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if let styledPartRange = Range(match.range, in: title) {
                    let styledPart = String(title[styledPartRange])
                    return (mainTitle, styledPart)
                }
            }
        }

        return (title, nil)
    }
}
