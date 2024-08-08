//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation
import SwiftUI

struct OpenNowPlayingAction: Sendable {
    typealias Content = () -> AnyView

    typealias Handler = @Sendable ([Content]) -> Void
    private let handler: Handler?

    init() {
        self.handler = nil // no op
    }

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func callAsFunction<V>(@ViewBuilder _ content: @escaping () -> V) where V: View {
        if let handler {
            handler ([{
                AnyView(content())
            }])
        }
    }
}

private struct OpenNowPlayingActionEnvironmentKey: EnvironmentKey {
    static let defaultValue = OpenNowPlayingAction()
}

extension EnvironmentValues {
    var openNowPlaying: OpenNowPlayingAction {
        get { self[OpenNowPlayingActionEnvironmentKey.self] }
        set { self[OpenNowPlayingActionEnvironmentKey.self] = newValue }
    }
}
