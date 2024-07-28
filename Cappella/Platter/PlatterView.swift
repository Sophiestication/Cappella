//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import AppKit

struct PlatterView<Content>: View where Content: View {
    private let content: () -> Content

    init(
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.content = content
    }

    var body: some View {
        makeBackgroundView()
            .containerRelativeFrame([ .horizontal, .vertical ])
            .overlay(content())
    }

    @ViewBuilder
    private func makeBackgroundView() -> some View {
        VisualEffectView(
            material: .underWindowBackground,
            blendingMode: .behindWindow,
            state: .active,
            cornerRadius: 16.0
        )
    }
}

#Preview {
    PlatterView {
        Text("Hello, world!")
            .padding()
    }
}
