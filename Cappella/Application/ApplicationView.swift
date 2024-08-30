//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct ApplicationView: View {
    @State private var authorizationStatus = MusicAuthorization.currentStatus
    @State private var playbackQueue: PlaybackQueue? = nil

    var body: some View {
        Group {
            switch authorizationStatus {
            case .authorized:
                makeContentView()
            case .notDetermined:
                makeAuthorizationView()
            case .denied, .restricted:
                makeDeniedView()
            @unknown default:
                makeDeniedView() // TODO
            }
        }
    }

    @ViewBuilder
    private func makeContentView() -> some View {
        if playbackQueue != nil {
            MusicSearchView()
                .environment(playbackQueue)
        } else {
            Color.clear
                .task {
                    do {
                        playbackQueue = try await PlaybackQueue()
                    } catch {
                        print("Error initializing PlaybackQueue: \(error)")
                    }
                }
        }
    }

    @ViewBuilder
    private func makeAuthorizationView() -> some View {
        AuthorizationView()
    }

    @ViewBuilder
    private func makeDeniedView() -> some View {
        Text("Music Library Access Denied")
    }
}

#Preview {
    ApplicationView()
        .frame(width: 400.0, height: 600.0)
}
