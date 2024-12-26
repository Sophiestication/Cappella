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

struct DevelopmentPreviewMenu: View {
    @State var selection: DevelopmentPreviewItem.ID? = nil
    @State var triggered: DevelopmentPreviewItem.ID? = nil
    @State var collections = DevelopmentPreviewCollection.previews

    @State var nowPlaying: DevelopmentPreviewItem? = nil

    var body: some View {
        VStack(spacing: 0.0) {
            PlatterMenu(selection: $selection, triggered: $triggered) {
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
