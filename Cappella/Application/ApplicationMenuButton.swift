//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

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
            if musicLibraryAccessEnabled {
                Group {
                    Button(playPauseTitle, action: {
                        musicPlayer.playPause()
                    })
                    Button("Next Track", action: {
                        musicPlayer.fastForward()
                    })
                    Button("Previous Track", action: {
                        musicPlayer.rewind()
                    })
                }
                .disabled(playbackEnabled == false)
                
                Divider()
                
                Group {
                    Picker("Repeat", selection: $playbackState.repeatMode) {
                        Text("Off").tag(MusicPlayer.RepeatMode.none)
                        Text("All").tag(MusicPlayer.RepeatMode.all)
                        Text("One").tag(MusicPlayer.RepeatMode.one)
                    }
                    
                    Picker("Shuffle", selection: $playbackState.shuffleMode) {
                        Text("Off").tag(MusicPlayer.ShuffleMode.off)
                        Text("Songs").tag(MusicPlayer.ShuffleMode.songs)
                    }
                }
                
                Divider()
            }

            Button("Settings…", action: {
                NSApplication.shared.activate(ignoringOtherApps: true)
                openSettings()
            })

            Divider()

            Button("About \(applicationName)", action: {
                NSApplication.shared.activate(ignoringOtherApps: true)
                NSApplication.shared.orderFrontStandardAboutPanel()
            })

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

    private var musicLibraryAccessEnabled: Bool {
        MusicAuthorization.currentStatus == .authorized
    }

    private var playPauseTitle: String {
        if musicPlayer.playbackState.playbackStatus == .playing {
            return "Pause"
        }

        return "Play"
    }

    private var playbackEnabled: Bool {
        musicPlayer.queue.currentEntry != nil
    }
}

#Preview {
    ApplicationMenuButton(using: CappellaMusicPlayer())
        .scenePadding()
}
