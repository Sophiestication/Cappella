//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation

@MainActor
struct PreviewCollection: Identifiable {
    let id = UUID()

    let title: String
    let subtitle: String

    let artwork: ArtworkProviding?

    let items: [PreviewItem]

    static let previews: [PreviewCollection] = [
        PreviewCollection(
            title: "Radical Optimism",
            subtitle: "Dua Lipa",
            artwork: PreviewArtworkProvider(),
            items: [
                PreviewItem(title: "End Of An Era"),
                PreviewItem(title: "Houdini"),
                PreviewItem(title: "Training Season"),
                PreviewItem(title: "These Walls"),
                PreviewItem(title: "Whatcha Doing"),
                PreviewItem(title: "French Exit"),
                PreviewItem(title: "Illusion"),
                PreviewItem(title: "Falling Forever"),
                PreviewItem(title: "Anything For Love"),
                PreviewItem(title: "Maria"),
                PreviewItem(title: "Happy For You")
            ]
        ),

        PreviewCollection(
            title: "Born to Die",
            subtitle: "Lana Del Rey",
            artwork: PreviewArtworkProvider("PreviewArtwork2"),
            items: [
                PreviewItem(title: "Born to Die"),
                PreviewItem(title: "Off to the Races"),
                PreviewItem(title: "Blue Jeans (Remastered)"),
                PreviewItem(title: "Video Games (Remastered)"),
                PreviewItem(title: "Diet Mountain Dew"),
                PreviewItem(title: "National Anthem"),
                PreviewItem(title: "Dark Paradise"),
                PreviewItem(title: "Radio"),
                PreviewItem(title: "Carmen"),
                PreviewItem(title: "Million Dollar Man"),
                PreviewItem(title: "Summertime Sadness"),
                PreviewItem(title: "This Is What Makes Us Girls")
            ]
        )
    ]
}

@MainActor
struct PreviewItem: Identifiable {
    let id: String
    let title: String

    init(title: String) {
        self.id = title
        self.title = title
    }

    static let previewAlbum = [
        Self(title: "End Of An Era"),
        Self(title: "Houdini"),
        Self(title: "Training Season"),
        Self(title: "These Walls"),
        Self(title: "Whatcha Doing"),
        Self(title: "French Exit"),
        Self(title: "Illusion"),
        Self(title: "Falling Forever"),
        Self(title: "Anything For Love"),
        Self(title: "Maria"),
        Self(title: "Happy For You")
    ]
}
