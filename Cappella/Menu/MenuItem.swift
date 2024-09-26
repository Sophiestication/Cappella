//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MenuItem<
        Content: View,
        Label: View,
        Accessory: View
    >: View {
    @Environment(\.platterGeometry) var platterGeometry
    @Environment(\.isMenuItemSelected) var isMenuItemSelected

    private var content: Content
    private var label: Label?
    private var accessory: Accessory?

    init(
        @ViewBuilder _ content: () -> Content,
        @ViewBuilder label: () -> Label,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.content = content()
        self.label = label()
        self.accessory = accessory()
    }

    init(
        @ViewBuilder _ content: () -> Content,
        @ViewBuilder label: () -> Label
    ) where Accessory == EmptyView {
        self.content = content()
        self.label = label()
        self.accessory = nil
    }

    init(
        @ViewBuilder _ content: () -> Content
    ) where Label == EmptyView, Accessory == EmptyView {
        self.content = content()
        self.label = nil
        self.accessory = nil
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer(minLength: leadingPadding)
                .overlay(
                    HStack(spacing: 0.0) {
                        Spacer()
                        accessory
                            .buttonStyle(.menuAccessory)
                        Spacer()

                        label
                    }
                    .padding(5.0),
                    alignment: .trailing
                )

            VStack(alignment: .leading) {
                content
            }

            .font(.system(size: 13, weight: .regular, design: .default))
            .fontWeight(.medium)

            .padding(5.0)

            Spacer()
        }
        .padding(5.0)
        .contentShape(contentShape)
        .background(background)

        .foregroundStyle(
            .primary,
            isMenuItemSelected ? .primary : .secondary
        )
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 140.0
        }

        return platterGeometry.contentFrame.width * 0.35
    }

    @ViewBuilder
    private var contentShape: some Shape {
        RoundedRectangle(
            cornerRadius: 10.0,
            style: .continuous
        )
    }

    @ViewBuilder
    private var background: some View {
        contentShape
            .fill(Color.accentColor)
            .opacity(isMenuItemSelected ? 1.0 : 0.0)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 10.0) {
        MenuItem {
            Text("Hello World")
        }

        MenuItem() {
            Text("Hello World")
        }
        .environment(\.isMenuItemSelected, true)
    }
    .padding(60.0)

    .environment(\.artworkProvider, PreviewArtworkProvider())
}
