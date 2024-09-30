//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuItem<
        Content: View,
        Label: View,
        Accessory: View
    >: View {
    @Environment(\.platterGeometry) var platterGeometry
    @Environment(\.menuItemState) var menuItemState

    @State private var preferredSelection: AnyHashable? = nil

    private var content: Content
    private var label: Label?
    private var accessory: Accessory?

    @State private var trigger: PlatterMenuItemTrigger? = nil
    @State private var isBlinking: Bool = false

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
        HStack {
            if isContentOnly == false {
                Spacer(minLength: leadingPadding)
                    .overlay(
                        HStack(spacing: 0.0) {
                            Spacer()
                            accessory
                                .buttonStyle(.menuAccessory)
                                .menuItemTextShadow()
                                .opacity(shouldHighlight ? 1.0 : 0.0)
                            Spacer()

                            label.offset(x: -4.0) // TODO
                        },
                        alignment: .trailing
                    )
            }

            VStack(alignment: .leading) {
                content
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 10.0)
            .padding(.vertical, 5.0)

            .padding(.vertical, isContentOnly ? 0.0 : 5.0)

            Spacer()
        }
        .contentShape(contentShape)
        .background(background)

        .foregroundStyle(
            .primary,
            shouldHighlight ? .primary : .secondary
        )

        .onTapGesture {
            if let trigger {
                trigger()
            }
        }
        .onKeyPress(.return) {
            if let trigger {
                trigger()
            }

            return .handled
        }

        .onChange(of: menuItemState, initial: true) { _, newState in
            guard let newState,
                  newState.isTriggered == true else {
                isBlinking = false
                return
            }

            withAnimation(.easeInOut(duration: 0.1).repeatCount(3)) {
                isBlinking = true
            } completion: {
                isBlinking = false
            }
        }

        .onHover {
            preferredSelection = $0 ? menuItemState?.id : nil
        }
        .preference(
            key: PlatterMenuSelectionKey.self,
            value: preferredSelection
        )

        .onPreferenceChange(PlatterMenuItemTriggerKey.self) { newTrigger in
            self.trigger = newTrigger
        }
    }

    private var isContentOnly: Bool {
        label == nil
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 180.0
        }

        return platterGeometry.contentFrame.width * 0.35
    }

    private var cornerRadius: CGFloat {
        isContentOnly ? 5.0 : 10.0
    }

    @ViewBuilder
    private var contentShape: some Shape {
        RoundedRectangle(
            cornerRadius: cornerRadius,
            style: .continuous
        )
    }

    @ViewBuilder
    private var background: some View {
        contentShape
            .fill(Color.accentColor)
            .opacity(shouldHighlight ? 1.0 : 0.0)
    }

    private var shouldHighlight: Bool {
        if isBlinking {
            return true
        }

        guard let menuItemState else {
            return false
        }

        return menuItemState.isSelected
    }
}