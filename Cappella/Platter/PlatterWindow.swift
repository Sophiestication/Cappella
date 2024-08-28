//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Cocoa
import SwiftUI

class PlatterWindow: NSPanel {
    private var platterGeometry: PlatterGeometry
    private var dragView: NSView? = nil

    init(
        contentRect: NSRect,
        @ViewBuilder _ content: @escaping () -> some View
    ) {
        let style: NSWindow.StyleMask = [
            .borderless, .nonactivatingPanel
        ]

        platterGeometry = PlatterGeometry(
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

        self.isMovable = false
        self.isMovableByWindowBackground = false

        self.isExcludedFromWindowsMenu = true

        self.backgroundColor = .clear
        self.hasShadow = false

        self.becomesKeyOnlyIfNeeded = false

        let rootView = PlatterView {
            content()
        }
        .environment(\.dismissPlatter, DismissPlatterAction(for: self))
        .environment(\.platterGeometry, platterGeometry)
        .ignoresSafeArea(.all)

        let hostingView = NSHostingView(rootView: rootView)

        let hostingViewOrigin = CGPoint(
            x: contentRect.midX - platterGeometry.contentFrame.width * 0.50,
            y: 0.0
        )
        hostingView.setFrameOrigin(hostingViewOrigin)
        hostingView.setFrameSize(platterGeometry.contentFrame.size)
        hostingView.autoresizingMask = [.width, .height]

        self.dragView = hostingView

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

    @objc private func windowDidMove(_ notification: Notification) {
//        layoutDockedPlatter()
    }

    private func layoutDragView() {
        guard let dragView else { return }

        let contentRect = platterGeometry.containerFrame
        let hostingViewOrigin = CGPoint(
            x: contentRect.midX - platterGeometry.contentFrame.width * 0.50,
            y: 0.0
        )
        dragView.setFrameOrigin(hostingViewOrigin)
        dragView.setFrameSize(platterGeometry.contentFrame.size)
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
