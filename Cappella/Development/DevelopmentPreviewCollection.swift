//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import Foundation

@MainActor
struct DevelopmentPreviewCollection: Identifiable {
    let id = UUID()

    let title: String
    let subtitle: String

    let artwork: ArtworkProviding?

    let items: [DevelopmentPreviewItem]

    static let previews: [DevelopmentPreviewCollection] = [
        DevelopmentPreviewCollection(
            title: "Radical Optimism",
            subtitle: "Dua Lipa",
            artwork: PreviewArtworkProvider(),
            items: [
                DevelopmentPreviewItem(title: "End Of An Era"),
                DevelopmentPreviewItem(title: "Houdini"),
                DevelopmentPreviewItem(title: "Training Season"),
                DevelopmentPreviewItem(title: "These Walls"),
                DevelopmentPreviewItem(title: "Whatcha Doing"),
                DevelopmentPreviewItem(title: "French Exit"),
                DevelopmentPreviewItem(title: "Illusion"),
                DevelopmentPreviewItem(title: "Falling Forever"),
                DevelopmentPreviewItem(title: "Anything For Love"),
                DevelopmentPreviewItem(title: "Maria"),
                DevelopmentPreviewItem(title: "Happy For You")
            ]
        ),

        DevelopmentPreviewCollection(
            title: "Born to Die",
            subtitle: "Lana Del Rey",
            artwork: PreviewArtworkProvider("PreviewArtwork2"),
            items: [
                DevelopmentPreviewItem(title: "Born to Die"),
                DevelopmentPreviewItem(title: "Off to the Races"),
                DevelopmentPreviewItem(title: "Blue Jeans (Remastered)"),
                DevelopmentPreviewItem(title: "Video Games (Remastered)"),
                DevelopmentPreviewItem(title: "Diet Mountain Dew"),
                DevelopmentPreviewItem(title: "National Anthem"),
                DevelopmentPreviewItem(title: "Dark Paradise"),
                DevelopmentPreviewItem(title: "Radio"),
                DevelopmentPreviewItem(title: "Carmen"),
                DevelopmentPreviewItem(title: "Million Dollar Man"),
                DevelopmentPreviewItem(title: "Summertime Sadness"),
                DevelopmentPreviewItem(title: "This Is What Makes Us Girls")
            ]
        )
    ]
}

@MainActor
struct DevelopmentPreviewItem: Identifiable {
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
