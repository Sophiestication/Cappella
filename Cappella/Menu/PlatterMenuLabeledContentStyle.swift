//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuLabeledContentStyle<
    SelectionValue: Hashable
>: LabeledContentStyle {
    @Environment(\.platterGeometry) var platterGeometry

    @Binding var selection: SelectionValue?

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack(alignment: .top, spacing: 5.0) {
            VStack(alignment: .trailing) {
                configuration.label
            }
            .frame(width: leadingPadding, alignment: .topTrailing)

            VStack(alignment: .leading, spacing: 0.0) {
                ForEach(subviews: configuration.content) { subview in
                    PlatterMenuItem {
                        subview
                            .menuItemTextShadow()
                    }
                    .environment(\.menuItemID, selectionValue(for: subview))
                    .environment(\.isMenuItemSelected, isSubviewSelected(subview))
                }
            }
            .buttonStyle(PlatterMenuLabeledContentButtonStyle())
        }
    }

    private func selectionValue(for subview: Subview) -> SelectionValue? {
        subview.containerValues.tag(for: SelectionValue.self)
    }

    private func isSubviewSelected(_ subview: Subview) -> Bool {
        guard let tag = selectionValue(for: subview) else {
            return false
        }

        return selection == tag
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 180.0
        }

        return platterGeometry.contentFrame.width * 0.35
    }
}

fileprivate struct PlatterMenuLabeledContentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .menuItemTextShadow()
    }
}
