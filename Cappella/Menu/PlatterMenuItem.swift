//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuItem<
        Content: View
    >: View {
    @Environment(\.menuItemState) var menuItemState
    @Environment(\.platterProxy) var platterProxy

    @State private var preferredSelection: AnyHashable? = nil

    private var content: Content

    @State private var trigger: PlatterMenuItemTrigger? = nil
    @State private var isTriggeringAction = false
    @State private var isHighlightedForTriggerAnimation = false

    init(
        @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                content
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 10.0)
            .padding(.vertical, 5.0)

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
                performTrigger()
            }
        }
        .onKeyPress(.return) {
            if let trigger {
                trigger()
                performTrigger()

                return .handled
            }

            return .ignored
        }

//        .onHover {
//            preferredSelection = $0 ? menuItemState?.id : nil
//        }
        .preference(
            key: PlatterMenuSelectionKey.self,
            value: preferredSelection
        )

        .onPreferenceChange(PlatterMenuItemTriggerKey.self) { newTrigger in
            self.trigger = newTrigger
        }
    }

    private var cornerRadius: CGFloat {
        5.0
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

    private func performTrigger() {
        isTriggeringAction = true
        isHighlightedForTriggerAnimation = true

        withAnimation(.easeInOut(duration: 0.1).repeatCount(3)) {
            isHighlightedForTriggerAnimation = false
        } completion: {
            isTriggeringAction = false

            if let platterProxy {
                platterProxy.dismiss()
            }
        }
    }

    private var shouldHighlight: Bool {
        if isTriggeringAction {
            return isHighlightedForTriggerAnimation
        }

        guard let menuItemState else {
            return false
        }

        return menuItemState.isSelected
    }
}
