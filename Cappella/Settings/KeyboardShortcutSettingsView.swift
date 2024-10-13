//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct KeyboardShortcutSettingsView: View {
    @Environment(\.globalKeyboardShortcutSettings) var keyboardShortcutSettings
    private let separatorLength: CGFloat = 20.0

    var body: some View {
        Form {
            Section {
                makeShortcutSetting("Show/Hide Music Search:", binding(for: .musicSearch))
            }

            separator

            Section {
                makeShortcutSetting("Play/Pause Current Song:", binding(for: .playPause))
                makeShortcutSetting("Next Song:", binding(for: .fastForward))
                makeShortcutSetting("Previous Song:", binding(for: .rewind))
            }

            separator

            Section {
                makeShortcutSetting("Toggle Repeat Mode:", binding(for: .toggleRepeatMode))
                makeShortcutSetting("Shuffle On/Off:", binding(for: .shuffleOnOff))
            }
        }
        .navigationTitle(Text("Keyboard Shortcuts"))

        .onPreferenceChange(KeyboardShortcutRecordingKey.self) { isRecording in
            guard let keyboardShortcutSettings else { return }

            if isRecording {
                keyboardShortcutSettings.beginRecording()
            } else {
                keyboardShortcutSettings.endRecording()
            }
        }

        .onReceive(keyboardShortcutSettings!.didReceiveUpdateError) { error in
            
        }
    }

    private var separator: some View {
        Spacer()
            .frame(height: separatorLength)
    }

    private func binding(
        for id: GlobalKeyboardShortcutSettings.KeyboardShortcutID
    ) -> Binding<GlobalKeyboardShortcutSettings.KeyboardShortcut?> {
        Binding(
            get: {
                keyboardShortcutSettings?.keyboardShortcut(for: id)
            },

            set: { newValue in
                keyboardShortcutSettings?.set(newValue, for: id)
            }
        )
    }

    @ViewBuilder
    private func makeShortcutSetting(
        _ title: String,
        _ keyboardShortcut: Binding<GlobalKeyboardShortcut?>
    ) -> some View {
        LabeledContent {
            ShortcutRecorderView(keyboardShortcut: keyboardShortcut)
        } label: {
            Text(title)
        }
    }
}

#Preview(traits: .fixedLayout(width: 680.0, height: 480.0)) {
    KeyboardShortcutSettingsView()
        .scenePadding()
}
