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
                DispatchQueue.main.async {
                    openSettings()
                    NSApplication.shared.activate()
                }
            })

            Divider()

            Button("About \(applicationName)", action: {
                DispatchQueue.main.async {
                    NSApplication.shared.orderFrontStandardAboutPanel()
                    NSApplication.shared.activate()
                }
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
