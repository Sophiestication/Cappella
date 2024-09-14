//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Cocoa
import SwiftUI

class PlatterWindow: NSPanel {
    private var platterProxy: PlatterProxy? = nil
    private var platterGeometry: PlatterGeometry

    private let statusItem: NSStatusItem
    private var pressDownTimestamp: TimeInterval = .zero

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

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: .buffered,
            defer: false
        )

        self.level = .tornOffMenu

        self.hidesOnDeactivate = false
        self.canHide = false

        self.isMovable = false
        self.isMovableByWindowBackground = false

        self.isExcludedFromWindowsMenu = true

        self.backgroundColor = .clear
        self.hasShadow = false

        self.becomesKeyOnlyIfNeeded = false

        platterProxy = PlatterProxy(for: self)

        let rootView = PlatterView {
            content()
        }
        .environment(\.platterProxy, platterProxy)
        .environment(\.platterGeometry, platterGeometry)

        .environment(\.openPlatter, OpenPlatterAction(for: self))
        .environment(\.dismissPlatter, DismissPlatterAction(for: self))

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResignKey(_:)),
            name: NSWindow.didResignKeyNotification,
            object: self
        )

        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("statusItemTemplate2"))

            let pressRecognizer = NSPressGestureRecognizer(
                target: self,
                action: #selector(handleStatusItemPressGesture(_:))
            )
            pressRecognizer.minimumPressDuration = 0.0
            button.addGestureRecognizer(pressRecognizer)

            if let window = button.window {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(statusWindowDidMove(_:)),
                    name: NSWindow.didMoveNotification,
                    object: window
                )
            }
        }
    }

    func orderFront(_ sender: Any?, animated: Bool = false) {
        if let button = statusItem.button {
            button.highlight(true)
        }

        layoutWindow(self)
        makeKeyAndOrderFront(sender)
    }

    func orderOut(_ sender: Any?, animated: Bool = false) {
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 1.0 / 3.0
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

                self.animator().alphaValue = 0.0

                if let button = statusItem.button {
                    button.animator().highlight(false)
                }
            } completionHandler: {
                self.orderOut(self)
                self.alphaValue = 1.0
            }
        } else {
            orderOut(sender)
        }
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

    @objc private func windowDidResignKey(_ notification: Notification) {
        orderOut(notification, animated: true)
    }

    @objc private func statusWindowDidMove(_ notification: Notification) {
        guard let window = notification.object as? PlatterWindow else { return }
        layoutWindow(window)
    }

    @objc private func handleStatusItemPressGesture(_ sender: NSPressGestureRecognizer) {
        switch sender.state {
        case .began:
            pressDownTimestamp = Date().timeIntervalSince1970

            if isVisible {
                orderOut(sender, animated: true)
            } else {
                orderFront(sender, animated: true)
            }
        case .ended, .cancelled:
            if Date().timeIntervalSince1970 - self.pressDownTimestamp >= 0.33 {
                orderOut(sender, animated: true)
            }
        default:
            break
        }
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

    private func layoutWindow(_ window: PlatterWindow) {
        guard let statusItemWindow = statusItem.button?.window else {
            return
        }

        let targetRect = statusItemWindow.frame

        let windowRect = window.frame
        let newWindowRect = NSMakeRect(
            targetRect.midX - (windowRect.width * 0.50),
            targetRect.minY - windowRect.height,
            windowRect.width,
            windowRect.height
        )

        window.setFrame(newWindowRect, display: true)
    }
}

final class PlatterContainerView: NSView {
    override var isFlipped: Bool { true }
}
