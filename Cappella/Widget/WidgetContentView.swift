//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct WidgetContentView: View {
    @Environment(\.artworkProvider) var artwork: ArtworkProviding?
    @Environment(\.pixelLength) var pixelLength

    @State var imageLength: Int = 400

    @State var title: String?
    @State var artist: String?
    @State var album: String?

    var body: some View {
        artworkImage
            .containerRelativeFrame([.horizontal, .vertical])
            .containerBackground(for: .widget) {
                placeholder
            }

            .overlay(details, alignment: .bottom)
    }

    @ViewBuilder
    private var artworkImage: some View {
        if let url {
            Image(nsImage: NSImage(byReferencing: url))
                .resizable()

//            AsyncImage(url: url) { image in
//                image
//                    .interpolation(.high)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(placeholder)
//            } placeholder: {
//                placeholder
//            }
        } else {
            placeholder
        }
    }

    @ViewBuilder
    private var placeholder: some View {
        if let backgroundColor = artwork?.backgroundColor {
            Color(cgColor: backgroundColor)
        } else {
            ContainerRelativeShape()
                .fill(.placeholder)
        }
    }

    private var url: URL? {
        artwork?.url(
            width: imageLength,
            height: imageLength
        )
    }

    @ViewBuilder
    private var details: some View {
        VStack(alignment: .leading, spacing: -1.0) {
            detailText
                .lineLimit(1, reservesSpace: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(15.0)

        .font(.system(size: 16.0, design: .rounded))
        .fontWidth(.compressed)
        .shadow(color: .black.opacity(0.75), radius: pixelLength, y: pixelLength)

        .background {
            LinearGradient(
                gradient: backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.plusDarker)
            .padding(.top, -10.0)
        }
    }

    private var backgroundGradient: Gradient {
        let colors = stride(from: 0.0, to: 0.33, by: 0.125).map { value -> Color in
            let opacity = UnitCurve.easeInOut.value(at: value)
            return Color.black.opacity(opacity)
        }

        return Gradient(colors: colors)
    }

    @ViewBuilder
    private var detailText: some View {
        if let title {
            Text(title)
                .foregroundStyle(.primary)
                .bold()
        } else {
            Text("Watcha Doing")
                .redacted(reason: .placeholder)
        }

        if let artist {
            Text(artist)
                .foregroundStyle(.secondary)
        } else {
            Text("Dua Lipa")
                .redacted(reason: .placeholder)
        }

        if let album {
            Text(album)
                .foregroundStyle(.secondary)
        } else {
            Text("Radical Optimism")
                .redacted(reason: .placeholder)
        }
    }
}

#Preview("Complete", traits: .fixedLayout(width: 328, height: 328)) {
    WidgetContentView(
        title: "Watcha Doing",
        artist: "Dua Lipa",
        album: "Radical Optimism"
    )
    .environment(\.artworkProvider, PreviewArtworkProvider())

    .frame(width: 328 / 2, height: 328 / 2)
    .scenePadding()
}

#Preview("Placeholder", traits: .fixedLayout(width: 328, height: 328)) {
    WidgetContentView(
        title: nil,
        artist: nil,
        album: nil
    )
    .environment(\.artworkProvider, PreviewArtworkProvider())

    .frame(width: 328 / 2, height: 328 / 2)
    .scenePadding()
}

