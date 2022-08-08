//
// Copyright © 2022 Sophiestication Software. All rights reserved.
//

import SwiftUI

@main
struct Application: App {
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var searchText: String = ""

    @StateObject private var playback: PlaybackPublisher = .init()

    var body: some Scene {
        Window("Application Window", id: "application") {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SidebarView()
                    .navigationSplitViewColumnWidth(min: 320.0, ideal: 400.0, max: 480.0)
            } detail: {
                MusicPickerView()
                    .navigationSplitViewColumnWidth(min: 320.0, ideal: 768.0)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    HStack(spacing: 0.0) {
                        makeRepeatModeMenu()
                        makeShuffleMenu()
                    }
                }
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
            ToolbarCommands()
        }
    }
}

extension Application {
    typealias ShuffleMode = PlaybackPublisher.ShuffleMode

    fileprivate func makeShuffleMenu() -> some View {
        Menu {
            Picker(selection: $playback.shuffle) {
                Text("On").tag(true)
                Text("Off").tag(false)
            } label: {
                Text("Shuffle")
            }
            .pickerStyle(.inline)

            Picker(selection: $playback.shuffleMode) {
                Text("Songs").tag(ShuffleMode.song)
                Text("Albums").tag(ShuffleMode.album)
                Text("Groupings").tag(ShuffleMode.grouping)
            } label: {
                Group { }
            }
            .pickerStyle(.inline)
        } label: {
            Image(systemName: "shuffle")
        }
        .menuIndicator(.hidden)
    }
}

extension Application {
    typealias RepeatMode = PlaybackPublisher.RepeatMode

    fileprivate func makeRepeatModeMenu() -> some View {
        Menu {
            Picker(selection: $playback.repeatMode, label: Text("Repeat")) {
                Text("Off").tag(RepeatMode.off)
                Text("All").tag(RepeatMode.all)
                Text("One").tag(RepeatMode.one)
            }
            .pickerStyle(.inline)
        } label: {
            label(for: playback.repeatMode)
        }
        .menuIndicator(.hidden)
    }
    
    @ViewBuilder
    fileprivate func label(for repeatMode:  RepeatMode) -> some View {
        Group {
            switch repeatMode {
            case .off: Image(systemName: "repeat").foregroundColor(.accentColor)
            case .all: Image(systemName: "repeat")
            case .one: Image(systemName: "repeat.1")
            }
        }
    }
}
