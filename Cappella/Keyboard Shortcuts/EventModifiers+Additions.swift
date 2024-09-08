//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

extension SwiftUI.EventModifiers {
    var NSEventModifierFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []

        if self.contains(.command) { flags.insert(.command) }
        if self.contains(.control) { flags.insert(.control) }
        if self.contains(.option) { flags.insert(.option) }
        if self.contains(.shift) { flags.insert(.shift) }
        if self.contains(.capsLock) { flags.insert(.capsLock) }
        if self.contains(.numericPad) { flags.insert(.numericPad) }

        return flags
    }
}
