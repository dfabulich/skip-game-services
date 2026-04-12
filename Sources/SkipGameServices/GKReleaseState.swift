// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

/// Describes the release state of an App Store Connect resource (stub on Play Games).
public struct GKReleaseState: OptionSet, @unchecked Sendable {
    public var rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let released = GKReleaseState(rawValue: UInt(1))
    public static let prereleased = GKReleaseState(rawValue: UInt(2))
}

#endif
#endif
