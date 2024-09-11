//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

@Observable
class KeyboardShortcutStorage {

}

class KeyboardShortcut {

}



struct ShortcutEvent {

}

extension ShortcutEvent {
    enum `Type` {
        case playbackControls
        case musicSearch

        case playPause
        case nextSong
        case previousSong

        case toggleRepeatMode
        case shuffleOnOff

        case increaseSoundVolume
        case decreaseSoundVolume
        case toggleMute
    }

    typealias Phases = SwiftUI.KeyPress.Phases
}
