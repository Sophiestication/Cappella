//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

struct ShortcutRecorderView: View {
    @FocusState private var isFocused: Bool

    @State private var isSelected: Bool = false
    @State private var isRecording: Bool = false

    @Binding var keyboardShortcut: GlobalKeyboardShortcut?
    @State private var currentModifiers: NSEvent.ModifierFlags? = nil

    @Environment(\.pixelLength) var pixelLength
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            content
        }
        .padding(.horizontal)
        .frame(minWidth: 180.0)

        .overlay(placeholder, alignment: .center)
        .overlay(clearButton, alignment: .trailing)

        .padding(.vertical, 6.0)

        .background(background)

        .focusable()
        .focused($isFocused)
        .onChange(of: isFocused, initial: true) { _, newValue  in
            isSelected = newValue

            if isFocused == false {
                cancel()
            }
        }
        .focusEffectDisabled()

        .contentShape(backgroundShape)
        .onTapGesture {
            record()
        }

        .onKeyPress(.return, phases: .down, action: { keyPress in // start recording
            guard isRecording == false else { return .ignored }

            record()

            return .handled
        })

        .onKeyPress { keyPress in
            guard isRecording else { return .ignored }

            if keyPress.key == .escape &&
               keyPress.modifiers.isEmpty {
                // will cancel…
            } else if keyPress.key == .tab &&
                      keyPress.modifiers.isEmpty {
                cancel()

                return .ignored
            } else {
                if let event = NSApp.currentEvent {
                    keyboardShortcut = GlobalKeyboardShortcut(with: event)
                } else {
                    keyboardShortcut = nil
                }
            }

            cancel()

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
    private var content: some View {
        if isRecording, let currentModifiers {
            Text("\(currentModifiers.description)")
        } else if let keyboardShortcut {
            Text("\(keyboardShortcut)")
        } else {
            Text("\(CompatibilityKeyEquivalent.command)")
                .opacity(0.0)
        }
    }

    @ViewBuilder
    private var placeholder: some View {
        Text(placeholderString)
            .foregroundStyle(.secondary)
            .font(.callout)
            .opacity(isPlaceholderVisible ? 1.0 : 0.0)
    }

    private var isPlaceholderVisible: Bool {
        return currentModifiers == nil && keyboardShortcut == nil
    }

    private var placeholderString: String {
        isRecording ? "Type shortcut" : "Click to record shortcut"
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
    private var background: some View {
        ShortcutRecorderBackgroundView(
            isFocused: $isSelected,
            isRecording: $isRecording
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

    private func cancel() {
        currentModifiers = nil
        keyboardShortcut = nil
        isRecording = false
    }

    private func clear() {
        cancel()
    }
}

fileprivate struct ShortcutRecorderBackgroundView: View {
    @Binding var isFocused: Bool
    @Binding var isRecording: Bool

    @Environment(\.pixelLength) var pixelLength
    @Environment(\.colorScheme) var colorScheme

    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            backgroundShape
                .fill(.tint.opacity(isFocused && colorScheme == .dark ? 1.0 : 0.0))
                .blur(radius: 1.0)
            backgroundShape
                .fill(.tint.opacity(isPulsing ? 1.0 : 0.0))
                .blur(radius: 3.0)
            backgroundShape
                .fill(.white.opacity(1.0 / 7.0))
                .offset(y: pixelLength)
                .blur(radius: pixelLength)
                .blendMode(.plusLighter)
            backgroundShape
                .fill(.background)
            backgroundShape
                .fill(.tint.opacity(isPulsing ? 1.0 : 0.0))
                .blendMode(.overlay)
            backgroundShape
                .fill(LinearGradient(
                    gradient: backgroundGradient,
                    startPoint: .top,
                    endPoint: .bottom)
                )
            backgroundShape
                .innerShadow(
                    color: isFocused ?
                        .accentColor.opacity(1.0 / 3.0) :
                            .black.opacity(1.0 / 3.0),
                    radius: 1.0,
                    x: 0,
                    y: 1.0
                )
                .blendMode(.multiply)
            backgroundShape
                .inset(by: pixelLength)
                .stroke(.black.opacity(1.0 / 6.0), lineWidth: pixelLength)
            backgroundShape
                .stroke(lineWidth: 1.0)
                .fill(.tint.opacity(isFocused ? 1.0 / 2.0 : 0.0))
                .blendMode(.multiply)
        }

        .onChange(of: isRecording, initial: true) { _, newValue in
            if newValue {
                withAnimation(
                    .spring.repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            } else {
                withAnimation(.snappy) {
                    isPulsing = false
                }
            }
        }
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
