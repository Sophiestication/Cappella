//
// Copyright © 2006-2024 Sophiestication Software. All rights reserved.
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
