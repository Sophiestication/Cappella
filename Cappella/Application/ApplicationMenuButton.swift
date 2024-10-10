//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct ApplicationMenuButton: View {
    @Environment(\.openSettings) private var openSettings

    typealias MusicPlayerType = CappellaMusicPlayer
    private let musicPlayer: MusicPlayerType

    @ObservedObject private var playbackState: MusicPlayerType.State

    init(using musicPlayer: MusicPlayerType) {
        self.musicPlayer = musicPlayer
        self.playbackState = musicPlayer.playbackState
    }

    var body: some View {
        Menu {
            Button(playPauseTitle, action: {
                musicPlayer.playPause()
            })
            Button("Next Track", action: {
                
            })
            Button("Previous Track", action: {})

            Divider()

            Menu("Repeat") {
                Button("Off", action: {})
                Button("All", action: {})
                Button("One", action: {})
            }

            Menu("Shuffle") {
                Button("On", action: {})
                Button("Off", action: {})
                Divider()
                Button("Songs", action: {})
                Button("Albums", action: {})
                Button("Groupings", action: {})
            }

            Divider()

            Button("Settings…", action: {
                openSettings()
            })

            Divider()

            Button("About \(applicationName)", action: {})

            Divider()

            Button("Quit \(applicationName)", action: {
                NSApplication.shared.terminate(self)
            })
        } label: {
            Image("settingsTemplate")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24.0)
                .padding(.trailing, 15.0)
        }
        .buttonStyle(.plain)
    }

    private var applicationName: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleDisplayName"
        ) as! String
    }

    private var playPauseTitle: String {
        if musicPlayer.playbackState.playbackStatus == .playing {
            return "Pause"
        }

        return "Play"
    }

    private func openAppSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    ApplicationMenuButton(using: CappellaMusicPlayer())
        .scenePadding()
}
