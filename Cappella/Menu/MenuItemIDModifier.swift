//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

fileprivate struct MenuItemTextShadowModifier2: ViewModifier {
    @Environment(\.isMenuItemSelected) var isMenuItemSelected
    @Environment(\.pixelLength) var pixelLength

    func body(content: Content) -> some View {
        content
            .shadow(
                color: Color.black.opacity(isMenuItemSelected ? 0.5 : 0.0),
                radius: pixelLength,
                y: pixelLength
            )
    }
}
