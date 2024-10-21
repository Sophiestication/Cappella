//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuItem<
        Content: View
    >: View {
    @Environment(\.menuItemState) var menuItemState
    @Environment(\.platterProxy) var platterProxy

    @Environment(\.pointerBehavior) var pointerBehavior

    @State private var preferredSelection: AnyHashable? = nil

    private var action: () -> Void
    private var content: Content

    @State private var trigger: PlatterMenuItemTrigger? = nil
    @State private var isTriggeringAction = false
    @State private var isHighlightedForTriggerAnimation = false

    init(
        action: @escaping () -> Void,
        @ViewBuilder _ content: () -> Content
    ) {
        self.action = action
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

        .onChange(of: menuItemState?.isTriggered ?? false, initial: true) { _, newValue in
            if newValue {
                performTrigger()
            }
        }

        .onContinuousHover(coordinateSpace: .global) { phase in
            guard let pointerBehavior else { return }
            guard let menuItemState else { return }

            switch phase {
            case .active(let location):
                if location != pointerBehavior.location &&
                   preferredSelection != menuItemState.id {
                    preferredSelection = menuItemState.id
                }
                break
            case .ended:
                if preferredSelection == menuItemState.id {
                    preferredSelection = nil
                }
                break
            }
        }

        .preference(
            key: PlatterMenuSelectionKey.self,
            value: preferredSelection
        )

        .onPreferenceChange(PlatterMenuItemTriggerKey.self) { newTrigger in
            self.trigger = newTrigger
        }
    }

    private var pointerIsHidden: Bool {
        if let pointerBehavior {
            return pointerBehavior.isHidden
        } else {
            return false
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

            if let menuItemState {
                menuItemState.isTriggered = false
            }

            if let platterProxy {
                platterProxy.dismiss()
            }

            action()
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
