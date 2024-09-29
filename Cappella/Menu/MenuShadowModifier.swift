//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

fileprivate struct MenuItemTextShadowModifier: ViewModifier {
    @Environment(\.isMenuItemSelected) var isMenuItemSelected
    @Environment(\.pixelLength) var pixelLength

    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.black.opacity(isMenuItemSelected ? 0.80 : 0.0),
                radius: pixelLength,
                y: pixelLength
            )
    }
}

extension View {
    func menuItemTextShadow() -> some View {
        self.modifier(MenuItemTextShadowModifier())
    }
}
