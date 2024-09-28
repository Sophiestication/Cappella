//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct Menu<
    Content: View
>: View {
    @Environment(\.platterGeometry) var platterGeometry

    @ViewBuilder var content: Content

    typealias Selection = Set<AnyHashable>
    @Binding private var selection: Selection

    init(
        selection: Binding<Selection>,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._selection = selection
    }

    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self._selection = .constant([])
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
                                .containerValue(\.menuSelection, selection)
                        }
                    }
                }
            }
        }

        .environment(\.menuSelection, selection)
        .labeledContentStyle(.menu)

        .font(.system(size: 13, weight: .regular, design: .default))
        .fontWeight(.medium)
        .fontDesign(.rounded)
    }

    private func isSubviewSelected(_ subview: Subview) -> Bool {
        return selection.contains(subview.id)
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 180.0
        }

        return platterGeometry.contentFrame.width * 0.35
    }
}

extension EnvironmentValues {
    @Entry var menuSelection: Set<AnyHashable> = []
}

extension ContainerValues {
    @Entry var menuSelection: Set<AnyHashable> = []
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selection: Set<AnyHashable> = [
        "Off to the Races"
    ]
    @Previewable @State var collections = PreviewCollection.previews

    Menu(selection: $selection) {
        Section {
            PlaybackQueueMenuItem()
            PlaybackQueueMenuItem()
                .environment(\.isMenuItemSelected, true)
        } header: {
            Text("Now Playing")
        }

        Section {
            ForEach(collections) { collection in
                LabeledContent {
                    ForEach(collection.items) { item in
                        Text(item.title)
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
            MenuItem { Text("End Of An Era") }
            MenuItem() { Text("End Of An Era") }
                .environment(\.isMenuItemSelected, true)
            MenuItem() { Text("End Of An Era") }
                .environment(\.isMenuItemTriggering, true)
        }
    }
    .scenePadding()
}
