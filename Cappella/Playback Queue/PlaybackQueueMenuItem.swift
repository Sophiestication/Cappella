//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackQueueMenuItem: View {
    var body: some View {
        PlatterMenuItem {
            titleView
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
        ArtworkView(length: 40)
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
