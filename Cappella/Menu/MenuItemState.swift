//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

class MenuItemState: ObservableObject, Identifiable, Equatable, CustomDebugStringConvertible {
    @Published var id: AnyHashable

    @Published var isSelected: Bool
    @Published var isTriggered: Bool

    @Published var trigger: () -> Void

    init(
        _ id: AnyHashable,
        isSelected: Bool = false,
        isTriggered: Bool = false
    ) {
        self.id = id
        self.isSelected = isSelected
        self.isTriggered = isTriggered
        self.trigger = {}
    }

    static func == (lhs: MenuItemState, rhs: MenuItemState) -> Bool {
        return lhs.id == rhs.id &&
        lhs.isSelected == rhs.isSelected &&
        lhs.isTriggered == rhs.isTriggered
    }

    var debugDescription: String {
        return """
        MenuItemState(
            id: \(id),
            isSelected: \(isSelected),
            isTriggered: \(isTriggered)
        )
        """
    }
}

extension EnvironmentValues {
    @Entry var menuItemState: MenuItemState? = nil
}
