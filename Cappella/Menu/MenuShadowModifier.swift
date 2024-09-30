//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

fileprivate struct MenuItemTextShadowModifier: ViewModifier {
    @Environment(\.menuItemState) var menuItemState
    @Environment(\.pixelLength) var pixelLength

    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.black.opacity(shouldHighlight ? 0.80 : 0.0),
                radius: pixelLength,
                y: pixelLength
            )
    }

    private var shouldHighlight: Bool {
        guard let menuItemState else {
            return false
        }

        return menuItemState.isSelected
    }
}

extension View {
    func menuItemTextShadow() -> some View {
        self.modifier(MenuItemTextShadowModifier())
    }
}
