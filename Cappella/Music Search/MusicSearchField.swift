//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MusicSearchField: View {
    @State private var musicSearch: MusicSearch

    @Environment(\.platterGeometry) var platterGeometry
    @Environment(\.dismissPlatter) var dismissPlatter

    @Environment(\.pixelLength) var pixelLength
    private let cornerRadius: CGFloat = 6.0

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
                .padding(.leading, 10.0)
            TextField("", text: $musicSearch.term, prompt: Text("Search"))
                .disableAutocorrection(true)

                .textFieldStyle(.plain)

                .focused($searchFieldFocused)
        }
        .font(.system(size: 15.0, weight: .regular, design: .rounded))
        .padding(.vertical, 4.0)
        .background (
            RoundedRectangle(
                cornerRadius: cornerRadius,
                style: .continuous
            )
            .stroke(lineWidth: pixelLength)
            .fill(.quaternary)
            .background(
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .fill(.thinMaterial)
            )
        )
        .padding(.vertical)
        .padding(.trailing, 15.0)

        .padding(.leading, leadingPadding)

        .onKeyPress(.upArrow, phases: [.down, .repeat]) { keyPress in
            if musicSearch.selectPrevious(makeSelectionGroup(for: keyPress)) {
                NSCursor.setHiddenUntilMouseMoves(true)
                return .handled
            }

            return .ignored
        }
        .onKeyPress(.downArrow, phases: [.down, .repeat]) { keyPress in
            if musicSearch.selectNext(makeSelectionGroup(for: keyPress)) {
                NSCursor.setHiddenUntilMouseMoves(true)
                return .handled
            }

            return .ignored
        }
        .onKeyPress(.tab, phases: [.down, .repeat]) { keyPress in
            toggleSearchScope(for: keyPress)
            return .handled
        }
        .onKeyPress(.return) {
            scheduleSelectionToPlay() ? .handled : .ignored
        }
        .onKeyPress(.escape) {
            if resetSearchTermIfNeeded() == false {
                dismissPlatter()
            }

            return .handled
        }
    }

    private var leadingPadding: CGFloat {
        guard let platterGeometry else {
            return 0.0
        }

        return platterGeometry.contentFrame.width * 0.35 + 8.0
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
