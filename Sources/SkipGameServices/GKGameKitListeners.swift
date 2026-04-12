// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

// MARK: - Stub types (signatures only; Play Games does not implement these GameKit features on Android)

open class GKChallenge: NSObject {}
open class GKGameActivity: NSObject {}
open class GKInvite: NSObject {}
open class GKTurnBasedMatch: NSObject {}
open class GKTurnBasedExchange: NSObject {}
open class GKTurnBasedExchangeReply: NSObject {}

// MARK: - Listener protocols

/// On Android, Play Games Services does not deliver Game Center–style push notifications when another device updates a cloud save (see GameKit’s ``GKSavedGameListener/player(_:didModifySavedGame:)``). Snapshots sync when your app calls the API; to detect remote changes, refresh on resume (e.g. ``GKLocalPlayer/fetchSavedGames()``) and compare ``GKSavedGame/modificationDate`` to your last-seen state. SkipGameServices invokes ``player(_:hasConflictingSavedGames:)`` on the main actor when ``SnapshotsClient`` returns a conflict (manual resolution policy). Pass those same ``GKSavedGame`` instances to ``GKLocalPlayer/resolveConflictingSavedGames(_:with:)``; they carry internal state required for ``SnapshotsClient/resolveConflict``. If a nested conflict remains, ``resolveConflictingSavedGames`` returns the saves still in conflict (like GameKit) for another merge pass.
public protocol GKSavedGameListener: NSObjectProtocol {}

public extension GKSavedGameListener {
    func player(_ player: GKPlayer, didModifySavedGame savedGame: GKSavedGame) {}

    func player(_ player: GKPlayer, hasConflictingSavedGames savedGames: [GKSavedGame]) {}
}

/// Marker only on Android: GameKit’s challenge / invite / turn-based listener methods are not modeled here because Kotlin cannot represent the overlapping `player(_:…)` overloads from separate protocol extensions. Use ``GKLocalPlayer/register(_:)`` with a type that also conforms to ``GKSavedGameListener`` for saved games.
public protocol GKChallengeListener: NSObjectProtocol {}

/// Marker only; see note on ``GKChallengeListener``.
public protocol GKGameActivityListener: NSObjectProtocol {}

/// Marker only; see note on ``GKChallengeListener``.
public protocol GKInviteEventListener: NSObjectProtocol {}

/// Marker only; see note on ``GKChallengeListener``.
public protocol GKTurnBasedEventListener: NSObjectProtocol {}

public protocol GKLocalPlayerListener: GKChallengeListener, GKGameActivityListener, GKInviteEventListener, GKSavedGameListener, GKTurnBasedEventListener {}

#endif
#endif
