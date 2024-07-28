//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Cocoa
import SwiftUI

@main @MainActor
class Cappella: NSObject, NSApplicationDelegate {
    private var applicationWindow: PlatterWindow!
    private var nowPlayingWindow: PlatterWindow!
    private var menuExtra: CappellaMenuExtra? = nil

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentWidth = 400.0
        let contentHeight = 720.0

        // Init application window
        applicationWindow = PlatterWindow(contentRect: NSRect(
            x: 0.0, y: 0.0,
            width: contentWidth, height: contentHeight))

        let hostingView = NSHostingView(rootView: ApplicationView())
        hostingView.frame = applicationWindow.contentView!.bounds
        hostingView.autoresizingMask = [.width, .height]

        applicationWindow.contentView?.addSubview(hostingView)

        // Init now playing window
        let nowPlayingHeight = 44.0
        let horizontalPadding = 10.0

        nowPlayingWindow = PlatterWindow(contentRect: NSRect(
            x: horizontalPadding,
            y: 5.0,
            width: contentWidth - horizontalPadding * 2.0,
            height: nowPlayingHeight)
        )

        let nowPlayingView = NSHostingView(rootView: NowPlayingView())
        nowPlayingView.frame = nowPlayingWindow.contentView!.bounds
        nowPlayingView.autoresizingMask = [.width, .height]

        nowPlayingWindow.contentView?.addSubview(nowPlayingView)

        applicationWindow.dockedPlatter = nowPlayingWindow

        // Dock to the menu bar
        menuExtra = CappellaMenuExtra(with: applicationWindow)
    }

    func applicationWillTerminate(_ notification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }
}
