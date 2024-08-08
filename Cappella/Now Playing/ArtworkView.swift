//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit
import NukeUI

struct ArtworkView: View {
    @State private var artwork: Artwork?
    @State private var dimension: Int

    init(_ artwork: Artwork, dimension: Int) {
        self.artwork = artwork
        self.dimension = dimension
    }

    var body: some View {
        if let url = self.artworkURL {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: CGFloat(dimension), height: CGFloat(dimension))
                    .clipShape(makeContentShape())
            } placeholder: {
                ArtworkPlaceholderView(dimension)
            }
        } else {
            ArtworkPlaceholderView(dimension)
        }
    }

    private var artworkURL: URL? {
        return artwork?.url(
            width: dimension,
            height: dimension
        )
    }

    private func makeContentShape() -> some Shape {
        RoundedRectangle(
            cornerSize: CGSize(width: 4.0, height: 4.0),
            style: .continuous
        )
    }
}
