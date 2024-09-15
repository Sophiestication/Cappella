//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import AppKit
import Combine
import SwiftUI

class ApplicationDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var applicationWindow: PlatterWindow!
    private var nowPlayingWindow: PlatterWindow!

    private var globalKeyboardShortcutSubscription: AnyCancellable?
    private var keyboardShortcutBezel: KeyboardShortcutBezel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentWidth = 440.0 + (PlatterGeometry.horizontalInset * 2.0)
        let contentHeight = 720.0 + 240.0

        // Init application window
        let applicationWindowRect = NSRect(
            x: 0.0, y: 0.0,
            width: contentWidth, height: contentHeight)
        applicationWindow = PlatterWindow(contentRect: applicationWindowRect) {
            ApplicationView()
        }

//        // Init now playing window
//        let nowPlayingHeight = 44.0
//        let horizontalPadding = 10.0
//
//        let nowPlayingWindowRect = NSRect(
//            x: horizontalPadding,
//            y: 5.0,
//            width: contentWidth - horizontalPadding * 2.0,
//            height: nowPlayingHeight)
//        nowPlayingWindow = PlatterWindow(contentRect: nowPlayingWindowRect) {
//            NowPlayingView()
//        }
//
//        applicationWindow.dockedPlatter = nowPlayingWindow

       globalKeyboardShortcutSubscription = GlobalKeyboardShortcutHandler
            .shared
            .didReceiveEvent
            .sink { [weak self] event in
                guard let self else { return }
                self.applicationShouldHandleGlobalKeyboardShortcut(event)
            }

        keyboardShortcutBezel = KeyboardShortcutBezel()
    }

    func applicationWillTerminate(_ notification: Notification) {
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }

    @MainActor
    func applicationShouldHandleGlobalKeyboardShortcut(
        _ event: GlobalKeyboardShortcutHandler.Event
    ) {
        print("\(event.keyboardShortcut) \(event.phase)")

        if let keyboardShortcutBezel {
            keyboardShortcutBezel.update(for: event)
        }
    }
}
