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

import IOKit
import Foundation

struct SystemKeyRepeatInterval {
    static var interval: TimeInterval {
        if let interval = Self.IORegistryValue(for: kIOHIDKeyRepeatKey) {
            return TimeInterval(interval) / 1_000_000_000.0
        }

        return 0.05 // Fallback value
    }

    static var initialInterval: TimeInterval {
        if let delay = Self.IORegistryValue(for: kIOHIDInitialKeyRepeatKey) {
            return TimeInterval(delay) / 1_000_000_000.0
        }

        return 0.5 // Fallback value
    }

    private static func IORegistryValue(for key: String) -> Int? {
        var iterator: io_iterator_t = 0
        defer { IOObjectRelease(iterator) }

        let result = IOServiceGetMatchingServices(
            kIOMainPortDefault,
            IOServiceMatching("IOHIDSystem"),
            &iterator
        )

        if result != KERN_SUCCESS {
            return nil
        }

        let entry: io_object_t = IOIteratorNext(iterator)
        defer { IOObjectRelease(entry) }

        if entry == 0 {
            return nil
        }

        var properties: Unmanaged<CFMutableDictionary>?

        if IORegistryEntryCreateCFProperties(
            entry,
            &properties,
            kCFAllocatorDefault,
            0
        ) != KERN_SUCCESS {
            return nil
        }

        guard let dictionary = properties?.takeRetainedValue() as? [String: Any],
              let HIDParameters = dictionary[kIOHIDParametersKey] as? [String: Any],
              let value = HIDParameters[key] as? Int else {
            return nil
        }

        return value
    }
}
