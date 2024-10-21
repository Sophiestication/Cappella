//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct MusicSearchField: View {
    @State private var musicSearch: MusicSearch

    @Environment(\.platterProxy) var platterProxy
    @Environment(\.platterGeometry) var platterGeometry

    @Environment(\.pixelLength) var pixelLength
    private let cornerRadius: CGFloat = 10.0

    @FocusState private var searchFieldFocused: Bool

    init(with musicSearch: MusicSearch) {
        self.musicSearch = musicSearch
    }

    var body: some View {
        HStack(alignment: .center) {
            makeSearchScopeImage(for: musicSearch.scope)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14.0, height: 14.0)
                .padding(.leading, 10.0)
                .foregroundStyle(.secondary)
            MusicSearchTextField(
                text: $musicSearch.term,
                placeholder: makePrompt(for: musicSearch.scope)
            )
            .disableAutocorrection(true)
            .textFieldStyle(.plain)
            .focused($searchFieldFocused)
            .onAppear {
                searchFieldFocused = true
            }
        }
        .padding(.vertical, 8.0)
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
                .fill(.ultraThinMaterial)
            )
        )
        .padding(.trailing, 10.0)

        .padding(.leading, leadingPadding)

        .onKeyPress(.upArrow, phases: [.down, .repeat]) { keyPress in
            if musicSearch.selectPrevious(makeSelectionGroup(for: keyPress)) {
                return .handled
            }

            return .handled // prevent moving the textfield cursor
        }
        .onKeyPress(.downArrow, phases: [.down, .repeat]) { keyPress in
            if musicSearch.selectNext(makeSelectionGroup(for: keyPress)) {
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
            guard let platterProxy else { return .ignored }

            if resetSearchTermIfNeeded() == false {
                platterProxy.dismiss()
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
        case .song:
            return Image(systemName: "music.note")
        }
    }

    private func makePrompt(for scope: MusicSearch.Scope) -> String {
        switch scope {
        case .all:
            "Search Library"
        case .album:
            "Search Albums"
        case .artist:
            "Search Artists"
        case .song:
            "Search by Song"
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

fileprivate class MusicSearchNSTextField: NSTextField {
    override var acceptsFirstResponder: Bool { true }
}

fileprivate struct MusicSearchTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()

        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.focusRingType = .none

        if let fontDescriptor = textField.font?.fontDescriptor.withDesign(.rounded) {
            textField.font = NSFont(descriptor: fontDescriptor, size: 14.0)
        }

        textField.target = context.coordinator

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text

            if let editor = nsView.currentEditor() {
                editor.selectedRange = NSRange(location: text.count, length: 0)
            }
        }
    
        nsView.placeholderString = placeholder
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var representable: MusicSearchTextField

        init(_ representable: MusicSearchTextField) {
            self.representable = representable
        }

        @MainActor func controlTextDidChange(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField else { return }
            representable.text = textField.stringValue
        }
    }
}

#Preview {
    MusicSearchField(with: MusicSearch())
        .scenePadding()
}
