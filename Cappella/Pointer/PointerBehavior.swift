//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation
import Observation
import SwiftUI
import AppKit

@Observable
final class PointerBehavior {
    var isHidden: Bool = false {
        didSet {
            NSCursor.setHiddenUntilMouseMoves(isHidden)
        }
    }

    var location: CGPoint? = nil
}

extension EnvironmentValues {
    @Entry var pointerBehavior: PointerBehavior? = nil
}
