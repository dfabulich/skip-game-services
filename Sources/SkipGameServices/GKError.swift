// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

/// Compact errors for SkipGameKit-style APIs. Use ``init(_:)`` at `throw` sites instead of verbose ``NSError`` literals.
public struct GKError: Error {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }
}

extension GKError: LocalizedError {
    public var errorDescription: String? { message }
}

#endif
#endif
