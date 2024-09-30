//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct DevelopmentPreviewMenu: View {
    @State var selection: DevelopmentPreviewItem.ID? = nil
    @State var collections = DevelopmentPreviewCollection.previews

    @State var nowPlaying: DevelopmentPreviewItem? = nil

    var body: some View {
        VStack(spacing: 0.0) {
            PlatterMenu(selection: $selection) {
                Section {
                    ForEach(collections) { collection in
                        LabeledContent {
                            ForEach(collection.items) { item in
                                Button {
                                    nowPlaying = item
                                } label: {
                                    Text("\(item.title)")
                                }
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
                            LabeledContent {
                                Button {
                                    nowPlaying = item
                                } label: {
                                    Label {
                                        Text("\(item.title)")
                                        Text("\(collection.subtitle) – \(collection.title)")
                                    } icon: {
                                        ArtworkView(length: 40)
//                                            .padding(.leading, 140.0)
                                    }
                                }
                                .tag(item.id)
                            } label: {
                            }
                            .labelsVisibility(.hidden)
                        }
                        .environment(\.artworkProvider, collection.artwork)
                    }
                } header: {
                    Text("Now Playing")
                }
            }
        }
        .scenePadding()
        .overlay(
            HStack {
                if let selection {
                    Text("\(selection)")
                        .lineLimit(1, reservesSpace: true)
                        .padding()
                }

                if let nowPlaying {
                    Text("\(nowPlaying.title)")
                        .lineLimit(1, reservesSpace: true)
                        .padding()
                }
            }, alignment: .topLeading
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    DevelopmentPreviewMenu()
}