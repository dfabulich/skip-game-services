// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation

/// GKScore represents a score in the leaderboards.
open class GKScore: NSObject {

    @available(*, unavailable)
    public init(leaderboardIdentifier identifier: String) {
        fatalError()
    }

    @available(*, unavailable)
    public init(leaderboardIdentifier identifier: String, player: GKPlayer) {
        fatalError()
    }

    @available(*, unavailable)
    open var value: Int64 {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var formattedValue: String? { fatalError() }

    @available(*, unavailable)
    open var leaderboardIdentifier: String {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var context: UInt64 {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var date: Date { fatalError() }

    @available(*, unavailable)
    open var player: GKPlayer { fatalError() }

    @available(*, unavailable)
    open var rank: Int { fatalError() }

    @available(*, unavailable)
    open var shouldSetDefaultLeaderboard: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open class func report(_ scores: [GKScore], withCompletionHandler completionHandler: (@Sendable ((any Error)?) -> Void)? = nil) {
        fatalError()
    }

    @available(*, unavailable)
    open class func report(_ scores: [GKScore]) async throws {
        fatalError()
    }
}

extension GKScore {

    @available(*, unavailable)
    public init?(leaderboardIdentifier identifier: String, forPlayer playerID: String) {
        fatalError()
    }

    @available(*, unavailable)
    open var playerID: String? { fatalError() }
}

#endif
#endif
