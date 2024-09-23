//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import Combine

fileprivate struct KeyboardShortcutPlatterPresentingModifier: ViewModifier {
    @Environment(\.platterProxy) var platterProxy

    @State private var cancellable: AnyCancellable?

    private let keyboardShortcutID: GlobalKeyboardShortcut.ID
    @State private var keyUpShouldDismiss: Bool = false

    init(_ keyboardShortcutID: GlobalKeyboardShortcut.ID) {
        self.keyboardShortcutID = keyboardShortcutID
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                cancellable = GlobalKeyboardShortcutHandler
                    .shared
                    .didReceiveEvent
                    .sink { event in
                        guard event.id == keyboardShortcutID else { return }
                        guard let platterProxy else { return }

                        if event.phase == .down {
                            keyUpShouldDismiss = false

                            platterProxy.togglePresentation()
                        } else if event.phase == .up {
                            if keyUpShouldDismiss {
                                platterProxy.dismiss()
                            }
                        } else if event.phase == .repeat {
                            keyUpShouldDismiss = true
                        }
                    }
            }
            .onDisappear {
                if let cancellable {
                    cancellable.cancel()
                }
            }
    }
}

extension View {
    func platterKeyboardShortcut(
        using keyboardShortcutID: GlobalKeyboardShortcut.ID
    ) -> some View {
        self.modifier(KeyboardShortcutPlatterPresentingModifier(keyboardShortcutID))
    }
}
