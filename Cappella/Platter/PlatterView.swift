//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

struct PlatterView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }

    private func makeBackgroundView() -> NSView {
        let backgroundView = NSVisualEffectView()

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.autoresizingMask = [ .width, .height ]

        backgroundView.material = .underWindowBackground
        backgroundView.state = .active

        backgroundView.wantsLayer = true

        if let layer = backgroundView.layer {
            layer.cornerRadius = 16.0
            layer.cornerCurve = .continuous
        }

        return backgroundView
    }
}

#Preview {
    PlatterView()
}
