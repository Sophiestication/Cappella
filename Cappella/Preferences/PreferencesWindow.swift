//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

class PreferencesWindow: NSWindow {
    init(
        contentRect: NSRect
    ) {
        let style: NSWindow.StyleMask = [
            .titled, .fullSizeContentView, .closable, .miniaturizable
        ]

        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: .buffered,
            defer: false
        )

        let hostingView = NSHostingView(rootView: EmptyView())

        let hostingViewOrigin = CGPoint(
            x: contentRect.midX,
            y: 0.0
        )
        hostingView.setFrameOrigin(hostingViewOrigin)
        hostingView.setFrameSize(contentRect.size)
        hostingView.autoresizingMask = [.width, .height]

        self.contentView = hostingView
    }
}
