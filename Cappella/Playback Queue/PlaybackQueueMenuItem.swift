//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackQueueMenuItem: View {
    var body: some View {
        HStack(alignment: .center) {
            Spacer()

            HStack {
                reorderControl
                deleteControl
            }

            artworkView

            VStack(alignment: .leading) {
                titleView
                subtitleView
            }

            Spacer()
        }
        .contentShape(contentShape)
        .background(background)
    }

    @ViewBuilder
    private var contentShape: some Shape {
        RoundedRectangle(
            cornerRadius: 9.0,
            style: .continuous
        )
    }

    @ViewBuilder
    private var background: some View {
        contentShape
            .fill(.selection)
    }

    @ViewBuilder
    private var reorderControl: some View {
        EmptyView()
    }

    @ViewBuilder
    private var deleteControl: some View {
        EmptyView()
    }

    @ViewBuilder
    private var artworkView: some View {
        Image("artwork1")
            .resizable()
            .frame(width: 40.0, height: 40.0)
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

#Preview(traits: .fixedLayout(width: 600.0, height: 480.0)) {
    ScrollView {
        VStack {
            PlaybackQueueMenuItem()
        }
        .padding()
        .containerRelativeFrame(.vertical)
    }
    .containerRelativeFrame(.horizontal)
}
