// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if !SKIP
import Foundation
import GameKit

extension GKAchievement {
    /// No-op on Apple GameKit; map is ignored. Matches Skip’s ``GKAchievement/registerAchievementIdentifiers(_:)`` signature.
    @MainActor
    public static func registerAchievementIdentifiers(_ map: [String: String]) throws {}

    /// Always `nil` on GameKit; Play Games opaque ids exist only on Android.
    public var opaqueIdentifier: String? { nil }
}

extension GKAchievementDescription {
    /// Always `nil` on GameKit; Play Games opaque ids exist only on Android.
    public var opaqueIdentifier: String? { nil }
}

extension GKLeaderboard {
    /// No-op on Apple GameKit; map is ignored. Matches Skip’s ``GKLeaderboard/registerLeaderboardIdentifiers(_:)`` signature.
    @MainActor
    public static func registerLeaderboardIdentifiers(_ map: [String: String]) throws {}

    /// Always `nil` on GameKit; Play Games opaque ids exist only on Android.
    public var opaqueIdentifier: String? { nil }
}

#endif
#endif
