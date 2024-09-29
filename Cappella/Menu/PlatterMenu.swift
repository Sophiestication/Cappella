//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenu<
    Content: View,
    SelectionValue: Hashable
>: View {
    @Environment(\.platterGeometry) private var platterGeometry

    @ViewBuilder private var content: Content
    @Binding private var selection: SelectionValue?

    init(
        selection: Binding<SelectionValue?>,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._selection = selection
    }

    var body: some View {
        Group(sections: content) { sections in
            ForEach(sections) { section in
                VStack(alignment: .leading) {
                    ForEach(section.header) { header in
                        header
                    }
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .alignmentGuide(.leading) { guide in
                        -leadingPadding - 15.0
                    }

                    LazyVStack(spacing: 0.0) {
                        ForEach(section.content) { subview in
                            subview
                                .environment(\.menuItemID, selectionValue(for: subview))
                                .environment(\.isMenuItemSelected, isSubviewSelected(subview))
                        }
                    }
                }
            }
        }

        .labelStyle(PlatterMenuLabelStyle())
        .buttonStyle(PlatterMenuButtonStyle())
        .labeledContentStyle(PlatterMenuLabeledContentStyle(selection: $selection))

        .font(.system(size: 13, weight: .regular, design: .default))
        .fontWeight(.medium)
        .fontDesign(.rounded)

        .onPreferenceChange(PlatterMenuSelectionKey.self) { newSelection in
            self.selection = newSelection as? SelectionValue
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

struct PlatterMenuSelectionKey: PreferenceKey {
    typealias Value = AnyHashable?

    static var defaultValue: Value { nil }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }
}
