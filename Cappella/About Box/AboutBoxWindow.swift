//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//
import AppKit
import SwiftUI

class AboutBoxWindow: NSWindow {
    init(
        contentRect: NSRect,
        @ViewBuilder _ content: @escaping () -> some View
    ) {
        let style: NSWindow.StyleMask = [
            .fullSizeContentView, .titled, .closable, .miniaturizable, .unifiedTitleAndToolbar
        ]

        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: .buffered,
            defer: false
        )

        self.level = .statusBar

        self.hidesOnDeactivate = false
        self.canHide = false

        self.isMovable = true
        self.isMovableByWindowBackground = true

        self.isExcludedFromWindowsMenu = true

        self.backgroundColor = .clear
        self.hasShadow = false

        self.appearance = NSAppearance(named: .vibrantDark)

        let hostingView = NSHostingView(rootView: content())

        hostingView.setFrameOrigin(.zero)
        hostingView.setFrameSize(contentRect.size)
        hostingView.autoresizingMask = [.width, .height]
    }
}

fileprivate final class AboutBoxContainerView: NSView {
    override var isFlipped: Bool { true }
}
