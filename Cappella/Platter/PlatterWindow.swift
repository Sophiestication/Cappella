//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Cocoa
import SwiftUI

class PlatterWindow: NSPanel {
    var platterProxy: PlatterProxy? = nil
    private var platterGeometry: PlatterGeometry

    fileprivate let statusItem: NSStatusItem
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

        self.setFrameAutosaveName("")

        self.level = .tornOffMenu

        self.hidesOnDeactivate = false
        self.canHide = false

        self.isMovable = false
        self.isMovableByWindowBackground = false

        self.isExcludedFromWindowsMenu = true

        self.backgroundColor = .clear
        self.hasShadow = false

        self.becomesKeyOnlyIfNeeded = false

        self.appearance = NSAppearance(named: .vibrantDark)

        platterProxy = PlatterProxy(for: self)

        let rootView = PlatterView {
            content()
        }
        .environment(\.platterProxy, platterProxy)
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
        // containerView.wantsLayer = true
        // containerView.layer!.backgroundColor = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.25)
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

                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(statusWindowDidChangeScreen(_:)),
                    name: NSWindow.didChangeScreenNotification,
                    object: window
                )
            }
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
    }

    @objc private func windowDidResignKey(_ notification: Notification) {
        if let platterProxy {
            platterProxy.dismiss()
        }
    }

    @objc private func statusWindowDidMove(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }

        if let statusItemWindow = statusItem.button?.window {
            if window == statusItemWindow {
                layoutWindow()
            }
        } else if window == self {
            layoutWindow()
        }
    }

    @objc private func statusWindowDidChangeScreen(_ notification: Notification) {
        layoutWindow()
    }

    @objc private func handleStatusItemPressGesture(_ sender: NSPressGestureRecognizer) {
        guard let platterProxy else { return }

        switch sender.state {
        case .began:
            pressDownTimestamp = Date().timeIntervalSince1970
            platterProxy.togglePresentation()

        case .ended, .cancelled:
            if Date().timeIntervalSince1970 - self.pressDownTimestamp >= 0.33 {
                platterProxy.dismiss()
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

    func preferredWindowRect(
        propossedWindowRect: CGRect,
        _ screen: NSScreen?
    ) -> CGRect {
        guard let statusItemWindow = statusItem.button?.window else {
            return propossedWindowRect
        }

        let targetRect = statusItemWindow.frame

        let windowRect = self.frame
        var newWindowRect = NSMakeRect(
            targetRect.midX - (windowRect.width * 0.50),
            targetRect.minY - windowRect.height,
            windowRect.width,
            windowRect.height
        )

        if let screenRect = screen?.visibleFrame {
            if (newWindowRect.maxX - PlatterGeometry.horizontalInset) > screenRect.maxX {
                newWindowRect.origin = CGPoint(
                    x: screenRect.maxX - (newWindowRect.width - PlatterGeometry.horizontalInset + 10.0), // TODO
                    y: newWindowRect.maxY
                )
            }
        }

        return newWindowRect
    }

    override func setFrame(_ frameRect: NSRect, display: Bool) {
        super.setFrame(frameRect, display: display)
    }

    fileprivate func layoutWindow() {
        let newWindowRect = self.preferredWindowRect(
            propossedWindowRect: platterGeometry.containerFrame,
            screen
        )

        self.setFrame(newWindowRect, display: true)
    }
}

final class PlatterContainerView: NSView {
    override var isFlipped: Bool { true }
}

@Observable
class PlatterProxy {
    private weak var platterWindow: PlatterWindow?

    init() {
        self.platterWindow = nil
        self.presentationState = .dismissed
    }

    init(for platterWindow: PlatterWindow) {
        self.platterWindow = platterWindow
        self.presentationState = .dismissed // TODO?
    }

    private enum PresentationState {
        case presenting
        case presented
        case dismissing
        case dismissed
    }

    private var presentationState: PresentationState

    @MainActor
    func present() {
        guard let platterWindow else { return }
        guard presentationState == .dismissing ||
              presentationState == .dismissed else {
            return
        }

        platterWindow.statusItem.button?.highlight(false)
        platterWindow.layoutWindow()

        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.duration = 0.125

            presentationState = .presenting

            platterWindow.alphaValue = 1.0
            platterWindow.makeKeyAndOrderFront(nil)

            if let button = platterWindow.statusItem.button {
                button.highlight(true)
            }
        } completionHandler: {
            guard self.presentationState == .presenting else { return }
            self.presentationState = .presented
        }
    }

    @MainActor
    func dismiss() {
        guard let platterWindow else { return }
        guard presentationState == .presenting ||
              presentationState == .presented else {
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.duration = 0.25

            presentationState = .dismissing

            platterWindow.animator().alphaValue = 0.0

            if let button = platterWindow.statusItem.button {
                button.animator().highlight(false)
            }
        } completionHandler: {
            guard self.presentationState == .dismissing else { return }

            self.presentationState = .dismissed
            platterWindow.orderOut(nil)
        }
    }

    @MainActor
    func togglePresentation() {
        switch presentationState {
        case .presenting, .presented:
            dismiss()
            break

        case .dismissing, .dismissed:
            present()
            break
        }
    }
}

extension EnvironmentValues {
    @Entry var platterProxy: PlatterProxy? = nil
}
