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
                HStack {
                    VStack(alignment: .trailing) {

                        ForEach(section.header) { header in
                            header
                        }
                    }

                    VStack(spacing: 1.0) {
                        ForEach(section.content) { subview in
                            MenuItem {
                                subview
                            }
                        }
                    }
                }
            }
        }

        .font(.system(size: 13, weight: .regular, design: .default))
        .fontWeight(.medium)
        .fontDesign(.rounded)
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 140.0
        }

        return platterGeometry.contentFrame.width * 0.35
    }
}

extension ContainerValues {
//    @Entry var
}

#Preview(traits: .sizeThatFitsLayout) {
    Menu {
        PlaybackQueueMenuItem()
        PlaybackQueueMenuItem()
            .environment(\.isMenuItemSelected, true)

        Section {
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
        } header: {
            ArtworkView(dimension: 64)
            Text("Radical Optimism")
            Text("Dua Lipa")
        }

        Section {
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
        } header: {
            ArtworkView(dimension: 64)
            Text("Radical Optimism")
            Text("Dua Lipa")
        }
    }
    .safeAreaPadding()
    .environment(\.artworkProvider, PreviewArtworkProvider())
}
