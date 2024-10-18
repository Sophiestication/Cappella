// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlayerPositionView<
    LeadingLabel: View,
    TrailingLabel: View
>: View {
    private let updateAction: (Double, Bool) -> Void

    @Binding var currentPosition: Double
    @State private var draggingPosition: Double = .zero

    @State private var pointerLocation: CGPoint? = nil

    @ViewBuilder private var leadingLabel: LeadingLabel
    @ViewBuilder private var trailingLabel: TrailingLabel

    init(
        _ currentPosition: Binding<Double>,
        action updateAction: @escaping (Double, Bool) -> Void,
        @ViewBuilder leadingLabel: () -> LeadingLabel,
        @ViewBuilder trailingLabel: () -> TrailingLabel
    ) {
        self._currentPosition = currentPosition
        self.updateAction = updateAction
        self.leadingLabel = leadingLabel()
        self.trailingLabel = trailingLabel()
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                background
                    .overlay(
                        progress(for: geometry.size.width * draggingPosition),
                        alignment: .leading
                    )
                    .mask {
                        Capsule()
                    }

                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            pointerLocation = location
                        case .ended:
                            pointerLocation = nil
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.0) {
                        guard let pointerLocation else { return }
                        updatePosition(from: pointerLocation, geometry)
                    }
                    .onTapGesture { pointerLocation in
                        updatePosition(from: pointerLocation, geometry, shouldCommit: true)
                    }
                    .simultaneousGesture(makeScrubGesture(for: geometry))
            }
            .frame(height: 8.0)

            HStack {
                leadingLabel
                Spacer()
                trailingLabel
            }
            .font(.system(size: 12.0, weight: .medium, design: .rounded))
        }
    }

    @ViewBuilder
    private var background: some View {
        Rectangle()
            .fill(.regularMaterial)
            .fill(.primary.opacity(1.0 / 7.0))
    }

    @ViewBuilder
    private func progress(for width: CGFloat) -> some View {
        Rectangle()
            .fill(.tint)
            .frame(width: width)
    }

    private var contentShape: some Shape {
        Capsule()
    }

    private func makeScrubGesture(for geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged {
                updatePosition(from:$0.location, geometry)
            }
            .onEnded {
                updatePosition(from:$0.location, geometry, shouldCommit: true)
            }
    }

    private func updatePosition(
        from location: CGPoint,
        _ geometry: GeometryProxy,
        shouldCommit: Bool = false
    ) {
        let newPosition = location.x / geometry.size.width
        self.draggingPosition = max(0.0, min(newPosition, 1.0))

        updateAction(self.draggingPosition, shouldCommit)
    }
}

#Preview(traits: .fixedLayout(width: 400.0, height: 200.0)) {
    @Previewable @State var currentPosition: Double = 0.33

    PlayerPositionView(
        $currentPosition,
        action: { _, _ in

        },
        leadingLabel: {
            Text("1:34")
        },
        trailingLabel: {
            Text("-2:58")
        }
    )
    .scenePadding()
}
