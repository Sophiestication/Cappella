//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine
import AppKit
import MusicKit
import MediaPlayer

@MainActor
final class KeyboardShortcutBezel {
    typealias MusicPlayerType = CappellaMusicPlayer
    private let musicPlayer: MusicPlayerType

    typealias KeyboardShortcutEvent = GlobalKeyboardShortcutHandler.Event

    private enum PresentationState {
        case presenting
        case presented
        case dismissing
        case dismissed
    }
    private var presentationState: PresentationState
    private var dismissCancellable: AnyCancellable?

    private let window: NSWindow
    private let containerView: NSView

    private let keyboardShortcutEventSubject = PassthroughSubject<
        KeyboardShortcutEvent,
        Never
    >()

    init(using musicPlayer: MusicPlayerType) {
        self.musicPlayer = musicPlayer
        self.presentationState = .dismissed

        let window = Self.makeBezelWindow()
        self.window = window

        let containerView = Self.makeBezelContainerView(
            for: window,
            eventSubject: keyboardShortcutEventSubject.eraseToAnyPublisher(),
            musicPlayer: musicPlayer
        )
        self.containerView = containerView

        window.contentView = containerView

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidChangeScreen(_:)),
            name: NSWindow.didChangeScreenNotification,
            object: window
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidUpdate(_:)),
            name: NSWindow.didUpdateNotification,
            object: window
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @MainActor
    func update(for event: KeyboardShortcutEvent) {
        guard event.id != .musicSearch &&
              event.id != .nowPlaying else {
            return
        }

        keyboardShortcutEventSubject.send(event)

        if event.phase.isStrictSubset(of: [.down, .repeat]) {
            cancelDismissIfNeeded()
            present()
        } else if event.phase == .up {
            scheduleDismiss()
        }
    }

    @MainActor
    private func present() {
        guard presentationState == .dismissing ||
              presentationState == .dismissed else {
            return
        }

        layout()
        window.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.duration = 0.25

            presentationState = .presenting

            window.animator().alphaValue = 1.0
        } completionHandler: {
            guard self.presentationState == .presenting else { return }
            self.presentationState = .presented
        }
    }

    @MainActor
    private func cancelDismissIfNeeded() {
        dismissCancellable?.cancel()
        dismissCancellable = nil
    }

    @MainActor
    private func scheduleDismiss() {
        cancelDismissIfNeeded()

        dismissCancellable = Just(())
            .delay(
                for: .seconds(2.0),
                scheduler: RunLoop.main
            )
            .sink { [weak self] _ in
                guard let self else { return }
                self.dismiss()
            }
    }

    @MainActor
    private func dismiss() {
        guard presentationState == .presenting ||
              presentationState == .presented else {
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.duration = 1.0

            presentationState = .dismissing

            window.animator().alphaValue = 0.0
        } completionHandler: {
            guard self.presentationState == .dismissing else { return }

            self.presentationState = .dismissed
            self.window.orderOut(nil)
        }
    }

    private static func makeBezelWindow() -> NSWindow {
        let window = NSPanel(
            contentRect: .zero,
            styleMask: [ .borderless, .nonactivatingPanel ],
            backing: .buffered,
            defer: false
        )

        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

        window.isReleasedWhenClosed = true

        window.hidesOnDeactivate = false
        window.canHide = false

        window.isMovable = false
        window.isMovableByWindowBackground = false

        window.isExcludedFromWindowsMenu = true

        window.backgroundColor = .clear
        window.hasShadow = false

        window.becomesKeyOnlyIfNeeded = false
        window.ignoresMouseEvents = true

        window.alphaValue = 0.0

        return window
    }

    private static func makeBezelContainerView(
        for window: NSWindow,
        eventSubject: AnyPublisher<KeyboardShortcutEvent, Never>,
        musicPlayer: MusicPlayerType
    ) -> NSView {
        let containerView = NSHostingView(
            rootView: KeyboardShortcutBezelView(
                eventPublisher: eventSubject
            )
            .environment(\.musicPlayer, musicPlayer)
        )

        containerView.autoresizingMask = [.width, .height]

        return containerView
    }

    private func layout() {
        if let view = window.contentView,
           let screen = window.screen {
            let contentSize = view.fittingSize
            let screenRect = screen.frame

            let systemBezelOffset: CGFloat = 6.0

            let origin = CGPoint(
                x: screenRect.midX - contentSize.width * 0.5,
                y: contentSize.height * (1.0 - 1.0 / 3.0) + systemBezelOffset
            )

            let windowRect = CGRect(origin: origin, size: contentSize)
            window.setFrame(windowRect, display: true)
        }
    }

    @objc private func windowDidChangeScreen(_ notification: Notification) {
        layout()
    }

    @objc private func windowDidUpdate(_ notification: Notification) {
        layout()
    }
}
