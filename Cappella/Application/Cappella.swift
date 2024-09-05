//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

@main
struct Cappella: App {
    @NSApplicationDelegateAdaptor private var applicationDelegate: ApplicationDelegate

    var body: some Scene {
#if os(macOS)
        Settings {
            SettingsView()
        }
#endif
    }
}
