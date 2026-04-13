// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

private final class GKLocalPlayerSingleton: GKLocalPlayer {}

open class GKLocalPlayer: GKPlayer {
    private static let _local: GKLocalPlayer = GKLocalPlayerSingleton()

    open class var local: GKLocalPlayer { _local }

    private var authenticated: Bool = false

    open var isAuthenticated: Bool { authenticated }

    @available(*, unavailable)
    open var isUnderage: Bool { get { fatalError() } }

    @available(*, unavailable)
    open var isMultiplayerGamingRestricted: Bool { get { fatalError() } }

    @available(*, unavailable)
    open var isPersonalizedCommunicationRestricted: Bool { get { fatalError() } }

    @available(*, unavailable)
    open func loadRecentPlayers(completionHandler: (@Sendable ([GKPlayer]?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadRecentPlayers() async throws -> [GKPlayer] { fatalError() }

    @available(*, unavailable)
    open func loadChallengableFriends(completionHandler: (@Sendable ([GKPlayer]?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadChallengableFriends() async throws -> [GKPlayer] { fatalError() }

    @available(*, unavailable)
    open func fetchItems(forIdentityVerificationSignature completionHandler: (@Sendable (URL?, Data?, Data?, UInt64, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func fetchItemsForIdentityVerificationSignature() async throws -> (URL, Data, Data, UInt64) {
        fatalError()
    }

    /// Updates local player identity from Play Games Services. Call before returning from auth refresh when values must be visible synchronously.
    /// - Parameter playGamesPlayer: `nil`, or a `com.google.android.gms.games.Player` from PGS.
    static func applyPlayGamesState(isAuthenticated: Bool, playGamesPlayer: com.google.android.gms.games.Player?) {
        let p = local
        p.authenticated = isAuthenticated
        p.playGamesPlayer = playGamesPlayer
    }

    /// A single listener may be registered once. Registering multiple times results in undefined behavior. The registered listener will receive callbacks for any selector it responds to.
    open func register(_ listener: any GKLocalPlayerListener) {
        compactWeakListeners()
        let obj = listener as AnyObject
        guard !includesListener(obj) else { return }
        registeredListeners.append(WeakLocalPlayerListener(obj))
    }

    open func unregisterListener(_ listener: any GKLocalPlayerListener) {
        let obj = listener as AnyObject
        registeredListeners.removeAll { $0.object === obj }
        compactWeakListeners()
    }

    open func unregisterAllListeners() {
        registeredListeners.removeAll()
    }

    private var registeredListeners: [WeakLocalPlayerListener] = []

    private func compactWeakListeners() {
        registeredListeners.removeAll { $0.object == nil }
    }

    private func includesListener(_ obj: AnyObject) -> Bool {
        registeredListeners.contains { $0.object === obj }
    }

    /// Dispatches ``GKSavedGameListener/player(_:hasConflictingSavedGames:)`` on the main actor.
    internal func notifySavedGameConflicts(_ games: [GKSavedGame]) async {
        await MainActor.run { [self] in
            compactWeakListeners()
            let localPlayer = self
            for ref in registeredListeners {
                guard let listener = ref.object as? any GKLocalPlayerListener else { continue }
                listener.player(localPlayer, hasConflictingSavedGames: games)
            }
        }
    }
}

private final class WeakLocalPlayerListener {
    weak var object: AnyObject?
    init(_ object: AnyObject) { self.object = object }
}

#endif
#endif
