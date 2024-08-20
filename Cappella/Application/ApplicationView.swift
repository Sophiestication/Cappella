//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import SwiftUI
import MusicKit

struct ApplicationView: View {
    @State private var authorizationStatus = MusicAuthorization.currentStatus

    var body: some View {
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

    @ViewBuilder
    private func makeContentView() -> some View {
        MusicSearchView()
    }

    @ViewBuilder
    private func makeAuthorizationView() -> some View {
        AuthorizationView()
    }

    @ViewBuilder
    private func makeDeniedView() -> some View {
        Text("Music Library Access Denied")
    }
}

#Preview {
    ApplicationView()
        .frame(width: 400.0, height: 600.0)
}
