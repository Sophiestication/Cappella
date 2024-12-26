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
        .platterKeyboardShortcut(using: .musicSearch)
    }

    @ViewBuilder
    private func makeContentView() -> some View {
//        if playbackQueue != nil {
            MusicSearchView()
//                .environment(playbackQueue)
//        } else {
//            Color.clear
//                .task {
//                    do {
//                        playbackQueue = try await PlaybackQueue()
//                    } catch {
//                        print("Error initializing PlaybackQueue: \(error)")
//                    }
//                }
//        }
    }

    @ViewBuilder
    private func makeAuthorizationView() -> some View {
        VStack {
            VStack {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128.0)
                Text("To continue, please grant \(applicationName) access to  Music and your media library on this computer.")
            }
            .padding(.bottom, 44.0)

            Button(action: {
                Task {
                    self.authorizationStatus = await MusicAuthorization.request()
                }
            }, label: {
                Text("Authorize…")
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
                ApplicationMenuButton(using: CappellaMusicPlayer())
            }
        }
    }

    @ViewBuilder
    private func makeDeniedView() -> some View {
        VStack {
            VStack {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128.0)
                Text("To continue, please grant \(applicationName) access to  Music and your media library in Settings.")
            }
            .padding(.bottom, 44.0)

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
                ApplicationMenuButton(using: CappellaMusicPlayer())
            }
        }
    }

    private var applicationName: String {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleDisplayName"
        ) as! String
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ApplicationView()
        .buttonStyle(.platter)
        .frame(width: 440.0, height: 720.0)
}
