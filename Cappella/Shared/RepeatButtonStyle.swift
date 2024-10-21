//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine

typealias ButtonRepeatPhases = KeyPress.Phases

struct RepeatButtonStyle: ButtonStyle {
    @State private var isHighlighted: Bool = false
    @State private var isPressed = false

    @State private var repeatTimer: AnyCancellable?
    @State private var repeatPhases: ButtonRepeatPhases = .up
    @State private var lastRepeatTime: Date = .distantPast

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: length, height: length)
            .opacity(isEnabled ? 1.0 : 0.50)
            .contentShape(contentShape)
            .background(background)

            .scaleEffect(
                x: isPressed ? 0.88 : 1.0,
                y: isPressed ? 0.88 : 1.0,
                anchor: .center
            )

            .onHover { isHovering in
                withAnimation(.smooth(duration: isHovering ? 0.20 : 0.50)) {
                    isHighlighted = isHovering
                }
            }

            .onChange(of: configuration.isPressed) {
                if configuration.isPressed {
                    scheduleRepeat()
                    repeatPhases = [.down]
                } else {
                    stopRepeat()
                    repeatPhases = [.up]
                }

                withAnimation(.smooth(duration: configuration.isPressed ? 0.20 : 0.50)) {
                    isPressed = configuration.isPressed
                }
            }

            .preference(
                key: NowPlayingRepeatActionKey.self,
                value: ButtonRepeatPhaseUpdate(phases: repeatPhases, timestamp: lastRepeatTime)
            )
    }

    private let length = 36.0

    @ViewBuilder
    private var contentShape: some Shape {
        Circle()
    }

    @ViewBuilder
    private var background: some View {
        contentShape
            .fill(Color.white.opacity(isHighlighted ? 0.25 : 0.10))
    }

    private func scheduleRepeat() {
        stopRepeat()

        let publisher = Timer.publish(
            every: SystemKeyRepeatInterval.initialInterval,
            on: .main,
            in: .default
        )
        .autoconnect()
        .first() // Wait for the initial delay
        .flatMap { _ in
            Timer.publish(
                every: SystemKeyRepeatInterval.interval,
                on: .main,
                in: .default
            )
            .autoconnect()
        }
        .sink { _ in
            repeatPhases.insert(.repeat)
            lastRepeatTime = Date()
        }

        repeatTimer = publisher
    }

    private func stopRepeat() {
        repeatPhases.remove(.repeat)

        if let repeatTimer {
            repeatTimer.cancel()
            self.repeatTimer = nil
        }
    }
}

fileprivate struct ButtonRepeatPhaseUpdate: Equatable {
    let phases: ButtonRepeatPhases
    let timestamp: Date
}

fileprivate struct NowPlayingRepeatActionKey: PreferenceKey {
    typealias Value = ButtonRepeatPhaseUpdate

    static var defaultValue: Value {
        ButtonRepeatPhaseUpdate(phases: .up, timestamp: .distantPast)
    }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = nextValue()
    }
}

fileprivate struct ButtonRepeatActionModifier: ViewModifier {
    let action: (ButtonRepeatPhases) -> Void

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(NowPlayingRepeatActionKey.self) { newValue in
                action(newValue.phases)
            }
    }
}

extension Button {
    func buttonRepeatAction(action: @escaping (ButtonRepeatPhases) -> Void) -> some View {
        self.modifier(ButtonRepeatActionModifier(action: action))
    }
}
