//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

@main
struct Cappella: App {
    @NSApplicationDelegateAdaptor private var applicationDelegate: ApplicationDelegate

    private var keyboardShortcutSettings = GlobalKeyboardShortcutSettings(
        userDefaults: .standard,
        keyboardShortcutHandler: GlobalKeyboardShortcutHandler.shared
    )

    var body: some Scene {
#if os(macOS)
//        makeKeyboardShortcutBezel()

        Settings {
            SettingsView()
        }
        .environment(\.globalKeyboardShortcutSettings, keyboardShortcutSettings)
#endif
    }

    @SceneBuilder
    private func makeKeyboardShortcutBezel() -> some Scene {
        Window(Text(""), id: "keyboardShortcutBezel") {
            KeyboardShortcutBezelView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowLevel(.floating)

        .windowIdealSize(.fitToContent)

        .restorationBehavior(.disabled)
    }
}
