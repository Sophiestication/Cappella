//
//  Created by Sophiestication Software on 9/7/24.
//


import SwiftUI
import AppKit

extension View {
    func onKeyEquivalent(
        _ action: @escaping (Int, NSEvent.ModifierFlags) -> KeyPress.Result
    ) -> some View {
        self.background(KeyEquivalentListener(action: action))
    }
}

fileprivate class KeyEquivalentListenerView: NSView {
    let action: (Int, NSEvent.ModifierFlags) -> KeyPress.Result

    init(_ action: @escaping (Int, NSEvent.ModifierFlags) -> KeyPress.Result) {
        self.action = action
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let keyCode = Int(event.keyCode)
        let modifierFlags = event.modifierFlags
        
        if action(keyCode, modifierFlags) == .handled {
            return true
        }

        return false
    }
}

fileprivate struct KeyEquivalentListener: NSViewRepresentable {
    let action: (Int, NSEvent.ModifierFlags) -> KeyPress.Result

    func makeNSView(context: Context) -> NSView {
        let view = KeyEquivalentListenerView(action)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
    }
}
