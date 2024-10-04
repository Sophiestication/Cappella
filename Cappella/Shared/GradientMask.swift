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
        let colors = stride(from: 0.0, to: 1.0, by: 1.0 / 50.0).map { value -> Color in
            let opacity = curve.value(at: value)
            return Color.black.opacity(opacity)
        }

        return Gradient(colors: colors)
    }
}

struct ContentView: View {
    var body: some View {
        Color.red
            .mask(GradientMaskView())
    }
}

#Preview {
    ContentView()
}
