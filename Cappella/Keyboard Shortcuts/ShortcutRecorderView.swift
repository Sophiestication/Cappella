//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

struct ShortcutRecorderView: View {
    @FocusState private var isFocused: Bool
    @State private var isRecording: Bool = false

    @Binding var keyboardShortcut: GlobalKeyboardShortcut?
    @State private var currentModifiers: NSEvent.ModifierFlags? = nil

    var body: some View {
        HStack {
            if isRecording {
                if let currentModifiers {
                    Text("\(currentModifiers.description)")
                } else {
                    Text("Type shortcut")
                }
            } else if let keyboardShortcut {
                Text("\(keyboardShortcut)")
            } else {
                Text("Click to record shortcut")
            }
        }
        .padding(.horizontal)
        .frame(minWidth: 180.0)

        .overlay(
            makeClearButton(), alignment: .trailing
        )

        .padding(.vertical, 6.0)

        .background(
            makeBackgroundView()
        )

        .focusable()
        .focused($isFocused)
        .onChange(of: isFocused, initial: false) { _, isFocued  in
            if isFocused == false {
                isRecording = false
                currentModifiers = nil
            }
        }
        .focusEffectDisabled()

        .onKeyPress(.return, phases: .down, action: { keyPress in // start recording
            guard isRecording == false else { return .ignored }

            record()

            return .handled
        })

        .contentShape(.interaction, backgroundShape)
        .onTapGesture {
            record()
        }

        .onKeyPress { keyPress in
            guard isRecording else { return .ignored }

//            if keyPress.key == .escape &&
//               keyPress.modifiers.isEmpty {
//                isRecording = false
//            } else {
                if let event = NSApp.currentEvent {
                    keyboardShortcut = GlobalKeyboardShortcut(with: event)
                } else {
                    keyboardShortcut = nil
                }
//            }

            currentModifiers = nil
            isRecording = false

            return .handled
        }
        .onModifierKeysChanged { old, new in
            guard isRecording else { return }

            if new.isEmpty {
                currentModifiers = nil
            } else {
                currentModifiers = NSEvent.ModifierFlags(new)
            }
        }
    }

    @ViewBuilder
    private func makeClearButton() -> some View {
        Button(action: {
            clear()
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .padding(6.0)
        })

        .buttonStyle(.borderless)
        .labelStyle(.iconOnly)

        .accessibilityLabel(Text("Clear"))

        .opacity(keyboardShortcut == nil ? 0.0 : 1.0)
    }

    @ViewBuilder
    private func makeBackgroundView() -> some View {
        ZStack {
            backgroundShape
                .shadow(color: Color.blue, radius: isFocused ? 2.0 : 0.0)
                .opacity(isFocused ? 1.0 : 0.0)
            backgroundShape
                .fill(.background)

            if isRecording && isFocused {
                backgroundShape
                    .fill(.selection)
            } else if isFocused {
                backgroundShape
                    .stroke(.selection)
            } else {
                backgroundShape
                    .stroke(.tertiary)
            }
        }
        .animation(.smooth, value: isFocused)
    }

    private var backgroundShape: some Shape {
        Capsule(style: .continuous)
    }

    private func record() {
        isRecording = true
        keyboardShortcut = nil
    }

    private func clear() {
        currentModifiers = nil
        keyboardShortcut = nil
        isRecording = false
    }
}

#Preview(traits: .fixedLayout(width: 600.0, height: 480.0)) {
    @Previewable @State var shortcut: GlobalKeyboardShortcut? = nil

    Form {
        LabeledContent {
            ShortcutRecorderView(keyboardShortcut: $shortcut)
        } label: {
            Text("Play/Pause Current Song:")
        }
        .padding()
    }
}
