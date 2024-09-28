//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenu<
    Content: View,
    SelectionValue: Hashable
>: View {
    @Environment(\.platterGeometry) var platterGeometry

    @ViewBuilder var content: Content

    @Binding private var selection: SelectionValue

    init(
        selection: Binding<SelectionValue>,
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

                    VStack(spacing: 0.0) {
                        ForEach(section.content) { subview in
                            subview
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
    }

    private func isSubviewSelected(_ subview: Subview) -> Bool {
        guard let tag = subview.containerValues.tag(for: SelectionValue.self) else {
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

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selection: PreviewItem.ID = "Born to Die"
    @Previewable @State var collections = PreviewCollection.previews

    PlatterMenu(selection: $selection) {
        Section {
            ForEach(collections) { collection in
                LabeledContent {
                    ForEach(collection.items) { item in
                        Button {

                        } label: {
                            Text("\(item.title)")
                        }
                        .environment(\.isMenuItemSelected, item.id == selection)
                    }
                } label: {
                    ArtworkView(length: 64)
                    Text(collection.title)
                    Text(collection.subtitle)
                        .foregroundStyle(.secondary)
                }
                .environment(\.artworkProvider, collection.artwork)
            }
        } header: {
            Text("Recently Played")
        }

        Section {
            ForEach(collections) { collection in
                ForEach(collection.items) { item in
                    Label {
                        Text("\(item.title)")
                        Text("\(collection.subtitle) – \(collection.title)")
                    } icon: {
                        ArtworkView(length: 40)
                    }
                }
                .environment(\.artworkProvider, collection.artwork)
            }
        } header: {
            Text("Now Playing")
        }
    }
    .scenePadding()
}
