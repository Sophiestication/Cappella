//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Cocoa
import Combine

@MainActor
class MenuBarExtra: NSObject {
    private let statusItem: NSStatusItem
    private let window: PlatterWindow

    private var windowShown: Bool = false {
        didSet {
            windowDidShow(windowShown)
        }
    }

    private var pressDownTimestamp: TimeInterval = .zero

    init(with window: PlatterWindow) {
        self.window = window
        window.level = .tornOffMenu

        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        super.init()

        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("statusItemTemplate2"))

            let pressRecognizer = NSPressGestureRecognizer(
                target: self,
                action: #selector(handlePressGesture(_:))
            )
            pressRecognizer.minimumPressDuration = 0.0
            button.addGestureRecognizer(pressRecognizer)

            if let window = button.window {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(windowDidMove(_:)),
                    name: NSWindow.didMoveNotification,
                    object: window
                )
            }
        }

        layoutWindow(window)
    }

    deinit {
        Task { @MainActor in
            NotificationCenter.default.removeObserver(
                self,
                name: NSWindow.didMoveNotification,
                object: statusItem.button?.window
            )
        }
    }

    @objc private func windowDidMove(_ notification: Notification) {
//        guard let window = notification.object as? NSWindow else { return }

        // TODO
    }

    private func windowDidShow(_ windowShown: Bool) {
        if let button = statusItem.button {
            button.highlight(windowShown)
        }

        if windowShown {
            layoutWindow(window)
            window.makeKeyAndOrderFront(nil)
        } else {
            window.orderOut(nil)
        }
    }

    @objc private func handlePressGesture(_ sender: NSPressGestureRecognizer) {
        switch sender.state {
        case .began:
            self.pressDownTimestamp = Date().timeIntervalSince1970
            self.windowShown = !self.windowShown
        case .ended, .cancelled:
            if Date().timeIntervalSince1970 - self.pressDownTimestamp >= 0.33 {
                self.windowShown = false
            }
        default:
            break
        }
    }

    private func layoutWindow(_ window: PlatterWindow) {
        guard let statusItemWindow = statusItem.button?.window else {
            return
        }

        let targetRect = statusItemWindow.frame
        
        let windowRect = window.frame
        let newWindowRect = NSMakeRect(
            targetRect.midX - (windowRect.width * 0.50),
            targetRect.minY - windowRect.height - 5.0,
            windowRect.width,
            windowRect.height
        )

        window.setFrame(newWindowRect, display: true)
    }
}