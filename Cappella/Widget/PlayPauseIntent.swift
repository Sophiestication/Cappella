//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import AppIntents
import AppKit
import MusicKit

struct PlayPauseIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource { "Play or Pause" }
    static var description: IntentDescription? { "Toggles playback of the current song." }

    func perform() async throws -> some IntentResult {
        await togglePlayback()
        return .result()
    }

    private func togglePlayback() async {
        print("PlayPauseIntent performed")

        if let sound = NSSound(named: NSSound.Name("Ping")) {
            sound.play()
        }

        ApplicationMusicPlayer.shared.pause()
    }
}
