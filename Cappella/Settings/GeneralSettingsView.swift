//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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
