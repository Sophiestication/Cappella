//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct ApplicationView: View {
    @State private var authorizationStatus = MusicAuthorization.currentStatus
    @State private var playbackQueue: PlaybackQueue? = nil

    @Environment(\.openURL) private var openURL

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
        Button(action: {
            Task {
                self.authorizationStatus = await MusicAuthorization.request()
            }
        }, label: {
            Text("Authorize  Music")
        })
        .padding(.vertical, 80.0)
    }

    @ViewBuilder
    private func makeDeniedView() -> some View {
        VStack {
            Text("Music Library Access Denied")
            
            Button(action: {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Media") {
                    openURL(url)
                }
            }, label: {
                Text("Open Settings…")
            })
            .padding(.vertical, 10.0)
        }
    }
}

#Preview {
    ApplicationView()
        .frame(width: 400.0, height: 600.0)
}
