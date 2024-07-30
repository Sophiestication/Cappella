//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct NowPlayingView: View {
    @State private var authorizationStatus = MusicAuthorization.currentStatus

    var body: some View {
        switch authorizationStatus {
        case .authorized:
            makeContentView()
        default:
            Color.red
        }
    }

    @ViewBuilder
    private func makeContentView() -> some View {
        VStack {
            PlaybackView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NowPlayingView()
}
