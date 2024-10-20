//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlayerPositionView: View {
    typealias MusicPlayerType = CappellaMusicPlayer
    private let musicPlayer: MusicPlayerType

    @StateObject private var playerPosition = PlayerPosition()

    @ObservedObject private var playbackState: MusicPlayerType.State
    @ObservedObject private var queue: MusicPlayerType.Queue

    @State private var currentPosition: Double = .zero

    @State private var draggingPosition: Double = .zero
    @State private var isDragging: Bool = false

    @AppStorage("remainingDurationShown") private var remainingDurationShown: Bool = true

    init(using musicPlayer: MusicPlayerType) {
        self.musicPlayer = musicPlayer
        self.playbackState = musicPlayer.playbackState
        self.queue = musicPlayer.queue
    }

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
        }

        .onChange(of: playerPosition.playbackTime, initial: true) { oldValue, newValue in
            guard let _ = queue.currentEntry else {
                currentPosition = .zero
                return
            }

            let duration = musicPlayer.playbackDuration
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
                isDragging = true
                updatePosition(from:$0.location, geometry)
            }
            .onEnded {
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
            let newPlaybackTime = musicPlayer.playbackDuration * newPosition
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
            draggingPosition * musicPlayer.playbackDuration :
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
        if remainingDurationShown {
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

    PlayerPositionView(using: CappellaMusicPlayer())
        .scenePadding()
}
