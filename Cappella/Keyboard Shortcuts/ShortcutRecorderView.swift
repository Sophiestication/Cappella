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
            if let keyboardShortcut {
                Text("\(keyboardShortcut)")
            } else if isRecording,
                      let modifierString = currentModifiers?.description {
                Text("\(modifierString)")
            } else {
                Text("Click to record shortcut")
            }
        }
        .padding(.horizontal)
        .frame(minWidth: 140.0)

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
            }
        }
        .focusEffectDisabled()

        .onKeyPress(.return, phases: .down, action: { keyPress in // start recording
            guard isRecording == false else { return .ignored }

            isRecording = true

            return .handled
        })
        .onTapGesture {
            isRecording = true
        }

        .onKeyPress { keyPress in
            guard isRecording else { return .ignored }

            if let event = NSApp.currentEvent {
                keyboardShortcut = GlobalKeyboardShortcut(with: event)
            } else {
                keyboardShortcut = nil
            }

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

    private var backgroundShape: some Shape {
        Capsule(style: .continuous)
    }

    private func clear() {
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
