//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct ArtworkPlaceholderView: View {
    @State private var dimension: Int

    init(_ dimension: Int) {
        self.dimension = dimension
    }

    var body: some View {
        Group {
            RoundedRectangle(
                cornerSize: CGSize(width: 4.0, height: 4.0),
                style: .continuous
            )
            .fill(.quaternary)
        }
        .frame(
            width: CGFloat(dimension),
            height: CGFloat(dimension)
        )
    }
}
