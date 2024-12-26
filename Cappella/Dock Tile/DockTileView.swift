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

import AppKit
import MusicKit

class DockTileView: NSView {
    typealias Entry = ApplicationMusicPlayer.Queue.Entry
    private let entry: Entry?

    init(for entry: Entry?) {
        self.entry = entry
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if let artwork = entry?.artwork {
            guard let url = artwork.url(
                width: Int(dirtyRect.width),
                height: Int(dirtyRect.height)
            ) else {
                drawApplicationIcon(dirtyRect)
                return
            }

            guard let templateImage = NSImage(named: "DockTileIcon") else {
                return
            }

            templateImage.draw(in: dirtyRect)

            guard let image = NSImage(contentsOf: url),
                  let maskImage = NSImage(named: "DockTileMaskIcon") else {
                drawApplicationIcon(dirtyRect)
                return
            }

            let dockTileImage = applyMask(to: image, with: maskImage)
            dockTileImage.draw(in: dirtyRect)
        } else {
            drawApplicationIcon(dirtyRect)
        }
    }

    private func drawApplicationIcon(_ dirtyRect: NSRect) {
        guard let applicationIcon = NSApplication.shared.applicationIconImage else {
            return
        }

        applicationIcon.draw(in: dirtyRect)
    }

    private func applyMask(to image: NSImage, with mask: NSImage) -> NSImage {
        let newImage = NSImage(size: image.size)

        newImage.lockFocus()

        mask.draw(
            in: NSRect(origin: .zero, size: image.size),
            from: .zero,
            operation: .copy,
            fraction: 1.0
        )

        image.draw(
            in: NSRect(origin: .zero, size: image.size),
            from: .zero,
            operation: .sourceIn,
            fraction: 1.0
        )

        newImage.unlockFocus()

        return newImage
    }
}
