//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

struct GlobalKeyboardShortcut {
    typealias KeyEquivalent = CompatibilityKeyEquivalent
    let key: KeyEquivalent

    typealias EventModifiers = NSEvent.ModifierFlags
    let modifiers: EventModifiers

    init(
        _ key: KeyEquivalent,
        modifiers: EventModifiers = .command
    ) {
        self.key = key
        self.modifiers = modifiers
    }

    init(with event: NSEvent) {
        self.init(
            KeyEquivalent(with: event),
            modifiers: event.modifierFlags
        )
    }
}
