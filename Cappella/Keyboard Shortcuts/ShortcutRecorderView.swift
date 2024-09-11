//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Cocoa
import HotKey
import Carbon

struct ShortcutRecorderView: View {
    @FocusState private var isFocued: Bool
    @State private var isRecording: Bool = false

    @State private var keyEquivalent: GlobalKeyboardShortcut.KeyEquivalent? = nil
    @State private var modifiers: NSEvent.ModifierFlags? = nil

    var body: some View {
        HStack {
            if let modifierString = modifiers?.description,
               let string = keyEquivalent?.description {
                Text("\(modifierString)\(string)")
            } else if let string = keyEquivalent?.description {
                Text("\(string)")
            } else if let modifierString = modifiers?.description {
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
        .focused($isFocued)
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
                keyEquivalent = GlobalKeyboardShortcut.KeyEquivalent(with: event)
                modifiers = event.modifierFlags
            } else {
                keyEquivalent = nil
                modifiers = nil
            }

            isRecording = false

            return .handled
        }

//        .onKeyEquivalent { keyCode, modifiers in // record key combination
//            guard isRecording else { return .ignored }
//
//            if let key = Key(carbonKeyCode: keyCode) {
//                keyEquivalent = KeyCombo(
//                    key: key,
//                    modifiers: modifiers
//                )
//            } else {
//                keyEquivalent = nil
//            }
//
//            isRecording = false
//
//            return .handled
//        }
        .onModifierKeysChanged { old, new in
            guard isRecording else { return }

            if new.isEmpty {
                modifiers = nil
            } else {
                modifiers = NSEvent.ModifierFlags(new)
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

        .opacity(keyEquivalent == nil ? 0.0 : 1.0)
    }

    @ViewBuilder
    private func makeBackgroundView() -> some View {
        if isRecording && isFocued {
            backgroundShape
                .fill(.selection)
        } else if isFocued {
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
        keyEquivalent = nil
        modifiers = nil

        isRecording = false
    }
}

#Preview(traits: .fixedLayout(width: 600.0, height: 480.0)) {
    Form {
        LabeledContent {
            ShortcutRecorderView()
        } label: {
            Text("Play/Pause Current Song:")
        }
        .padding()
    }
}
