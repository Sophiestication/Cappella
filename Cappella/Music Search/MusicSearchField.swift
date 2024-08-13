//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MusicSearchField: View {
    @State private var musicSearch: MusicSearch

    @Environment(\.platterGeometry) var platterGeometry

    @FocusState private var searchFieldFocused: Bool

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

        .onKeyPress(.upArrow, phases: [.down, .repeat]) { keyPress in
            musicSearch.selectPrevious(makeSelectionGroup(for: keyPress)) ? .handled : .ignored
        }
        .onKeyPress(.downArrow, phases: [.down, .repeat]) { keyPress in
            musicSearch.selectNext(makeSelectionGroup(for: keyPress)) ? .handled : .ignored
        }
        .onKeyPress(.tab, phases: [.down, .repeat]) { keyPress in
            toggleSearchScope(for: keyPress)
            return .handled
        }
        .onKeyPress(.return) {
            scheduleSelectionToPlay() ? .handled : .ignored
        }
        .onKeyPress(.escape) {
            resetSearchTermIfNeeded() ? .handled : .ignored
        }
    }

    private func makeSelectionGroup(for keyPress: KeyPress) -> MusicSearch.Selection.Group {
        if keyPress.modifiers.contains(.option) {
            return .collection
        }

        return .entry
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

    private func toggleSearchScope(for keyPress: KeyPress) {
        let scope = musicSearch.scope

        if keyPress.modifiers.contains(.option) {
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

    private func resetSearchTermIfNeeded() -> Bool {
        guard !musicSearch.term.isEmpty else {
            return false
        }
        
        musicSearch.term = ""
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
