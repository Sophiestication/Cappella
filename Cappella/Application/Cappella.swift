//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

@main
struct Cappella: App {
    @NSApplicationDelegateAdaptor private var applicationDelegate: ApplicationDelegate
    private var keyboardShortcutSettings = GlobalKeyboardShortcutSettings(userDefaults: .standard)

    var body: some Scene {
#if os(macOS)
        Settings {
            SettingsView()
        }
        .environment(\.globalKeyboardShortcutSettings, keyboardShortcutSettings)
#endif
    }
}
