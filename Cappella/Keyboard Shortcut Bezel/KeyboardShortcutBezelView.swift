//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct KeyboardShortcutBezelView : View {
    var body: some View {
        VisualEffectView(
            material: .hudWindow,
            blendingMode: .behindWindow,
            state: .active
        )
        .clipShape(bezelShape)
        .frame(width: bezelDimension, height: bezelDimension)
    }

    private var bezelDimension: CGFloat { 200.0 }
    private var bezelShape: some Shape {
        RoundedRectangle(
            cornerRadius: 18.0,
            style: .continuous
        )
    }
}

#Preview {
    KeyboardShortcutBezelView()
}
