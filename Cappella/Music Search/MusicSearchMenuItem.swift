//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct MusicSearchMenuItem: View {
    private enum TextContent {
        case primary(String)
        case secondary(String)
    }
    private var contentParts: [TextContent]

    init(for entry: MusicSearch.Entry) {
        self.contentParts = Self.parseSongTitle(entry.title)
    }

    var body: some View {
        textContent
    }

    private var textContent: some View {
        HStack(spacing: 0.0) {
            ForEach(contentParts.indices, id: \.self) { index in
                switch contentParts[index] {
                case .primary(let text):
                    Text(text)
                case .secondary(let text):
                    Text(text)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .lineLimit(1)
    }

    private static func parseSongTitle(_ title: String) -> [TextContent] {
        let regexPattern = #"(?<=\S)\s*(\(([^)]+)\)|\[(.*?)\])"#
        var contentParts: [TextContent] = []

        if let regex = try? NSRegularExpression(pattern: regexPattern) {
            let nsRange = NSRange(title.startIndex..<title.endIndex, in: title)
            var lastRangeEnd = title.startIndex

            let matches = regex.matches(in: title, options: [], range: nsRange)

            for match in matches {
                guard let matchRange = Range(match.range, in: title) else { continue }

                if lastRangeEnd < matchRange.lowerBound {
                    let primaryPart = String(title[lastRangeEnd..<matchRange.lowerBound])
                    contentParts.append(.primary(primaryPart))
                }

                let secondaryPart = String(title[matchRange])
                contentParts.append(.secondary(secondaryPart))

                lastRangeEnd = matchRange.upperBound
            }

            if lastRangeEnd < title.endIndex {
                let primaryPart = String(title[lastRangeEnd..<title.endIndex])
                contentParts.append(.primary(primaryPart))
            }
        } else {
            contentParts.append(.primary(title))
        }

        return contentParts
    }
}
