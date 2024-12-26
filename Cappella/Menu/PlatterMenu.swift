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

struct PlatterMenu<
    Content: View,
    SelectionValue: Hashable
>: View {
    @Environment(\.platterGeometry) private var platterGeometry

    @ViewBuilder private var content: Content
    @Binding private var selection: SelectionValue?
    @Binding private var triggered: SelectionValue?

    init(
        selection: Binding<SelectionValue?>,
        triggered: Binding<SelectionValue?>,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._selection = selection
        self._triggered = triggered
    }

    var body: some View {
        let currentLeadingPadding = leadingPadding

        Group(sections: content) { sections in
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: 0.0) {
                    ForEach(section.header) { header in
                        header
                    }
                    .font(.system(size: 16))
                    .alignmentGuide(.leading) { guide in
                        -currentLeadingPadding - 15.0
                    }

                    VStack(spacing: 0.0) {
                        ForEach(section.content) { subview in
                            subview
                        }
                    }
                }
            }
        }

        .buttonStyle(PlatterMenuButtonStyle(contentOnly: false))
        .labelStyle(PlatterMenuLabelStyle())
        .labeledContentStyle(PlatterMenuLabeledContentStyle(
            selection: $selection,
            triggered: $triggered
        ))

        .font(.system(size: 13))

        .onPreferenceChange(PlatterMenuSelectionKey.self) { newSelection in
            self.selection = newSelection as? SelectionValue
        }
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 180.0
        }

        return platterGeometry.contentFrame.width * 0.35
    }
}

struct PlatterMenuSelectionKey: PreferenceKey {
    typealias Value = AnyHashable?

    static var defaultValue: Value { nil }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }
}
