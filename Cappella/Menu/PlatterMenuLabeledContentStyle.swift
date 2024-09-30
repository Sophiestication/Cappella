//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuLabeledContentStyle<
    SelectionValue: Hashable
>: LabeledContentStyle {
    @Environment(\.labelsVisibility) var labelsVisibility

    @Binding var selection: SelectionValue?

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack(alignment: .top, spacing: 5.0) {
            if labelsVisibility != .hidden {
                VStack(alignment: .trailing) {
                    configuration.label
                }
                .frame(width: 180.0, alignment: .topTrailing)
            }

            VStack(alignment: .leading, spacing: 0.0) {
                ForEach(subviews: configuration.content) { subview in
                    PlatterMenuItem {
                        subview
                            .menuItemTextShadow()
                    }
                    .environment(\.menuItemState, menuItemState(for: subview))
                }
            }
            .buttonStyle(PlatterMenuButtonStyle(contentOnly: true))
        }
    }

    private func menuItemState(for subview: Subview) -> MenuItemState? {
        guard let id = subview.containerValues.tag(for: SelectionValue.self) else {
            return nil
        }

        return MenuItemState(
            id,
            isSelected: selection == id,
            isTriggered: false
        )
    }
}
