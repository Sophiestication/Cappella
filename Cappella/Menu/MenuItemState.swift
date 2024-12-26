//
// MIT License
//
// Copyright (c) 2006-2024 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import SwiftUI

class MenuItemState: ObservableObject, Identifiable, Equatable, CustomDebugStringConvertible {
    @Published var id: AnyHashable

    @Published var isSelected: Bool
    @Published var isTriggered: Bool

    init(
        _ id: AnyHashable,
        isSelected: Bool = false,
        isTriggered: Bool = false
    ) {
        self.id = id
        self.isSelected = isSelected
        self.isTriggered = isTriggered
    }

    static func == (lhs: MenuItemState, rhs: MenuItemState) -> Bool {
        return lhs.id == rhs.id &&
        lhs.isSelected == rhs.isSelected &&
        lhs.isTriggered == rhs.isTriggered
    }

    var debugDescription: String {
        return """
        MenuItemState(
            id: \(id),
            isSelected: \(isSelected),
            isTriggered: \(isTriggered)
        )
        """
    }
}

extension EnvironmentValues {
    @Entry var menuItemState: MenuItemState? = nil
}
