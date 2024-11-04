//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import AppKit
import Combine
import SwiftUI
import MusicKit

@MainActor
class ApplicationDelegate:
    NSObject,
    NSApplicationDelegate,
    ObservableObject
{
    private(set) var musicPlayer = CappellaMusicPlayer()

    private var applicationWindow: PlatterWindow!
    private var nowPlayingWindow: PlatterWindow!

    private var globalKeyboardShortcutSubscription: AnyCancellable?
    private var keyboardShortcutBezel: KeyboardShortcutBezel?

    private var dockTile: DockTile?

    private var cancellable: AnyCancellable?
    private var receivedInitialApplicationDidBecomeActive = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentWidth = 440.0 + (PlatterGeometry.horizontalInset * 2.0)
        let contentHeight = 720.0 + 240.0 + 45.0 // TODO

        let applicationWindowRect = NSRect(
            x: 0.0, y: 0.0,
            width: contentWidth, height: contentHeight)
        applicationWindow = PlatterWindow(contentRect: applicationWindowRect) {
            ApplicationView()
                .environment(\.musicPlayer, self.musicPlayer)
        }

        globalKeyboardShortcutSubscription = GlobalKeyboardShortcutHandler
            .shared
            .didReceiveEvent
            .sink { [weak self] event in
                guard let self else { return }
                self.applicationShouldHandleGlobalKeyboardShortcut(event)
            }

        keyboardShortcutBezel = KeyboardShortcutBezel(using: self.musicPlayer)
        dockTile = DockTile(using: self.musicPlayer)

        orderFrontApplicationWindowIfNeeded()
    }

    func orderFrontApplicationWindowIfNeeded() {
        guard MusicAuthorization.currentStatus != .authorized else { return }

        cancellable = Timer
            .publish(every: 1.0, on: .main, in: .default)
            .autoconnect()
            .first()
            .sink { _ in
                if let platterProxy = self.applicationWindow.platterProxy {
                    platterProxy.present()
                }
            }
    }

    func applicationWillTerminate(_ notification: Notification) {
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        receivedInitialApplicationDidBecomeActive = true
    }

    func applicationShouldHandleReopen(
        _ sender: NSApplication,
        hasVisibleWindows flag: Bool
    ) -> Bool {
        if flag == false &&
           receivedInitialApplicationDidBecomeActive == true {
            if let platterProxy = self.applicationWindow.platterProxy {
                platterProxy.togglePresentation()
            }
        }

        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }

    func application(_ application: NSApplication, willEncodeRestorableState coder: NSCoder) {
    }

    func application(_ application: NSApplication, didDecodeRestorableState coder: NSCoder) {
    }

    func applicationShouldHandleGlobalKeyboardShortcut(
        _ event: GlobalKeyboardShortcutHandler.Event
    ) {
        musicPlayer.perform(using: event)

        if let keyboardShortcutBezel {
            keyboardShortcutBezel.update(for: event)
        }
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        guard let dockTile else { return nil }
        return dockTile.menu
    }

    @objc func playEntry(_ sender: NSMenuItem) {
        guard let entry = sender.representedObject as! ApplicationMusicPlayer.Queue.Entry? else {
            return
        }

        musicPlayer.play(entry)
    }
}
