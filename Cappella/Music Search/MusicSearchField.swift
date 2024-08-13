//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MusicSearchField: View {
    @State private var musicSearch: MusicSearch

    @Environment(\.platterGeometry) var platterGeometry

    @FocusState private var searchFieldFocused: Bool
    @State private var currentEventModifier: EventModifiers = []

    init(with musicSearch: MusicSearch) {
        self.musicSearch = musicSearch
    }

    var body: some View {
        HStack(alignment: .center) {
            makeSearchScopeImage(for: musicSearch.scope)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14.0)
                .padding(.leading, 15.0)
            TextField("", text: $musicSearch.term, prompt: Text("Search"))
                .disableAutocorrection(true)

                .textFieldStyle(.plain)

                .focused($searchFieldFocused)
        }
        .font(.system(size: 15.0, weight: .regular, design: .rounded))
        .padding(.vertical, 4.0)
        .background (
            RoundedRectangle(cornerRadius: 14.0, style: .continuous)
                .fill(.quaternary)
        )
        .padding(.vertical)
        .padding(.trailing, 15.0)

        .padding(.leading, platterGeometry.containerSize.width * 0.35)

        .onModifierKeysChanged { old, new in
            self.currentEventModifier = new
        }
        .onKeyPress(.upArrow) {
            musicSearch.selectPrevious(.entry) ? .handled : .ignored
        }
        .onKeyPress(.downArrow) {
            musicSearch.selectNext(.entry) ? .handled : .ignored
        }
        .onKeyPress(.tab) {
            toggleSearchScope()
            return .handled
        }
        .onKeyPress(.return) {
            scheduleSelectionToPlay() ? .handled : .ignored
        }
    }

    private func makeSearchScopeImage(for scope: MusicSearch.Scope) -> Image {
        switch scope {
        case .all:
            return Image(systemName: "magnifyingglass")
        case .album:
            return Image(systemName: "music.note.list")
        case .artist:
            return Image(systemName: "music.microphone")
        }
    }

    private func toggleSearchScope() {
        let scope = musicSearch.scope

        if currentEventModifier.contains(.option) {
            musicSearch.scope = scope.reverse()
        } else {
            musicSearch.scope = scope.advance()
        }
    }

    private func scheduleSelectionToPlay() -> Bool {
        guard let selection = musicSearch.selection else {
            return false
        }

        musicSearch.scheduledToPlay = selection
        return true
    }
}

fileprivate extension MusicSearch.Scope {
    func advance() -> Self {
        let allCases = Self.allCases

        let currentIndex = allCases.firstIndex(of: self)!
        let nextIndex = (currentIndex + 1) % allCases.count

        return allCases[nextIndex]
    }

    func reverse() -> Self {
        let allCases = Self.allCases

        let currentIndex = allCases.firstIndex(of: self)!
        let previousIndex = (currentIndex - 1 + allCases.count) % allCases.count

        return allCases[previousIndex]
    }
}
