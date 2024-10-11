//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

struct ShortcutRecorderView: View {
    @FocusState private var isFocused: Bool
    @State private var isRecording: Bool = false

    @Binding var keyboardShortcut: GlobalKeyboardShortcut?
    @State private var currentModifiers: NSEvent.ModifierFlags? = nil

    @Environment(\.pixelLength) var pixelLength

    var body: some View {
        HStack {
            if isRecording {
                if let currentModifiers {
                    Text("\(currentModifiers.description)")
                } else {
                    Text("Type shortcut")
                        .foregroundStyle(.secondary)
                }
            } else if let keyboardShortcut {
                Text("\(keyboardShortcut)")
            } else {
                Text("Click to record shortcut")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .frame(minWidth: 180.0)

        .overlay(clearButton, alignment: .trailing)

        .padding(.vertical, 6.0)

        .background(background)

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

        .contentShape(backgroundShape)
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
    private var clearButton: some View {
        Button(action: {
            clear()
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.trailing, 7.0)
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

    @ViewBuilder
    private var background: some View {
        ZStack {
            backgroundShape
                .fill(.tint.opacity(isFocused ? 1.0 : 0.0))
                .blur(radius: 1.0)
            backgroundShape
                .fill(.tint.opacity(isRecording ? 1.0 : 0.0))
                .blur(radius: 3.0)
            backgroundShape
                .fill(.foreground.opacity(1.0 / 7.0))
                .offset(y: pixelLength)
                .blur(radius: pixelLength)
                .blendMode(.plusLighter)
            backgroundShape
                .fill(.background)
            backgroundShape
                .fill(.tint.opacity(isRecording ? 1.0 : 0.0))
                .blendMode(.overlay)
            backgroundShape
                .fill(LinearGradient(
                    gradient: backgroundGradient,
                    startPoint: .top,
                    endPoint: .bottom)
                )
            backgroundShape
                .innerShadow(
                    color: .black.opacity(1.0 / 3.0),
                    radius: 1.0,
                    x: 0,
                    y: 1.0
                )
                .blendMode(.multiply)
            backgroundShape
                .inset(by: pixelLength)
                .stroke(.black.opacity(1.0 / 6.0), lineWidth: pixelLength)
        }
        .animation(
            .spring.repeatForever(autoreverses: true),
            value: isRecording
        )
    }

    private var backgroundShape: Capsule {
        Capsule(style: .continuous)
    }

    private var backgroundGradient: Gradient {
        let colors = stride(from: 0.0, to: 0.2, by: 0.05).map { value -> Color in
            let opacity = UnitCurve.easeInOut.value(at: value)
            return Color.white.opacity(opacity)
        }

        return Gradient(colors: colors)
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

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var shortcut: GlobalKeyboardShortcut? = nil

    Form {
        LabeledContent {
            ShortcutRecorderView(keyboardShortcut: $shortcut)
        } label: {
            Text("Play/Pause Current Song:")
        }

        LabeledContent {
            ShortcutRecorderView(keyboardShortcut: $shortcut)
        } label: {
            Text("Next Song:")
        }
    }
    .scenePadding()
}
