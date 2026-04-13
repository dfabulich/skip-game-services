// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

/// Mirrors GameKit’s friends authorization values without a Swift `Int` enum (Skip Kotlin does not support that pattern for this type).
public struct GKFriendsAuthorizationStatus: Hashable, @unchecked Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let notDetermined = GKFriendsAuthorizationStatus(rawValue: 0)
    public static let restricted = GKFriendsAuthorizationStatus(rawValue: 1)
    public static let denied = GKFriendsAuthorizationStatus(rawValue: 2)
    public static let authorized = GKFriendsAuthorizationStatus(rawValue: 3)
}

extension GKLocalPlayer {

    @available(*, unavailable)
    open func loadFriendPlayers(completionHandler: (@Sendable ([GKPlayer]?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func generateIdentityVerificationSignature(completionHandler: (@Sendable (URL?, Data?, Data?, UInt64, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func generateIdentityVerificationSignature() async throws -> (URL, Data, Data, UInt64) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadDefaultLeaderboardIdentifier(completionHandler: (@Sendable (String?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadDefaultLeaderboardIdentifier() async throws -> String {
        fatalError()
    }

    @available(*, unavailable)
    open func setDefaultLeaderboardIdentifier(_ leaderboardIdentifier: String, completionHandler: (@Sendable ((any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func setDefaultLeaderboardIdentifier(_ leaderboardIdentifier: String) async throws {
        fatalError()
    }
}

extension GKLocalPlayer {

    @available(*, unavailable)
    open func loadFriendsObsoleted(completionHandler: (@Sendable ([String]?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open var friends: [String]? { fatalError() }
}

extension GKLocalPlayer {

    @available(*, unavailable)
    open func loadFriendsAuthorizationStatus(_ completionHandler: @escaping @Sendable (GKFriendsAuthorizationStatus, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadFriendsAuthorizationStatus() async throws -> GKFriendsAuthorizationStatus {
        fatalError()
    }

    @available(*, unavailable)
    open func loadFriends(_ completionHandler: @escaping @Sendable ([GKPlayer]?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadFriends() async throws -> [GKPlayer] {
        fatalError()
    }

    @available(*, unavailable)
    open func loadFriends(identifiedBy identifiers: [String], completionHandler: @escaping @Sendable ([GKPlayer]?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadFriends(identifiedBy identifiers: [String]) async throws -> [GKPlayer] {
        fatalError()
    }
}

extension GKLocalPlayer {

    /// iOS GameKit uses `UIViewController`; on Skip/Android use an opaque value (typically unused because this API is unavailable).
    @available(*, unavailable)
    open var authenticateHandler: ((Any?, (any Error)?) -> Void)? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var isPresentingFriendRequestViewController: Bool { fatalError() }

    @available(*, unavailable)
    open func presentFriendRequestCreator(from viewController: Any) throws {
        fatalError()
    }
}

#endif
#endif
