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
