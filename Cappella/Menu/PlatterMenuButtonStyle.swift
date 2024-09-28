//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PlatterMenuItem {
            configuration.label
                .menuItemTextShadow()
        }
    }
}
