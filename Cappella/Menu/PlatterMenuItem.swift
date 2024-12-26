//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
