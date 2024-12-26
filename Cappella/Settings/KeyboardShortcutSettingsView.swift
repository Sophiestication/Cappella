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
