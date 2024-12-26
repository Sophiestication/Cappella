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

struct PlatterMenuLabeledContentStyle<
    SelectionValue: Hashable
>: LabeledContentStyle {
    @Environment(\.labelsVisibility) var labelsVisibility
    @Environment(\.platterGeometry) var platterGeometry

    @Binding var selection: SelectionValue?
    @Binding var triggered: SelectionValue?

    func makeBody(configuration: Self.Configuration) -> some View {
        HStack(alignment: .top, spacing: 5.0) {
            if labelsVisibility != .hidden {
                VStack(alignment: .trailing) {
                    configuration.label
                        .multilineTextAlignment(.trailing)
                }
                .frame(width: leadingPadding, alignment: .topTrailing)
            }

            LazyVStack(alignment: .leading, spacing: 0.0) {
                ForEach(subviews: configuration.content) { subview in
                    PlatterMenuItem(action: {
                        triggered = nil
                    }) {
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
            isTriggered: triggered == id
        )
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 0.0
        }

        return platterGeometry.contentFrame.width * 0.3
    }
}
