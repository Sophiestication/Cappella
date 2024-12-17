//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit
import MusicKit
import WidgetKit

struct WidgetContentView: View {
    @Environment(\.artworkProvider) var artwork: ArtworkProviding?
    @Environment(\.pixelLength) var pixelLength

    @State var widgetFamily: WidgetFamily

    @State var imageLength: Int = 400

    @State var title: String?
    @State var artist: String?
    @State var album: String?

    var body: some View {
        if widgetFamily == .systemSmall {
            smallBody
        } else {
            mediumBody
        }
    }

    @ViewBuilder
    private var smallBody: some View {
        artworkImage
            .aspectRatio(contentMode: .fill)
            .containerRelativeFrame([.horizontal, .vertical])
            .containerBackground(for: .widget) {
                placeholder
            }
            .overlay(details, alignment: .bottom)
    }

    @ViewBuilder
    private var mediumBody: some View {
        HStack(alignment: .top, spacing: 0.0) {
            artworkImage
                .aspectRatio(contentMode: .fit)
                .containerRelativeFrame(.vertical)

            VStack(spacing: 0.0) {
                VStack(alignment: .leading, spacing: 1.0) {
                    Group {
                        titleText
                        artistText
                        albumText
                    }
                }

                .font(.system(size: 14.0, design: .rounded))
                .fontWidth(.compressed)
                .shadow(color: .black.opacity(0.75), radius: pixelLength, y: pixelLength)

                .padding(.top, 20.0)
                .padding(.horizontal, 10.0)

                Spacer()

                HStack(spacing: 5.0) {
                    Spacer()

                    rewind
                    playPause
                    fastForward

                    Spacer()
                }
                .padding(.bottom, 20.0)
            }
        }
        .containerRelativeFrame(.horizontal)
        .containerBackground(for: .widget) {
            Color(white: 0.125)
        }
    }

    private var rewind: some View {
        makePlaybackButton("backward.fill")
    }

    private var playPause: some View {
        makePlaybackButton("pause.fill")
    }

    private var fastForward: some View {
        makePlaybackButton("forward.fill")
    }

    private func makePlaybackButton(_ image: String) -> some View {
        let length = 10.0

        return Button {
            if let customSound = NSSound(named: NSSound.Name("Submarine")) {
                customSound.play()
            }

            Task {
                try await PlayPauseIntent().perform()
            }
        } label: {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: length, height: length)
                .padding(14.0)
        }
        .buttonStyle(WidgetButtonStyle())
    }

    @ViewBuilder
    private var artworkImage: some View {
        if let url {
            Image(nsImage: NSImage(byReferencing: url))
                .interpolation(.high)
                .resizable()
                .background(placeholder)
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
                .fill(Color("WidgetBackground"))
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
        VStack(alignment: .leading, spacing: 1.0) {
            Group {
                titleText
                artistText
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(15.0)

        .font(.system(size: 14.0, design: .rounded))
        .fontWidth(.compressed)
        .shadow(color: .black.opacity(0.75), radius: pixelLength, y: pixelLength)

        .background {
            LinearGradient(
                gradient: backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.top, -60.0)
            .blendMode(.darken)
        }
    }

    private var backgroundColor: Color {
        if let backgroundColor = artwork?.backgroundColor {
            Color(cgColor: backgroundColor)
        } else {
            .black
        }
    }

    private var backgroundGradient: Gradient {
        let colors = stride(from: 0.0, to: 0.60, by: 0.25).map { value -> Color in
            let opacity = UnitCurve.easeInOut.value(at: value)
            return backgroundColor.opacity(opacity)
        }

        return Gradient(colors: colors)
    }

    @ViewBuilder
    private var titleText: some View {
        if let title {
            Text(title)
                .lineLimit(2)
                .foregroundStyle(.primary)
                .bold()
        } else {
            Text("Watcha Doing")
                .redacted(reason: .placeholder)
        }
    }

    @ViewBuilder
    private var artistText: some View {
        if let artist {
            Text(artist)
                .lineLimit(1, reservesSpace: true)
                .foregroundStyle(.secondary)
        } else {
            Text("Dua Lipa")
                .redacted(reason: .placeholder)
        }
    }

    @ViewBuilder
    private var albumText: some View {
        if let album {
            Text(album)
                .lineLimit(1, reservesSpace: true)
                .foregroundStyle(.secondary)
        } else {
            Text("Radical Optimism")
                .redacted(reason: .placeholder)
        }
    }
}

#Preview("systemSmall") {
    WidgetContentView(
        widgetFamily: .systemSmall,
        title: "Smoke Gets in Your Eye",
        artist: "Dua Lipa",
        album: "Radical Optimism"
    )
    .environment(\.artworkProvider, PreviewArtworkProvider())

    .frame(width: 165, height: 165)
}

#Preview("systemMedium") {
    WidgetContentView(
        widgetFamily: .systemMedium,
        title: "Smoke Gets in Your Eye",
        artist: "Dua Lipa",
        album: "Radical Optimism"
    )
    .environment(\.artworkProvider, PreviewArtworkProvider())

    .frame(width: 344, height: 165)
}

#Preview("Placeholder") {
    WidgetContentView(
        widgetFamily: .systemSmall,
        title: nil,
        artist: nil,
        album: nil
    )
//    .environment(\.artworkProvider, PreviewArtworkProvider())

    .frame(width: 165, height: 165)
    .scenePadding()
}

