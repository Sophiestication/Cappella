//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct Menu<Content: View>: View {
    @Environment(\.platterGeometry) var platterGeometry

    @ViewBuilder var content: Content

    var body: some View {
        Group(sections: content) { sections in
            ForEach(sections) { section in
                VStack(alignment: .leading) {
                    ForEach(section.header) { header in
                        header
                    }
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .alignmentGuide(.leading) { guide in
                        -leadingPadding - 15.0
                    }

                    VStack(spacing: 20.0) {
                        ForEach(section.content) { subview in
                            subview
                        }
                    }
                }
            }
        }

        .labeledContentStyle(.menu)

        .font(.system(size: 13, weight: .regular, design: .default))
        .fontWeight(.medium)
        .fontDesign(.rounded)
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 180.0
        }

        return platterGeometry.contentFrame.width * 0.35
    }
}

extension ContainerValues {
//    @Entry var
}

#Preview(traits: .sizeThatFitsLayout) {
    Menu {
        Section {
            PlaybackQueueMenuItem()
            PlaybackQueueMenuItem()
                .environment(\.isMenuItemSelected, true)
        }

        Section {
            LabeledContent {
                Text("End Of An Era")
                Text("Houdini")
                Text("Training Season")
                Text("These Walls")
                Text("Whatcha Doing")
                Text("French Exit")
                Text("Illusion")
                Text("Falling Forever")
                Text("Anything For Love")
                Text("Maria")
                Text("Happy For You")
            } label: {
                ArtworkView(dimension: 64)
                Text("Radical Optimism")
                Text("Dua Lipa")
            }

            LabeledContent {
                Text("End Of An Era")
                Text("Houdini")
                Text("Training Season")
                Text("These Walls")
                Text("Whatcha Doing")
                Text("French Exit")
                Text("Illusion")
                Text("Falling Forever")
                Text("Anything For Love")
                Text("Maria")
                Text("Happy For You")
            } label: {
                ArtworkView(dimension: 64)
                Text("Radical Optimism")
                Text("Dua Lipa")
            }
        } header: {
            Text("Recently Played")
        }
    }
    .scenePadding()
    .environment(\.artworkProvider, PreviewArtworkProvider())
}
