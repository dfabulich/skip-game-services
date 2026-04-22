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

extension GKSavedGame {
    public typealias ConflictResolver = @Sendable ([GKSavedGame]) async throws -> Void

    /// Resolves a conflict set by loading data from the most recently modified branch.
    /// Pass this to ``fetchSavedGames(resolvingConflictsWith:)``.
    public static let mostRecentConflictResolver: GKSavedGame.ConflictResolver = { savedGames in
        guard let first = savedGames.first else { return }
        let mostRecent = savedGames.max(by: {
            $0.modificationDate ?? Date.distantPast < $1.modificationDate ?? Date.distantPast
        }) ?? first
        let data = try await mostRecent.loadData()
        _ = try await GKLocalPlayer.local.resolveConflictingSavedGames(savedGames, with: data)
    }

    public static func detectAndResolveConflicts(
        in fetched: [GKSavedGame],
        with resolver: @escaping GKSavedGame.ConflictResolver = GKSavedGame.mostRecentConflictResolver
    ) async throws -> Bool {
        var groupedByName: [String: [GKSavedGame]] = [:]
        for game in fetched {
            guard let name = game.name else { continue }
            if groupedByName[name] == nil {
                groupedByName[name] = []
            }
            groupedByName[name]?.append(game)
        }
        var conflictsResolved = false
        for (_, conflicted) in groupedByName where conflicted.count > 1 {
            try await resolver(conflicted)
            conflictsResolved = true
        }
        return conflictsResolved
    }
}

extension GKLocalPlayer {
    public func fetchSavedGamesResolvingConflicts(
        with resolver: @escaping GKSavedGame.ConflictResolver = GKSavedGame.mostRecentConflictResolver
    ) async throws -> [GKSavedGame] {
        var fetched = try await GKLocalPlayer.local.fetchSavedGames()
        while try await GKSavedGame.detectAndResolveConflicts(in: fetched, with: resolver) {
            fetched = try await GKLocalPlayer.local.fetchSavedGames()
        }
        return fetched
    }
}

#endif
