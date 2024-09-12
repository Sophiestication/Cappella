//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

@Observable
class GlobalKeyboardShortcutSettings {
    typealias KeyboardShortcut = GlobalKeyboardShortcut
    typealias KeyboardShortcutID = GlobalKeyboardShortcut.ID

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

    private typealias Storage = [KeyboardShortcutID: KeyboardShortcut]
    private var all: Storage {
        didSet {
            Self.store(all, to: userDefaults)
        }
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.all = Self.restore(from: userDefaults)
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
