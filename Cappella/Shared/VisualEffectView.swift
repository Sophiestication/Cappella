//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

#if os(macOS)

import AppKit

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode

    var state: NSVisualEffectView.State = .active

    var cornerRadius: CGFloat = 0.0

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()

        view.material = material
        view.blendingMode = blendingMode

        view.state = state

        view.wantsLayer = true

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode

        nsView.state = state

        if let layer = nsView.layer {
            layer.cornerRadius = cornerRadius
            layer.cornerCurve = .continuous
        }
    }
}

#endif
