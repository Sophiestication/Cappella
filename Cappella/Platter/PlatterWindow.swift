//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Cocoa
import SwiftUI

class PlatterWindow: NSPanel {
    private var geometry: PlatterGeometry

    init(
        contentRect: NSRect,
        @ViewBuilder _ content: @escaping () -> some View
    ) {
        let style: NSWindow.StyleMask = [
            .borderless, .nonactivatingPanel
        ]

        geometry = PlatterGeometry(
            containerSize: contentRect.size
        )

        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: .buffered,
            defer: false
        )

        self.hidesOnDeactivate = false
        self.canHide = false

        self.isMovable = true
        self.isMovableByWindowBackground = true

        self.isExcludedFromWindowsMenu = true

        self.backgroundColor = .clear
        self.hasShadow = false

        self.becomesKeyOnlyIfNeeded = true

        let rootView = PlatterView {
            content()
        }
        .environment(\.platterGeometry, geometry)
        .ignoresSafeArea(.all)

        let hostingView = NSHostingView(rootView: rootView)

        if let contentView = self.contentView {
            hostingView.frame = contentView.bounds
            hostingView.autoresizingMask = [.width, .height]

            contentView.addSubview(hostingView)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidMove(_:)),
            name: NSWindow.didMoveNotification,
            object: self
        )
    }

    var dockedPlatter: PlatterWindow? = nil {
        didSet {
            if let platter = dockedPlatter {
                self.addChildWindow(platter, ordered: .above)
            }

            self.layoutDockedPlatter()
        }
    }

    var dockedPlatterMinimized: Bool = true {
        didSet {
            self.layoutDockedPlatter()
        }
    }

    override var canBecomeKey: Bool {
        true
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    @objc private func windowDidMove(_ notification: Notification) {
//        layoutDockedPlatter()
    }

    private func layoutDockedPlatter() {
        guard let platter = dockedPlatter else {
            return
        }

        if self.dockedPlatterMinimized {
            layoutMinimized(platter)
        } else {
            layoutPlatter(platter)
        }

        platter.order(.above, relativeTo: self.windowNumber)
    }

    private func layoutPlatter(_ platter: PlatterWindow) {
        let frame = self.frame

        let platterFrame = CGRect(
            x: frame.minX,
            y: frame.minY - 20.0,
            width: frame.width,
            height: frame.height
        )
        platter.setFrame(platterFrame, display: true)
    }

    private func layoutMinimized(_ platter: PlatterWindow) {
        let frame = self.frame

        let horizontalPadding = 10.0
        let platterFrame = CGRect(
            x: frame.minX + horizontalPadding,
            y: frame.minY + 10.0,
            width: frame.width - horizontalPadding * 2.0,
            height: 44.0
        )
        platter.setFrame(platterFrame, display: true)
    }
}
