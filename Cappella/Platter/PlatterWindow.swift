//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Cocoa
import SwiftUI

class PlatterWindow: NSPanel {
    init(
        contentRect: NSRect,
        @ViewBuilder _ content: @escaping () -> some View
    ) {
        let style: NSWindow.StyleMask = [
            .borderless, .nonactivatingPanel
        ]

        let geometry = PlatterGeometry(
            containerFrame: contentRect
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

        self.becomesKeyOnlyIfNeeded = false

        let rootView = PlatterView {
            content()
        }
        .environment(\.dismissPlatter, DismissPlatterAction(for: self))
        .environment(\.platterGeometry, geometry)
        .ignoresSafeArea(.all)

        let hostingView = NSHostingView(rootView: rootView)

        let hostingViewOrigin = CGPoint(
            x: contentRect.midX - geometry.contentFrame.width * 0.50,
            y: 0.0
        )
        hostingView.setFrameOrigin(hostingViewOrigin)
        hostingView.setFrameSize(geometry.contentFrame.size)
        hostingView.autoresizingMask = [.width, .height]

        let containerView = PlatterContainerView(frame: contentRect)
//        containerView.wantsLayer = true
//        containerView.layer!.backgroundColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.25)
        containerView.addSubview(hostingView)

        self.contentView = containerView

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

    override func frameRect(forContentRect contentRect: NSRect) -> NSRect {
//        let frameRect = CGRect(
//            x: contentRect.minX,
//            y: contentRect.minY,
//            width: contentRect.width,
//            height: contentRect.height
//        )

        let frameRect = contentRect.insetBy(dx: -60, dy: -60.0)

        return frameRect
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

final class PlatterContainerView: NSView {
    override var isFlipped: Bool { true }
}
