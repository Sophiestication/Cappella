//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import AppKit
import Carbon

struct CompatibilityKeyEquivalent {
    let keyCode: Int

    init(_ keyCode: Int) {
        self.keyCode = keyCode
    }

    init(with event: NSEvent) {
        self.init(Int(event.keyCode))
    }
}

extension CompatibilityKeyEquivalent: Codable {
    enum CodingKeys: String, CodingKey {
        case keyCode
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keyCode, forKey: .keyCode)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        keyCode = try container.decode(Int.self, forKey: .keyCode)
    }
}

extension CompatibilityKeyEquivalent: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.keyCode == rhs.keyCode
    }
}

// System keycodes
extension CompatibilityKeyEquivalent {
    static let a = Self(kVK_ANSI_A)
    static let s = Self(kVK_ANSI_S)
    static let d = Self(kVK_ANSI_D)
    static let f = Self(kVK_ANSI_F)
    static let h = Self(kVK_ANSI_H)
    static let g = Self(kVK_ANSI_G)
    static let z = Self(kVK_ANSI_Z)
    static let x = Self(kVK_ANSI_X)
    static let c = Self(kVK_ANSI_C)
    static let v = Self(kVK_ANSI_V)
    static let b = Self(kVK_ANSI_B)
    static let q = Self(kVK_ANSI_Q)
    static let w = Self(kVK_ANSI_W)
    static let e = Self(kVK_ANSI_E)
    static let r = Self(kVK_ANSI_R)
    static let y = Self(kVK_ANSI_Y)
    static let t = Self(kVK_ANSI_T)
    static let one = Self(kVK_ANSI_1)
    static let two = Self(kVK_ANSI_2)
    static let three = Self(kVK_ANSI_3)
    static let four = Self(kVK_ANSI_4)
    static let six = Self(kVK_ANSI_6)
    static let five = Self(kVK_ANSI_5)
    static let equal = Self(kVK_ANSI_Equal)
    static let nine = Self(kVK_ANSI_9)
    static let seven = Self(kVK_ANSI_7)
    static let minus = Self(kVK_ANSI_Minus)
    static let eight = Self(kVK_ANSI_8)
    static let zero = Self(kVK_ANSI_0)
    static let rightBracket = Self(kVK_ANSI_RightBracket)
    static let o = Self(kVK_ANSI_O)
    static let u = Self(kVK_ANSI_U)
    static let leftBracket = Self(kVK_ANSI_LeftBracket)
    static let i = Self(kVK_ANSI_I)
    static let p = Self(kVK_ANSI_P)
    static let l = Self(kVK_ANSI_L)
    static let j = Self(kVK_ANSI_J)
    static let quote = Self(kVK_ANSI_Quote)
    static let k = Self(kVK_ANSI_K)
    static let semicolon = Self(kVK_ANSI_Semicolon)
    static let backslash = Self(kVK_ANSI_Backslash)
    static let comma = Self(kVK_ANSI_Comma)
    static let slash = Self(kVK_ANSI_Slash)
    static let n = Self(kVK_ANSI_N)
    static let m = Self(kVK_ANSI_M)
    static let period = Self(kVK_ANSI_Period)
    static let grave = Self(kVK_ANSI_Grave)
    static let keypadDecimal = Self(kVK_ANSI_KeypadDecimal)
    static let keypadMultiply = Self(kVK_ANSI_KeypadMultiply)
    static let keypadPlus = Self(kVK_ANSI_KeypadPlus)
    static let keypadClear = Self(kVK_ANSI_KeypadClear)
    static let keypadDivide = Self(kVK_ANSI_KeypadDivide)
    static let keypadEnter = Self(kVK_ANSI_KeypadEnter)
    static let keypadMinus = Self(kVK_ANSI_KeypadMinus)
    static let keypadEquals = Self(kVK_ANSI_KeypadEquals)
    static let keypadZero = Self(kVK_ANSI_Keypad0)
    static let keypadOne = Self(kVK_ANSI_Keypad1)
    static let keypadTwo = Self(kVK_ANSI_Keypad2)
    static let keypadThree = Self(kVK_ANSI_Keypad3)
    static let keypadFour = Self(kVK_ANSI_Keypad4)
    static let keypadFive = Self(kVK_ANSI_Keypad5)
    static let keypadSix = Self(kVK_ANSI_Keypad6)
    static let keypadSeven = Self(kVK_ANSI_Keypad7)
    static let keypadEight = Self(kVK_ANSI_Keypad8)
    static let keypadNine = Self(kVK_ANSI_Keypad9)
}

// Keycodes for keys that are independent of keyboard layout
extension CompatibilityKeyEquivalent {
    static let `return` = Self(kVK_Return)
    static let tab = Self(kVK_Tab)
    static let space = Self(kVK_Space)
    static let delete = Self(kVK_Delete)
    static let escape = Self(kVK_Escape)
    static let command = Self(kVK_Command)
    static let shift = Self(kVK_Shift)
    static let capsLock = Self(kVK_CapsLock)
    static let option = Self(kVK_Option)
    static let control = Self(kVK_Control)
    static let rightCommand = Self(kVK_RightCommand)
    static let rightShift = Self(kVK_RightShift)
    static let rightOption = Self(kVK_RightOption)
    static let rightControl = Self(kVK_RightControl)
    static let function = Self(kVK_Function)
    static let f17 = Self(kVK_F17)
    static let volumeUp = Self(kVK_VolumeUp)
    static let volumeDown = Self(kVK_VolumeDown)
    static let mute = Self(kVK_Mute)
    static let f18 = Self(kVK_F18)
    static let f19 = Self(kVK_F19)
    static let f20 = Self(kVK_F20)
    static let f5 = Self(kVK_F5)
    static let f6 = Self(kVK_F6)
    static let f7 = Self(kVK_F7)
    static let f3 = Self(kVK_F3)
    static let f8 = Self(kVK_F8)
    static let f9 = Self(kVK_F9)
    static let f11 = Self(kVK_F11)
    static let f13 = Self(kVK_F13)
    static let f16 = Self(kVK_F16)
    static let f14 = Self(kVK_F14)
    static let f10 = Self(kVK_F10)
    static let contextualMenu = Self(kVK_ContextualMenu)
    static let f12 = Self(kVK_F12)
    static let f15 = Self(kVK_F15)
    static let help = Self(kVK_Help)
    static let home = Self(kVK_Home)
    static let pageUp = Self(kVK_PageUp)
    static let forwardDelete = Self(kVK_ForwardDelete)
    static let f4 = Self(kVK_F4)
    static let end = Self(kVK_End)
    static let f2 = Self(kVK_F2)
    static let pageDown = Self(kVK_PageDown)
    static let f1 = Self(kVK_F1)
    static let leftArrow = Self(kVK_LeftArrow)
    static let rightArrow = Self(kVK_RightArrow)
    static let downArrow = Self(kVK_DownArrow)
    static let upArrow = Self(kVK_UpArrow)
}

extension CompatibilityKeyEquivalent: CustomStringConvertible {
    var description: String {
        switch keyCode {

        // Alphabet keys
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_T: return "T"

        // Number and symbol keys
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_Equal: return "="
        case kVK_ANSI_Minus: return "-"
        case kVK_ANSI_LeftBracket: return "["
        case kVK_ANSI_RightBracket: return "]"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_Quote: return "\u{0027}"  // '
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_Semicolon: return ";"
        case kVK_ANSI_Backslash: return "\\"
        case kVK_ANSI_Comma: return ","
        case kVK_ANSI_Slash: return "/"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_M: return "M"
        case kVK_ANSI_Period: return "."
        case kVK_ANSI_Grave: return "\u{0060}"  // `

        // Special keys
        case kVK_Return: return "\u{2305}"  // ⏎
        case kVK_Tab: return "\u{21E4}"     // ⇤
        case kVK_Space: return "Space" // "\u{2423}"   // ␣
        case kVK_Delete: return "\u{232B}"  // ⌫
        case kVK_Escape: return "\u{238B}"  // ⎋
        case kVK_Command: return "\u{2318}" // ⌘
        case kVK_Shift: return "\u{21E7}"   // ⇧
        case kVK_CapsLock: return "\u{21EA}" // ⇪
        case kVK_Option: return "\u{2325}"  // ⌥
        case kVK_Control: return "\u{2303}" // ⌃
        case kVK_RightCommand: return "\u{2318}" // ⌘
        case kVK_RightShift: return "\u{21E7}"   // ⇧
        case kVK_RightOption: return "\u{2325}"  // ⌥
        case kVK_RightControl: return "\u{2303}" // ⌃
        case kVK_Function: return "fn"           // Function key
        case kVK_VolumeUp: return "\u{1F50A}"    // 🔊
        case kVK_VolumeDown: return "\u{1F509}"  // 🔉
        case kVK_Mute: return "\u{1F507}"        // 🔇

        // Function keys with macOS-style representations
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        case kVK_F13: return "F13"
        case kVK_F14: return "F14"
        case kVK_F15: return "F15"
        case kVK_F16: return "F16"
        case kVK_F17: return "F17"
        case kVK_F18: return "F18"
        case kVK_F19: return "F19"
        case kVK_F20: return "F20"

        // Miscellaneous keys
        case kVK_ContextualMenu: return "\u{2263}"  // ≣
        case kVK_Help: return "\u{003F}"            // ?
        case kVK_Home: return "Home" // "\u{2302}"            // ⌂
        case kVK_PageUp: return "\u{21DE}"          // ⇞
        case kVK_ForwardDelete: return "\u{2326}"   // ⌦
        case kVK_End: return "End" // \u{21F2}"             // ⇲
        case kVK_PageDown: return "\u{21DF}"        // ⇟

        // Arrow keys
        case kVK_LeftArrow: return "\u{2190}"  // ←
        case kVK_RightArrow: return "\u{2192}" // →
        case kVK_DownArrow: return "\u{2193}"  // ↓
        case kVK_UpArrow: return "\u{2191}"    // ↑

        // Keypad
        case kVK_ANSI_Keypad0: return "\u{0030}"        // 0
        case kVK_ANSI_Keypad1: return "\u{0031}"        // 1
        case kVK_ANSI_Keypad2: return "\u{0032}"        // 2
        case kVK_ANSI_Keypad3: return "\u{0033}"        // 3
        case kVK_ANSI_Keypad4: return "\u{0034}"        // 4
        case kVK_ANSI_Keypad5: return "\u{0035}"        // 5
        case kVK_ANSI_Keypad6: return "\u{0036}"        // 6
        case kVK_ANSI_Keypad7: return "\u{0037}"        // 7
        case kVK_ANSI_Keypad8: return "\u{0038}"        // 8
        case kVK_ANSI_Keypad9: return "\u{0039}"        // 9
        case kVK_ANSI_KeypadDecimal: return "\u{002E}"  // .
        case kVK_ANSI_KeypadMultiply: return "\u{00D7}" // ×
        case kVK_ANSI_KeypadDivide: return "\u{00F7}"   // ÷
        case kVK_ANSI_KeypadPlus: return "\u{002B}"     // +
        case kVK_ANSI_KeypadMinus: return "\u{2212}"    // −
        case kVK_ANSI_KeypadClear: return "\u{2327}"    // ⌧
        case kVK_ANSI_KeypadEquals: return "\u{003D}"   // =
        case kVK_ANSI_KeypadEnter: return "\u{21B5}"    // ↵

        default: return "\u{FFFD}"  // Unknown key representation
        }
    }
}
