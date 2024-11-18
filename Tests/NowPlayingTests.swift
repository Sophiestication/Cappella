//
//  Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Testing
import Foundation
import Combine
import MusicKit
@testable import Cappella

struct NowPlayingTests {
    private var nowPlayingPublisher: ApplicationMusicPlayer.NowPlaying!
    private var cancellables: Set<AnyCancellable> = []

    @Test mutating func testNowPlayingNotification() async throws {
        guard MusicAuthorization.currentStatus == .authorized else {
            return // ignore on CI
        }

        let title = "Radical Optimism"

        let albums = try await MusicLibrary.fetchAlbums(
            matchting: title
        )

        let song = albums.first(where: {
            $0.title.hasPrefix(title) == false
        })
        
        #expect(song == nil, "Album title needs to match the filter: \"\(title)\"")

        try await confirmation() { confirmation in
            nowPlayingPublisher = ApplicationMusicPlayer.shared.nowPlayingPublisher()

            nowPlayingPublisher
                .sink {
                    print($0)
                    confirmation()
                }
                .store(in: &cancellables)

            let player = ApplicationMusicPlayer.shared

            let entries = albums.map { ApplicationMusicPlayer.Queue.Entry($0) }
            player.queue = ApplicationMusicPlayer.Queue(entries)

            try await player.prepareToPlay()

            try await player.play()

            try await player.skipToNextEntry()

//            #expect(false)
        }
    }
}
