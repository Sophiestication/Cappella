//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Cocoa
import SwiftUI

class ApplicationDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var applicationWindow: PlatterWindow!
    private var nowPlayingWindow: PlatterWindow!
    private var menuBarExtra: MenuBarExtra? = nil

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

        // Dock to the menu bar
        menuBarExtra = MenuBarExtra(with: applicationWindow)
    }

    func applicationWillTerminate(_ notification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
}
