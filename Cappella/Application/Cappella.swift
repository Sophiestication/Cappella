//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

@main
struct Cappella: App {
    @NSApplicationDelegateAdaptor private var applicationDelegate: ApplicationDelegate
    @State private var repeatMode: MusicPlayer.RepeatMode? = nil

    private var keyboardShortcutSettings = GlobalKeyboardShortcutSettings(
        userDefaults: .standard,
        keyboardShortcutHandler: GlobalKeyboardShortcutHandler.shared
    )

    var body: some Scene {
#if os(macOS)
        Settings {
            SettingsView()
        }
        .environment(\.globalKeyboardShortcutSettings, keyboardShortcutSettings)
        .commands {
            CommandMenu("Controls") {
                Section {
                    Button("Play") {
                    }
                    .keyboardShortcut(.space, modifiers: [])
                }

                Section {
                    Button("Next") {
                    }
                    .keyboardShortcut(.rightArrow, modifiers: [.command])

                    Button("Previous") {
                    }
                    .keyboardShortcut(.rightArrow, modifiers: [.command])
                }

                Section {
                    Button("Shuffle") {
                    }
                }

                Section {
                    Picker("Repeat Mode", selection: $repeatMode) {
                        Text("Repeat Off").tag(MusicPlayer.RepeatMode.none)
                        Text("Repeat All").tag(MusicPlayer.RepeatMode.all)
                        Text("Repeat One").tag(MusicPlayer.RepeatMode.one)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
        }
#endif
    }
}
