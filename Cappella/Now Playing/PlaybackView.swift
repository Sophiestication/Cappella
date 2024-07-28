//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct PlaybackView: View {
    private let musicPlayer = ApplicationMusicPlayer.shared

    var body: some View {
        HStack {
            Button(action: {

            }, label: {
                Image(systemName: "backward.fill")
            })

            Button(action: {

            }, label: {
                Image(systemName: "play.fill")
            })

            Button(action: {

            }, label: {
                Image(systemName: "forward.fill")
            })
        }
    }
}

#Preview {
    PlaybackView()
}
