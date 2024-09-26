//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackQueueMenuItem: View {
    var body: some View {
        MenuItem {
            titleView
                .foregroundStyle(.primary)
            subtitleView
                .foregroundStyle(.secondary)
        } label: {
            artworkView
        } accessory: {
            reorderControl
            deleteControl
        }
    }

    @ViewBuilder
    private var reorderControl: some View {
        Button(action: {

        }, label: {
            Image("reorderTemplate")
                .resizable()
        })
    }

    @ViewBuilder
    private var deleteControl: some View {
        Button(action: {

        }, label: {
            Image("deleteTemplate")
                .resizable()
        })
    }

    @ViewBuilder
    private var artworkView: some View {
        ArtworkView(dimension: 40.0)
    }

    @ViewBuilder
    private var titleView: some View {
        Text("End of An Era")
    }

    @ViewBuilder
    private var subtitleView: some View {
        Text("Dua Lipa – Radical Optimism")
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 10.0) {
        PlaybackQueueMenuItem()

        PlaybackQueueMenuItem()
            .environment(\.isMenuItemSelected, true)

        PlaybackQueueMenuItem()
            .environment(\.isMenuItemTriggering, true)
    }
    .padding(60.0)

    .environment(\.artworkProvider, PreviewArtworkProvider())
}
