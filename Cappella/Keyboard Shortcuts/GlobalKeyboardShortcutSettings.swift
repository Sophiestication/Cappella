//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

@Observable
class GlobalKeyboardShortcutSettings {
    typealias KeyboardShortcut = GlobalKeyboardShortcut
    typealias KeyboardShortcutID = GlobalKeyboardShortcut.ID

    private typealias Storage = [KeyboardShortcutID: KeyboardShortcut]
    private var all: Storage {
        didSet {
            if isRecording == false {
                keyboardShortcutHandler.update(from: all)
            }

            Self.store(all, to: userDefaults)
        }
    }

    private let userDefaults: UserDefaults
    private let keyboardShortcutHandler: GlobalKeyboardShortcutHandler

    typealias UpdateError = GlobalKeyboardShortcutHandler.UpdateError
    var didReceiveUpdateError: AnyPublisher<UpdateError, Never> {
        keyboardShortcutHandler.didReceiveUpdateError
    }

    init(
        userDefaults: UserDefaults,
        keyboardShortcutHandler: GlobalKeyboardShortcutHandler
    ) {
        self.userDefaults = userDefaults
        self.keyboardShortcutHandler = keyboardShortcutHandler

        self.all = Self.restore(from: userDefaults)
        keyboardShortcutHandler.update(from: all)
    }

    func keyboardShortcut(for id: KeyboardShortcutID) -> KeyboardShortcut? {
        all[id]
    }

    func set(_ keyboardShortcut: KeyboardShortcut?, for id: KeyboardShortcutID) {
        if keyboardShortcut == nil {
            all.removeValue(forKey: id)
        } else {
            all = all.filter { $0.value != keyboardShortcut } // remove duplicates
            all[id] = keyboardShortcut
        }

        Self.store(all, to: userDefaults)
    }

    private(set) var isRecording: Bool = false

    func beginRecording() {
        guard isRecording == false else { return }

        keyboardShortcutHandler.removeAll()
    }

    func endRecording() {
        isRecording = false
        keyboardShortcutHandler.update(from: all)
    }

    private static let userDefaultsKey = "GlobalKeyboardShortcuts"

    private static func restore(
        from userDefaults: UserDefaults
    ) -> Storage {
        guard let data = userDefaults.data(forKey: userDefaultsKey) else {
            return [:]
        }

        do {
            let all = try JSONDecoder().decode(
                Storage.self,
                from: data
            )

            return all
        } catch {
            print("Failed to decode global keyboard shortcuts: \(error)")
            return [:]
        }
    }

    private static func store(
        _ keyboardShortcuts: Storage,
        to userDefaults: UserDefaults
    ) {
        let encoded = try? JSONEncoder().encode(keyboardShortcuts)
        userDefaults.set(encoded, forKey: userDefaultsKey)
    }
}

extension EnvironmentValues {
    @Entry var globalKeyboardShortcutSettings: GlobalKeyboardShortcutSettings? = nil
}
