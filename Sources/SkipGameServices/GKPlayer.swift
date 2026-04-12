// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation
import com.google.android.gms.games.Player

public let GKPlayerIDNoLongerAvailable: String = ""

open class GKPlayer: GKBasePlayer {
    /// Holds `com.google.android.gms.games.Player` on Android. Typed as `Any?` so Skip can transpile (the Java `Player` type is not a bridged stored-property type).
    var _skip_playGamesPlayer: Any?

    public override init() {
        super.init()
    }

    /// - Parameter playGamesPlayer: Pass `nil` or a `com.google.android.gms.games.Player` instance from Play Games Services.
    public init(playGamesPlayer: Any?) {
        super.init()
        self._skip_playGamesPlayer = playGamesPlayer
    }

    open var gamePlayerID: String {
        guard let p = _skip_playGamesPlayer as? Player else { return "" }
        return p.getPlayerId() ?? ""
    }

    open var displayName: String {
        guard let p = _skip_playGamesPlayer as? Player else { return "" }
        return p.getDisplayName() ?? ""
    }

    @available(*, unavailable)
    open func scopedIDsArePersistent() -> Bool { fatalError() }

    @available(*, unavailable)
    open var teamPlayerID: String { get { fatalError() } }

    @available(*, unavailable)
    open var alias: String { get { fatalError() } }

    @available(*, unavailable)
    open class func anonymousGuestPlayer(withIdentifier guestIdentifier: String) -> Self {
        fatalError()
    }

    @available(*, unavailable)
    open var guestIdentifier: String? { get { fatalError() } }

    @available(*, unavailable)
    open var isInvitable: Bool { get { fatalError() } }
}

#endif
#endif
