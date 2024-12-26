//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    private let resourceName: String

    init(_ resourceName: String = "PreviewArtwork1") {
        self.resourceName = resourceName
    }

    var backgroundColor: CGColor? {
        CGColor(red: 1.0 / 255.0, green: 67.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0)
    }

    func url(width: Int, height: Int) -> URL? {
        Bundle.main.url(forResource: resourceName, withExtension: "png")
    }
}
