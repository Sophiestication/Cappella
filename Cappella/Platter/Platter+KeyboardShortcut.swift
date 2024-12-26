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
