//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation
import SwiftUI
import MusicKit

protocol ArtworkProviding {
    var backgroundColor: CGColor? { get }
    func url(width: Int, height: Int) -> URL?
}

extension EnvironmentValues {
    @Entry var artworkProvider: ArtworkProviding? = nil
}

extension Artwork: ArtworkProviding {
}

struct PreviewArtworkProvider: ArtworkProviding {
    var backgroundColor: CGColor? {
        CGColor(red: 1.0 / 255.0, green: 67.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0)
    }

    func url(width: Int, height: Int) -> URL? {
        Bundle.main.url(forResource: "PreviewArtwork1", withExtension: "png")
    }
}
