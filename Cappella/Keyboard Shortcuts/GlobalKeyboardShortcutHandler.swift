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

import Foundation
import Combine
import SwiftUI
import AppKit
import Carbon
import IOKit

final class GlobalKeyboardShortcutHandler {
    typealias KeyboardShortcut = GlobalKeyboardShortcut
    typealias KeyboardShortcutID = GlobalKeyboardShortcut.ID

    private struct Entry {
        let keyboardShortcut: KeyboardShortcut
        let eventHotKey: EventHotKeyRef
    }

    private var entries: [KeyboardShortcutID: Entry] = [:]
    private var eventHandler: EventHandlerRef? = nil
    private var keyPressTimers: [KeyboardShortcutID: AnyCancellable] = [:]

    private let keyPressRepeatInterval: TimeInterval
    private let initialKeyPressDelay: TimeInterval

    struct Event {
        let id: GlobalKeyboardShortcut.ID
        let keyboardShortcut: GlobalKeyboardShortcut
        let phase: KeyPress.Phases
    }

    private let keyPressEventSubject = PassthroughSubject<Event, Never>()

    var didReceiveEvent: AnyPublisher<Event, Never> {
        keyPressEventSubject.eraseToAnyPublisher()
    }

    struct UpdateError: Error {
        let keyboardShortcutID: KeyboardShortcutID
        let keyboardShortcut: KeyboardShortcut
    }

    private let keyboardShortcutUpdateErrorSubject = PassthroughSubject<UpdateError, Never>()

    var didReceiveUpdateError: AnyPublisher<UpdateError, Never> {
        keyboardShortcutUpdateErrorSubject.eraseToAnyPublisher()
    }

    init() {
        self.keyPressRepeatInterval = SystemKeyRepeatInterval.interval
        self.initialKeyPressDelay = SystemKeyRepeatInterval.initialInterval

        let mutableSelf = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let hotKeyEventSpec = [
            EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            ),
            EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyReleased)
            )
        ]

        let error = InstallEventHandler(
            GetEventDispatcherTarget(),
            hotKeyEventHandler,
            2,
            hotKeyEventSpec,
            mutableSelf,
            &eventHandler
        )

        if error != noErr {
            print("Could not install hot key event handler.")
        }
    }

    deinit {
        entries.keys.forEach(unregister)
    }

    func update(from settings: [KeyboardShortcutID: KeyboardShortcut]) {
        for (id, keyboardShortcut) in settings {
            if let entry = entries[id] {
                if entry.keyboardShortcut != keyboardShortcut {
                    unregister(id)
                    register(keyboardShortcut, for: id)
                }
            } else {
                register(keyboardShortcut, for: id)
            }
        }

        for id in entries.keys where settings[id] == nil {
            unregister(id)
        }
    }

    func removeAll() {
        for id in entries.keys {
            unregister(id)
        }
    }

    private func register(_ keyboardShortcut: KeyboardShortcut, for id: KeyboardShortcutID) {
        let eventHotKey = EventHotKeyID(
            signature: Self.hotKeyEventSignature,
            id: UInt32(id.rawValue)
        )

        var hotKeyEvent: EventHotKeyRef?

        let error = RegisterEventHotKey(
            UInt32(keyboardShortcut.key.keyCode),
            carbonModifiers(from: keyboardShortcut.modifiers),
            eventHotKey,
            GetEventDispatcherTarget(),
            0,
            &hotKeyEvent
        )

        guard error == noErr else {
            print("Could not register hot key for: \(keyboardShortcut)")

            keyboardShortcutUpdateErrorSubject.send(
                UpdateError(keyboardShortcutID: id, keyboardShortcut: keyboardShortcut)
            )

            return
        }

        guard let hotKeyEvent else { return }

        entries[id] = Entry(keyboardShortcut: keyboardShortcut, eventHotKey: hotKeyEvent)
    }

    private func unregister(_ id: KeyboardShortcutID) {
        if let entry = entries[id] {
            if UnregisterEventHotKey(entry.eventHotKey) != noErr {
                print("Could not unregister hot key for: \(id)")
            }

            entries.removeValue(forKey: id)
        }
    }

    fileprivate static let hotKeyEventSignature: UInt32 = {
        let string = "SSHk"
        var result: FourCharCode = 0

        for char in string.utf16 {
            result = (result << 8) + FourCharCode(char)
        }

        return result
    }()

    fileprivate func handleHotKeyEvent(
        _ event: EventRef,
        _ eventHotKeyID: EventHotKeyID
    ) -> OSStatus {
        let element = entries.first { (key: KeyboardShortcutID, value: Entry) in
            key.rawValue == eventHotKeyID.id
        }
        guard let element else { return OSStatus(eventNotHandledErr) }

        let id = element.key
        let keyboardShortcut = element.value.keyboardShortcut

        switch GetEventKind(event) {
        case UInt32(kEventHotKeyPressed):
            keyPressEventSubject.send(
                Event(id: id, keyboardShortcut: keyboardShortcut, phase: .down)
            )
            startRepeat(for: id, with: keyboardShortcut)

            return noErr
        case UInt32(kEventHotKeyReleased):
            keyPressEventSubject.send(
                Event(id: id, keyboardShortcut: keyboardShortcut, phase: .up)
            )
            stopRepeat(for: id)

            return noErr
        default:
            return OSStatus(eventNotHandledErr)
        }
    }

    private func startRepeat(for id: KeyboardShortcutID, with keyboardShortcut: KeyboardShortcut) {
        stopRepeat(for: id)

        let publisher = Timer.publish(every: initialKeyPressDelay, on: .main, in: .default)
            .autoconnect()
            .first() // Wait for the initial delay
            .flatMap { _ in
                Timer.publish(
                    every: self.keyPressRepeatInterval,
                    on: .main,
                    in: .default
                )
                .autoconnect()
            }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.keyPressEventSubject.send(
                    Event(id: id, keyboardShortcut: keyboardShortcut, phase: .repeat)
                )
            }

        keyPressTimers[id] = publisher
    }

    private func stopRepeat(for id: KeyboardShortcutID) {
        keyPressTimers[id]?.cancel()
        keyPressTimers.removeValue(forKey: id)
    }

    private func carbonModifiers(from modifiers: KeyboardShortcut.EventModifiers) -> UInt32 {
        var carbonModifiers: UInt32 = 0

        if modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if modifiers.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }
        if modifiers.contains(.option) { carbonModifiers |= UInt32(optionKey) }
        if modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }
        if modifiers.contains(.capsLock) { carbonModifiers |= UInt32(alphaLock) }

        return carbonModifiers
    }
}

extension GlobalKeyboardShortcutHandler {
    @MainActor static let shared = GlobalKeyboardShortcutHandler()
}

fileprivate func hotKeyEventHandler(
    eventHandlerCall: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let event, let userData else {
        return OSStatus(eventNotHandledErr)
    }

    var eventHotKeyID = EventHotKeyID()

    let error = GetEventParameter(
        event,
        UInt32(kEventParamDirectObject),
        UInt32(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &eventHotKeyID
    )

    if error != noErr {
        return error
    }

    guard eventHotKeyID.signature == GlobalKeyboardShortcutHandler.hotKeyEventSignature else {
        return OSStatus(eventNotHandledErr)
    }

    let handler = Unmanaged<GlobalKeyboardShortcutHandler>
        .fromOpaque(userData)
        .takeUnretainedValue()
    return handler.handleHotKeyEvent(event, eventHotKeyID)
}

extension EnvironmentValues {
    @Entry var currentGlobalKeyboardShortcutEvent: GlobalKeyboardShortcutHandler.Event? = nil
}
