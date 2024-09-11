//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

extension NSEvent.ModifierFlags {
    init(_ modifiers: EventModifiers) {
        self = []

        if modifiers.contains(.command) { self.insert(.command) }
        if modifiers.contains(.control) { self.insert(.control) }
        if modifiers.contains(.option) { self.insert(.option) }
        if modifiers.contains(.shift) { self.insert(.shift) }
        if modifiers.contains(.capsLock) { self.insert(.capsLock) }
        if modifiers.contains(.numericPad) { self.insert(.numericPad) }
    }
}
