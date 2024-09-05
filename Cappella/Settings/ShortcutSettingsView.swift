//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct ShortcutSettingsView: View {
    @AppStorage("menuBarExtraShown") private var menuBarExtraShown = true
    @AppStorage("dockItemShown") private var dockItemShown = true

    var body: some View {
        Form {
            Section {
                makeShortcutSetting("Show/Hide Music Search:")
                makeShortcutSetting("Show/Hide Now Playing:")
            }

            Spacer()

            Section {
                makeShortcutSetting("Play/Pause Current Song:")
                makeShortcutSetting("Next Song:")
                makeShortcutSetting("Previous Song:")
            }

            Spacer()

            Section {
                makeShortcutSetting("Toggle Repeat Mode:")
                makeShortcutSetting("Shuffle On/Off:")
            }

            Spacer()

            Section {
                makeShortcutSetting("Increase Sound Volume:")
                makeShortcutSetting("Decrease Sound Volume:")
                makeShortcutSetting("Toggle Mute Playback:")
            }
        }
    }

    @ViewBuilder
    private func makeShortcutSetting(_ title: String) -> some View {
        LabeledContent {
            ShortcutView()
        } label: {
            Text(title)
        }
    }
}

#Preview {
    SettingsView()
}
