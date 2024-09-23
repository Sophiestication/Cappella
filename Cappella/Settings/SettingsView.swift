//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        KeyboardShortcutSettingsView()
            .frame(maxWidth: 600)
            .scenePadding()
    }
}

#Preview {
    SettingsView()
}
