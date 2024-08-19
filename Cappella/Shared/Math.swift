//
// Copyright © 2024 Sophiestication Software. All rights reserved.
//

import Foundation

/// Linearly interpolates between `start` and `end` based on the parameter `t`.
/// - Parameters:
///   - start: The starting value.
///   - end: The ending value.
///   - t: The interpolation factor, where `0 <= t <= 1`.
/// - Returns: The interpolated value.
func lerp(start: CGFloat, end: CGFloat, t: CGFloat) -> CGFloat {
    return (1 - t) * start + t * end
}
