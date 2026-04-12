// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

public let GKPlayerIDNoLongerAvailable: String = ""

open class GKPlayer: GKBasePlayer {
    /// Holds `com.google.android.gms.games.Player` on Android. Must use the fully-qualified type (not `import` + `Player`) so bridged API is validated and projected as `AnyDynamicObject` in native Swift.
    var _skip_playGamesPlayer: com.google.android.gms.games.Player?

    public override init() {
        super.init()
    }

    /// - Parameter playGamesPlayer: Pass `nil` or a `com.google.android.gms.games.Player` instance from Play Games Services.
    public init(playGamesPlayer: com.google.android.gms.games.Player?) {
        super.init()
        self._skip_playGamesPlayer = playGamesPlayer
    }

    open var gamePlayerID: String {
        guard let p = _skip_playGamesPlayer else { return "" }
        return p.getPlayerId() ?? ""
    }

    open var displayName: String {
        guard let p = _skip_playGamesPlayer else { return "" }
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
