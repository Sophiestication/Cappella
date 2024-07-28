//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct NowPlayingView: View {
    private let musicPlayer = ApplicationMusicPlayer.shared

    var body: some View {
        VStack {
            if let title = musicPlayer.queue.currentEntry?.title {
                Text(title)
            }

            PlaybackView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(.red.opacity(0.75))
    }
}

#Preview {
    NowPlayingView()
}
