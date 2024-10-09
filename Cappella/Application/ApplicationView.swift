//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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
            VStack {
                Image("PlaceholderAppIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128.0)
                Text("To continue, please enable CoverSutra’s access to  Music in Settings.")
            }
            .padding(.bottom, 60.0)

            Button(action: {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Media") {
                    openURL(url)
                }
            }, label: {
                Text("Open Settings…")
            })
        }

        .font(.system(size: 17.0, weight: .medium, design: .rounded))
        .lineSpacing(6.0)
        .multilineTextAlignment(.center)

        .padding(.horizontal, 64.0)

        .containerRelativeFrame(.vertical, alignment: .center)

        .platterContent(id: "settings", placement: .header) {
            HStack {
                Spacer()
                ApplicationMenuButton()
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ApplicationView()
        .buttonStyle(.platter)
        .frame(width: 440.0, height: 720.0)
}
