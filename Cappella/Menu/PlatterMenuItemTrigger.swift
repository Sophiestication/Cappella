//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
//

import SwiftUI

struct PlatterMenuItemTrigger: Identifiable, Equatable {
    let id: AnyHashable
    private let trigger: () -> Void

    init(id: Self.ID, _ trigger: @escaping () -> Void) {
        self.id = id
        self.trigger = trigger
    }

    func callAsFunction() {
        trigger()
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct PlatterMenuItemTriggerKey: PreferenceKey {
    typealias Value = PlatterMenuItemTrigger?

    static var defaultValue: Value { nil }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }
}
