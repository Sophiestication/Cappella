//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct ShortcutSettingsView: View {
    @AppStorage("menuBarExtraShown") private var menuBarExtraShown = true
    @AppStorage("dockItemShown") private var dockItemShown = true

    private let separatorLength: CGFloat = 20.0

    var body: some View {
        Form {
            Section {
                makeShortcutSetting("Show/Hide Music Search:")
                makeShortcutSetting("Show/Hide Now Playing:")
            }

            Spacer(minLength: separatorLength)

            Section {
                makeShortcutSetting("Play/Pause Current Song:")
                makeShortcutSetting("Next Song:")
                makeShortcutSetting("Previous Song:")
            }

            Spacer(minLength: separatorLength)

            Section {
                makeShortcutSetting("Toggle Repeat Mode:")
                makeShortcutSetting("Shuffle On/Off:")
            }

            Spacer(minLength: separatorLength)

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
            ShortcutRecorderView()
        } label: {
            Text(title)
        }
    }
}

#Preview(traits: .fixedLayout(width: 680.0, height: 480.0)) {
    ShortcutSettingsView()
        .padding()
}
