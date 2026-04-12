// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

private final class GKLocalPlayerSingleton: GKLocalPlayer {}

open class GKLocalPlayer: GKPlayer {
    private static let _local: GKLocalPlayer = GKLocalPlayerSingleton()

    open class var local: GKLocalPlayer { _local }

    private var _skip_isAuthenticated: Bool = false

    open var isAuthenticated: Bool { _skip_isAuthenticated }

    @available(*, unavailable)
    open var isUnderage: Bool { get { fatalError() } }

    @available(*, unavailable)
    open var isMultiplayerGamingRestricted: Bool { get { fatalError() } }

    @available(*, unavailable)
    open var isPersonalizedCommunicationRestricted: Bool { get { fatalError() } }

    @available(*, unavailable)
    open func loadRecentPlayers(completionHandler: (@Sendable ([GKPlayer]?, (any Error)?) -> Void)? = nil) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadRecentPlayers() async throws -> [GKPlayer] { fatalError() }

    @available(*, unavailable)
    open func loadChallengableFriends(completionHandler: (@Sendable ([GKPlayer]?, (any Error)?) -> Void)? = nil) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadChallengableFriends() async throws -> [GKPlayer] { fatalError() }

    @available(*, unavailable)
    open func fetchItems(forIdentityVerificationSignature completionHandler: (@Sendable (URL?, Data?, Data?, UInt64, (any Error)?) -> Void)? = nil) {
        fatalError()
    }

    @available(*, unavailable)
    open func fetchItemsForIdentityVerificationSignature() async throws -> (URL, Data, Data, UInt64) {
        fatalError()
    }

    /// Updates local player identity from Play Games Services. Call before returning from auth refresh when values must be visible synchronously.
    /// - Parameter playGamesPlayer: `nil`, or a `com.google.android.gms.games.Player` from PGS.
    static func _skip_applyPlayGamesState(isAuthenticated: Bool, playGamesPlayer: com.google.android.gms.games.Player?) {
        let p = local
        p._skip_isAuthenticated = isAuthenticated
        p._skip_playGamesPlayer = playGamesPlayer
    }
}

#endif
#endif
