//
//  Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Testing
import MusicKit
@testable import Cappella

struct MusicLibraryTests {
    @Test func testFetchAlbumByTitle() async throws {
        let title = "Radical Optimism"

        let albums = try await MusicLibrary.fetchAlbums(
            matchting: title
        )

        let mismatch = albums.first(where: {
            $0.title.hasPrefix(title) == false
        })
        
        #expect(mismatch == nil, "Album title needs to match the filter: \"\(title)\"")
    }
}
