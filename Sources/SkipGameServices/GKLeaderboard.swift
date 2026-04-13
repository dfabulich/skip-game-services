// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation
import SkipUI
import androidx.activity.ComponentActivity
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.LeaderboardsClient
import com.google.android.gms.games.AnnotatedData
import com.google.android.gms.games.leaderboard.LeaderboardBuffer

extension GKLeaderboard {

    public enum TimeScope: Int, @unchecked Sendable {
        case today = 0
        case week = 1
        case allTime = 2
    }

    public enum PlayerScope: Int, @unchecked Sendable {
        case global = 0
        case friendsOnly = 1
    }

    public enum LeaderboardType: Int, @unchecked Sendable {
        case classic = 0
        case recurring = 1
    }
}

/// Public stand-in for GameKit’s `NSRange` in leaderboard APIs. Skip Foundation’s `NSRange` is not Kotlin-public.
public typealias NSRange = Any

/// GKLeaderboard represents a single instance of a leaderboard for the current game.
open class GKLeaderboard: NSObject {

    private var _skip_leaderboardId: String = ""
    private var _skip_title: String? = nil

    /// Localized title
    open var title: String? { _skip_title }

    @available(*, unavailable)
    open var groupIdentifier: String? { fatalError() }

    @available(*, unavailable)
    open var baseLeaderboardID: String { fatalError() }

    @available(*, unavailable)
    open var type: GKLeaderboard.LeaderboardType { fatalError() }

    @available(*, unavailable)
    open var startDate: Date? { fatalError() }

    @available(*, unavailable)
    open var nextStartDate: Date? { fatalError() }

    @available(*, unavailable)
    open var duration: TimeInterval { fatalError() }

    @available(*, unavailable)
    open var leaderboardDescription: String { fatalError() }

    @available(*, unavailable)
    open var releaseState: GKReleaseState { fatalError() }

    @available(*, unavailable)
    open var activityIdentifier: String { fatalError() }

    @available(*, unavailable)
    open var activityProperties: [String: String] { fatalError() }

    @available(*, unavailable)
    open var isHidden: Bool { fatalError() }

    @available(*, unavailable)
    open class func loadLeaderboards(IDs leaderboardIDs: [String]?, completionHandler: @escaping @Sendable ([GKLeaderboard]?, (any Error)?) -> Void) {
        fatalError()
    }

    open class func loadLeaderboards(IDs leaderboardIDs: [String]?) async throws -> [GKLeaderboard] {
        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let client: LeaderboardsClient = PlayGames.getLeaderboardsClient(activity)
        if let leaderboardIDs {
            if leaderboardIDs.isEmpty {
                return []
            }
            var out: [GKLeaderboard] = []
            for id in leaderboardIDs {
                let task: GmsTask<AnnotatedData<com.google.android.gms.games.leaderboard.Leaderboard>> = client.loadLeaderboardMetadata(id, false)
                let annotated: AnnotatedData<com.google.android.gms.games.leaderboard.Leaderboard> = try await gmsTaskResult(task)
                guard let lb = annotated.get() else { continue }
                out.append(GKLeaderboard(pgsLeaderboard: lb))
            }
            return out
        } else {
            let task: GmsTask<AnnotatedData<LeaderboardBuffer>> = client.loadLeaderboardMetadata(false)
            let annotated: AnnotatedData<LeaderboardBuffer> = try await gmsTaskResult(task)
            guard let buffer: LeaderboardBuffer = annotated.get() else {
                throw NSError(
                    domain: "GKLeaderboard",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Play Games leaderboard metadata was unavailable"]
                )
            }
            defer { buffer.release() }
            let count: Int = Int(buffer.getCount())
            var out: [GKLeaderboard] = []
            for i in 0..<count {
                out.append(GKLeaderboard(pgsLeaderboard: buffer.get(Int32(i))))
            }
            return out
        }
    }

    @available(*, unavailable)
    open func loadPreviousOccurrence(completionHandler: @escaping @Sendable (GKLeaderboard?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadPreviousOccurrence() async throws -> GKLeaderboard? {
        fatalError()
    }

    @available(*, unavailable)
    open class func submitScore(_ score: Int, context: Int, player: GKPlayer, leaderboardIDs: [String], completionHandler: @escaping @Sendable ((any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open class func submitScore(_ score: Int, context: Int, player: GKPlayer, leaderboardIDs: [String]) async throws {
        fatalError()
    }

    @available(*, unavailable)
    open func submitScore(_ score: Int, context: Int, player: GKPlayer, completionHandler: @escaping @Sendable ((any Error)?) -> Void) {
        fatalError()
    }

    open func submitScore(_ score: Int, context: Int, player: GKPlayer) async throws {
        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let localId = GKLocalPlayer.local.gamePlayerID
        guard !localId.isEmpty, player.gamePlayerID == localId else {
            throw NSError(
                domain: "GKLeaderboard",
                code: 6,
                userInfo: [NSLocalizedDescriptionKey: "Scores can only be submitted for the signed-in local player"]
            )
        }
        let client: LeaderboardsClient = PlayGames.getLeaderboardsClient(activity)
        let raw: Int64 = Int64(score)
        if context == 0 {
            let task: GmsTask<com.google.android.gms.games.leaderboard.ScoreSubmissionData> = client.submitScoreImmediate(_skip_leaderboardId, raw)
            _ = try await gmsTaskResult(task)
        } else {
            let tag = String(context)
            let task: GmsTask<com.google.android.gms.games.leaderboard.ScoreSubmissionData> = client.submitScoreImmediate(_skip_leaderboardId, raw, tag)
            _ = try await gmsTaskResult(task)
        }
    }

    @available(*, unavailable)
    open func loadEntries(for playerScope: GKLeaderboard.PlayerScope, timeScope: GKLeaderboard.TimeScope, range: NSRange, completionHandler: @escaping @Sendable (GKLeaderboard.Entry?, [GKLeaderboard.Entry]?, Int, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadEntries(for playerScope: GKLeaderboard.PlayerScope, timeScope: GKLeaderboard.TimeScope, range: NSRange) async throws -> (GKLeaderboard.Entry?, [GKLeaderboard.Entry], Int) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadEntries(for players: [GKPlayer], timeScope: GKLeaderboard.TimeScope, completionHandler: @escaping @Sendable (GKLeaderboard.Entry?, [GKLeaderboard.Entry]?, (any Error)?) -> Void) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadEntries(for players: [GKPlayer], timeScope: GKLeaderboard.TimeScope) async throws -> (GKLeaderboard.Entry?, [GKLeaderboard.Entry]) {
        fatalError()
    }

    private init(pgsLeaderboard: com.google.android.gms.games.leaderboard.Leaderboard) {
        self._skip_leaderboardId = pgsLeaderboard.getLeaderboardId() ?? ""
        let displayName = pgsLeaderboard.getDisplayName()
        self._skip_title = (displayName?.isEmpty ?? true) ? nil : displayName
        super.init()
    }
}

extension GKLeaderboard {

    @available(*, unavailable)
    public init?(playerIDs: [String]?) {
        fatalError()
    }

    @available(*, unavailable)
    open var timeScope: GKLeaderboard.TimeScope {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var playerScope: GKLeaderboard.PlayerScope {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var identifier: String? {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var range: NSRange {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var scores: [GKScore]? { fatalError() }

    @available(*, unavailable)
    open var maxRange: Int { fatalError() }

    @available(*, unavailable)
    open var localPlayerScore: GKScore? { fatalError() }

    @available(*, unavailable)
    open var isLoading: Bool { fatalError() }

    /// Second parameter exists only so Kotlin/JVM does not merge this with ``init(playerIDs:)`` (both would otherwise be `<init>(Array)>`).
    @available(*, unavailable)
    public init(players: [GKPlayer], _kotlinJvmInitTag: Bool = false) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadScores(completionHandler: (([GKScore]?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open class func loadLeaderboards(completionHandler: (@Sendable ([GKLeaderboard]?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open class func loadLeaderboards() async throws -> [GKLeaderboard] {
        fatalError()
    }
}

extension GKLeaderboard {

    @available(*, unavailable)
    open func loadImage(completionHandler: (@Sendable (UIImage?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadImage() async throws -> UIImage {
        fatalError()
    }
}

extension GKLeaderboard {

    open class Entry: NSObject {

        @available(*, unavailable)
        open var player: GKPlayer { fatalError() }

        @available(*, unavailable)
        open var rank: Int { fatalError() }

        @available(*, unavailable)
        open var score: Int { fatalError() }

        @available(*, unavailable)
        open var formattedScore: String { fatalError() }

        @available(*, unavailable)
        open var context: Int { fatalError() }

        @available(*, unavailable)
        open var date: Date { fatalError() }
    }
}

#endif
#endif
