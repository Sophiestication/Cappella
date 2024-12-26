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

struct PlayerPositionView: View {
    @StateObject private var playerPosition = PlayerPosition()

    @State private var currentPosition: Double = .zero

    @State private var draggingPosition: Double = .zero
    @State private var isDragging: Bool = false

    @Environment(\.isEnabled) private var isEnabled

    @AppStorage("remainingDurationShown") private var remainingDurationShown: Bool = true

    var body: some View {
        VStack {
            GeometryReader { geometry in
                background
                    .overlay(
                        progress(for: geometry),
                        alignment: .leading
                    )
                    .mask {
                        Capsule()
                    }
                    .gesture(makeScrubGesture(for: geometry))
            }
            .frame(height: 8.0)

            HStack {
                Text("\(format(playerPosition.playbackTime))")
                Spacer()
                trailingLabel
            }
            .font(.system(size: 12.0, weight: .medium, design: .rounded))
            .monospacedDigit()
            .opacity(isEnabled ? 1.0 : 0.50)
        }

        .onChange(of: playerPosition.playbackTime, initial: true) { oldValue, newValue in
            guard newValue.isNaN == false else {
                currentPosition = .zero
                return
            }

            let duration = playerPosition.playbackDuration
            currentPosition = newValue / duration
        }
    }

    @ViewBuilder
    private var background: some View {
        Rectangle()
            .fill(.regularMaterial)
            .fill(.primary.opacity(1.0 / 7.0))
    }

    @ViewBuilder
    private func progress(for geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(.tint)
            .frame(width: width(for: geometry))
    }

    private func width(for geometry: GeometryProxy) -> CGFloat {
        visiblePosition.isNaN ? 0.0 : geometry.size.width * visiblePosition
    }

    private var contentShape: some Shape {
        Capsule()
    }

    private func makeScrubGesture(for geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged {
                guard isEnabled else { return }

                isDragging = true
                updatePosition(from:$0.location, geometry)
            }
            .onEnded {
                guard isEnabled else { return }

                isDragging = false
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

        if shouldCommit {
            let newPlaybackTime = playerPosition.playbackDuration * newPosition
            playerPosition.seek(to: newPlaybackTime)
        }
    }

    private var visiblePosition: Double {
        isDragging ?
            draggingPosition :
            currentPosition
    }

    private var visiblePlaybackTime: TimeInterval {
        isDragging ?
            draggingPosition * playerPosition.playbackDuration :
            playerPosition.playbackTime
    }

    @ViewBuilder
    private var trailingLabel: some View {
        Text(trailingLabelString)
            .onTapGesture {
                remainingDurationShown.toggle()
            }
    }

    private var trailingLabelString: String {
        if isEnabled == false {
            "--:--"
        } else if remainingDurationShown {
            "-\(format(playerPosition.playbackDuration - playerPosition.playbackTime))"
        } else {
            format(playerPosition.playbackDuration)
        }
    }

    private func format(_ playbackTime: TimeInterval) -> String {
        guard !playbackTime.isNaN else { return "--:--" }

        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = playbackTime >= 3600 ?
            [.hour, .minute, .second] :
            [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: playbackTime) ?? "0:00"
    }
}

#Preview(traits: .fixedLayout(width: 400.0, height: 200.0)) {
    @Previewable @State var currentPosition: Double = 0.33

    PlayerPositionView()
        .scenePadding()
}
