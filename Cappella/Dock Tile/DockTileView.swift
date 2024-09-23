//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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
