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

    /// A single listener may be registered once. Registering multiple times results in undefined behavior. The registered listener will receive callbacks for any selector it responds to.
    open func register(_ listener: any GKLocalPlayerListener) {
        _skip_compactWeakListeners()
        let obj = listener as AnyObject
        guard !_skip_includesListener(obj) else { return }
        _skip_registeredListeners.append(_SkipWeakLocalPlayerListener(obj))
    }

    open func unregisterListener(_ listener: any GKLocalPlayerListener) {
        let obj = listener as AnyObject
        _skip_registeredListeners.removeAll { $0.object === obj }
        _skip_compactWeakListeners()
    }

    open func unregisterAllListeners() {
        _skip_registeredListeners.removeAll()
    }

    private var _skip_registeredListeners: [_SkipWeakLocalPlayerListener] = []

    private func _skip_compactWeakListeners() {
        _skip_registeredListeners.removeAll { $0.object == nil }
    }

    private func _skip_includesListener(_ obj: AnyObject) -> Bool {
        _skip_registeredListeners.contains { $0.object === obj }
    }

    /// Dispatches ``GKSavedGameListener/player(_:hasConflictingSavedGames:)`` on the main actor.
    internal func _skip_notifySavedGameConflicts(_ games: [GKSavedGame]) async {
        await MainActor.run { [self] in
            _skip_compactWeakListeners()
            let localPlayer = self
            for ref in _skip_registeredListeners {
                guard let listener = ref.object as? any GKLocalPlayerListener else { continue }
                listener.player(localPlayer, hasConflictingSavedGames: games)
            }
        }
    }
}

private final class _SkipWeakLocalPlayerListener {
    weak var object: AnyObject?
    init(_ object: AnyObject) { self.object = object }
}

#endif
#endif
