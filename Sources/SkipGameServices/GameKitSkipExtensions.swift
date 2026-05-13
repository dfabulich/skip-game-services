// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
import Foundation

#if !SKIP
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

// MARK: - GKSavedGame

extension GKSavedGame: @retroactive @unchecked Sendable {}

/// Skips overlapping conflict resolution for the same save name (e.g. fetch and listener on iOS both resolving), which can otherwise ping-pong new conflicts.
actor SavedGameConflictResolutionActor {
    static let shared = SavedGameConflictResolutionActor()
    private var names: Set<String> = []

    /// Resolves one named conflict group when not already resolving that name. Does nothing if that name is already in flight.
    func resolveConflicts(
        name: String,
        conflicted: [GKSavedGame],
        resolver: @escaping GKSavedGame.ConflictResolver
    ) async throws {
        guard !names.contains(name) else {
            logger.debug("Skipping saved game conflict resolution for \(name): already in flight")
            return
        }
        names.insert(name)
        defer { names.remove(name) }
        var current = conflicted
        while current.count > 1 {
            let first = current[0]
            let rest = Array(current.dropFirst())
            let data = try await resolver(name, first, rest)
            current = try await GKLocalPlayer.local.resolveConflictingSavedGames(current, with: data)
        }
    }
}

extension GKSavedGame {
    /// Returns the bytes to keep for a conflicting set of saved games.
    /// - Parameter name: The unique save name for this conflict group (same as each branch’s ``GKSavedGame/name`` when present).
    /// - Parameter first: One branch of the conflict (always present).
    /// - Parameter rest: The other branches (together with `first`, always at least two saves).
    public typealias ConflictResolver = @Sendable (_ name: String, _ first: GKSavedGame, _ rest: [GKSavedGame]) async throws -> Data

    /// Resolves a conflict set by loading data from the most recently modified branch.
    /// Pass this to ``detectAndResolveConflicts(in:with:)``.
    public static let mostRecentConflictResolver: GKSavedGame.ConflictResolver = { _, first, rest in
        let savedGames = [first] + rest
        let mostRecent = savedGames.max(by: {
            $0.modificationDate ?? Date.distantPast < $1.modificationDate ?? Date.distantPast
        }) ?? first
        return try await mostRecent.loadData()
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
        var conflictsDetected = false
        var resolveError: Error?
        for (name, conflicted) in groupedByName where conflicted.count > 1 {
            conflictsDetected = true
            do {
                try await SavedGameConflictResolutionActor.shared.resolveConflicts(
                    name: name,
                    conflicted: conflicted,
                    resolver: resolver
                )
            } catch {
                resolveError = error
            }
        }
        if let resolveError {
            throw resolveError
        }
        return conflictsDetected
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
