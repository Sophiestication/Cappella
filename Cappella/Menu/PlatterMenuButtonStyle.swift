//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuButtonStyle: PrimitiveButtonStyle {
    private let contentOnly: Bool

    init(contentOnly: Bool = false) {
        self.contentOnly = contentOnly
    }

    func makeBody(configuration: Configuration) -> some View {
        if contentOnly {
            label(for: configuration)
        } else {
            PlatterMenuItem(action: {}) {
                label(for: configuration)
            }
        }
    }

    @ViewBuilder
    private func label(for configuration: Configuration) -> some View {
        configuration.label
            .preference(
                key: PlatterMenuItemTriggerKey.self,
                value: trigger(for: configuration)
            )
    }

    private func trigger(for configuration: Configuration) -> PlatterMenuItemTrigger? {
        let trigger = PlatterMenuItemTrigger(id: UUID()) {
            configuration.trigger()
        }

        return trigger
    }
}
