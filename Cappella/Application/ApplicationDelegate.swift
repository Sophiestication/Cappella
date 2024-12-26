//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import AppKit
import Combine
import SwiftUI
import MusicKit
import WidgetKit

@MainActor
class ApplicationDelegate:
    NSObject,
    NSApplicationDelegate,
    ObservableObject
{
    private(set) var musicPlayer = CappellaMusicPlayer()

    private var applicationWindow: PlatterWindow!

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
        let store = NowPlayingStore()
        store.update(entry: nil)

        WidgetCenter.shared.reloadAllTimelines()
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
