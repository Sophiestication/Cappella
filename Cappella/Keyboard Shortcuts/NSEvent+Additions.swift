//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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

extension NSEvent.ModifierFlags: @retroactive CustomStringConvertible {
    public var description: String {
        var string = ""

        if contains(.command) { string += "\u{2318}" }
        if contains(.control) { string += "\u{2303}" }
        if contains(.option) { string += "\u{2325}" }
        if contains(.shift) { string += "\u{21E7}" }
        if contains(.capsLock) { string += "\u{21EA}" }
        if contains(.numericPad) { string += "Pad" }

        return string
    }
}
