//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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

extension GlobalKeyboardShortcut {
    enum ID: Int, CaseIterable, Codable {
        case nowPlaying = 1
        case musicSearch = 2

        case playPause = 10
        case fastForward = 11
        case rewind = 12

        case toggleRepeatMode = 20
        case shuffleOnOff = 21

        case increaseSoundVolume = 30
        case decreaseSoundVolume = 31
        case toggleMute = 32
    }
}

extension GlobalKeyboardShortcut: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(modifiers.rawValue, forKey: .modifiers)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(KeyEquivalent.self, forKey: .key)

        let modifiersRawValue = try container.decode(UInt.self, forKey: .modifiers)
        modifiers = NSEvent.ModifierFlags(rawValue: modifiersRawValue)
    }

    enum CodingKeys: String, CodingKey {
        case key
        case modifiers
    }
}

extension GlobalKeyboardShortcut: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.key == rhs.key && lhs.modifiers == rhs.modifiers
    }
}

extension GlobalKeyboardShortcut: CustomStringConvertible {
    var description: String {
        "\(modifiers)\(key)"
    }
}
