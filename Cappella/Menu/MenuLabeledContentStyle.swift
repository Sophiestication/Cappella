//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MenuLabeledContentStyle: LabeledContentStyle {
    @Environment(\.platterGeometry) var platterGeometry

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack(alignment: .top, spacing: 5.0) {
            VStack(alignment: .trailing) {
                configuration.label
            }
            .frame(width: leadingPadding, alignment: .topTrailing)

            VStack(alignment: .leading, spacing: 0.0) {
                ForEach(subviews: configuration.content) { subview in
                    MenuItem {
                        subview
                    }
                }
            }
        }
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 180.0
        }

        return platterGeometry.contentFrame.width * 0.35
    }
}

extension LabeledContentStyle where Self == MenuLabeledContentStyle {
    @MainActor static var menu: MenuLabeledContentStyle {
        MenuLabeledContentStyle()
    }
}
