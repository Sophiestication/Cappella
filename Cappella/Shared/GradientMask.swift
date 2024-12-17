//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct GradientMask: View {
    let curve: UnitCurve

    let start: UnitPoint
    let end: UnitPoint

    init(
        _ curve: UnitCurve = .easeInOut,
        start: UnitPoint = .bottom,
        end: UnitPoint = .top
    ) {
        self.curve = curve

        self.start = start
        self.end = end
    }

    var body: some View {
        LinearGradient(
            gradient: gradient,
            startPoint: start,
            endPoint: end
        )
    }

    private var gradient: Gradient {
        let colors = stride(from: 0.0, to: 1.0, by: 1.0 / 25.0).map { value -> Color in
            let opacity = curve.value(at: value)
            return Color.red.opacity(opacity)
        }

        return Gradient(colors: colors)
    }
}

#Preview {
    VStack(spacing: 44.0) {
        ArtworkView(length: 240)
            .overlay(GradientMask(start: .init(x: 0.0, y: 0.0), end: .init(x: 0.0, y: 0.75)))
    }
    .padding(60.0)

    .environment(\.artworkProvider, PreviewArtworkProvider())
}
