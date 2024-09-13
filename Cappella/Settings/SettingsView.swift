//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                GeneralSettingsView()
            }

            Tab("Shortcuts", systemImage: "keyboard") {
                KeyboardShortcutSettingsView()
            }
        }
        .frame(maxWidth: 600)
        .scenePadding()
    }
}

#Preview {
    SettingsView()
}
