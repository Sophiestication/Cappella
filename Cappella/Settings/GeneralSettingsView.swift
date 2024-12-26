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

struct GeneralSettingsView: View {
    @AppStorage("menuBarExtraShown") private var menuBarExtraShown = true
    @AppStorage("dockItemShown") private var dockItemShown = true

    @AppStorage("dockTileArtworkShown") private var dockTileArtworkShown = false

    @AppStorage("playerNotifications") private var playerNotifications: PlayerNotificationStyle = .album

    var body: some View {
        Form {
            Section {
                LabeledContent {
                    VStack(alignment: .leading) {
                        Toggle("Menu Bar", isOn: $menuBarExtraShown)
                        Toggle("Dock", isOn: $dockItemShown)
                    }
                } label: {
                    Text("Show Application Icon in:")
                }
            }

            Section {
                LabeledContent {
                    Toggle("Album Artwork in Dock", isOn: $dockTileArtworkShown)
                } label: {
                    Text("Show:")
                }
            }

            Section {
                Picker(selection: $playerNotifications, content: {
                    Text("Never").tag(PlayerNotificationStyle.off)
                    Text("On album change").tag(PlayerNotificationStyle.album)
                    Text("On song change").tag(PlayerNotificationStyle.song)
                }, label: {
                    Text("Show Now Playing Notifications:")
                })
                .pickerStyle(.radioGroup)
            } footer: {
                Text("Now Playing Notifications are sent out whenever a new song starts playing in iTunes, but not when the change was triggered by the user.")
                    .font(.footnote)
                    .frame(maxWidth: 280.0)
            }
        }
    }
}

extension GeneralSettingsView {
    enum PlayerNotificationStyle: Int {
        case off = 0
        case album = 1
        case song = 2
    }
}

#Preview {
    SettingsView()
}
