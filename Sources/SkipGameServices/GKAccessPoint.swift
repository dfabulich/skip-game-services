// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import SwiftUI
import android.content.Intent
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.leaderboard.LeaderboardVariant
import java.util.UUID

extension GKAccessPoint {
    public enum Location: Int, @unchecked Sendable {
        case topLeading = 0
        case topTrailing = 1
        case bottomLeading = 2
        case bottomTrailing = 3
    }
}

public enum GKGameCenterViewControllerState: Int, @unchecked Sendable {
    case `default` = -1
    case leaderboards = 0
    case achievements = 1
    case challenges = 2
    case localPlayerProfile = 3
    case dashboard = 4
    case localPlayerFriendsList = 5
}

@MainActor
open class GKAccessPoint: NSObject {
    private static let _shared = GKAccessPoint()

    open class var shared: GKAccessPoint { _shared }

    @available(*, unavailable)
    open var isActive: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    open var isVisible: Bool { false }

    public private(set) var isPresentingGameCenter: Bool = false

    @available(*, unavailable)
    open var showHighlights: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var location: GKAccessPoint.Location {
        get { fatalError() }
        set { fatalError() }
    }

    @available(*, unavailable)
    open var frameInScreenCoordinates: CGRect { fatalError() }

    private override init() {
        super.init()
    }

    private var activity: ComponentActivity? { UIApplication.shared.androidActivity }

    /// Presents the intent and suspends until the activity result fires; manages ``isPresentingGameCenter`` for the presentation window.
    private func presentPlayGamesIntent(_ intent: Intent) async {
        guard !isPresentingGameCenter,
            GKLocalPlayer.local.isAuthenticated,
            let activity else {
            return
        }
        isPresentingGameCenter = true
        var launcher: ActivityResultLauncher<Intent>? = nil
        defer {
            isPresentingGameCenter = false
            launcher?.unregister()
        }

        let registry = activity.activityResultRegistry
        let uniqueKey = UUID.randomUUID().toString()
        let contract = ActivityResultContracts.StartActivityForResult()
        return await withCheckedContinuation { continuation in
            launcher = registry.register(uniqueKey, contract) { _ in
                Task { @MainActor in
                    continuation.resume(returning: ())
                }
            }
            guard let launcher else {
                continuation.resume(returning: ())
                return
            }
            launcher.launch(intent)
        }
    }

    private static func pgsTimeSpan(_ timeScope: GKLeaderboard.TimeScope) -> Int32 {
        switch timeScope {
        case .today: return LeaderboardVariant.TIME_SPAN_DAILY
        case .week: return LeaderboardVariant.TIME_SPAN_WEEKLY
        case .allTime: return LeaderboardVariant.TIME_SPAN_ALL_TIME
        }
    }

    private static func pgsCollection(_ playerScope: GKLeaderboard.PlayerScope) -> Int32 {
        switch playerScope {
        case .global: return LeaderboardVariant.COLLECTION_PUBLIC
        case .friendsOnly: return LeaderboardVariant.COLLECTION_FRIENDS
        }
    }

    private func resolveIntent(for state: GKGameCenterViewControllerState, activity: ComponentActivity) async throws -> Intent {
        switch state {
        case .achievements, .default, .dashboard:
            // No PGS “dashboard”; achievements UI is the closest default.
            let client = PlayGames.getAchievementsClient(activity)
            let task: GmsTask<Intent> = client.getAchievementsIntent()
            return try await gmsTaskResult(task)
        case .leaderboards:
            let client = PlayGames.getLeaderboardsClient(activity)
            let task: GmsTask<Intent> = client.getAllLeaderboardsIntent()
            return try await gmsTaskResult(task)
        case .localPlayerProfile:
            let client = PlayGames.getPlayersClient(activity)
            let task: GmsTask<Intent> = client.getPlayerSearchIntent()
            return try await gmsTaskResult(task)
        default:
            let error = GKError("GKGameCenterViewControllerState \(state) is not supported for Play Games Services")
            logger.error("\(error)")
            throw error
        }
    }

    open func trigger(handler: @escaping () -> Void) {
        trigger(state: .default, handler: handler)
    }

    open func trigger(state: GKGameCenterViewControllerState, handler: @escaping () -> Void) {
        Task { @MainActor in
            if let activity, let intent = try? await resolveIntent(for: state, activity: activity) {
                await presentPlayGamesIntent(intent)
            }
            handler()
        }
    }

    open func trigger(
        leaderboardID: String,
        playerScope: GKLeaderboard.PlayerScope,
        timeScope: GKLeaderboard.TimeScope,
        handler: (() -> Void)? = nil
    ) {
        let completion = handler ?? {}
        Task { @MainActor in
            let maps: SkipLeaderboardIdentifierRegistration.Maps
            do { maps = try await requireRegisteredLeaderboardMaps() }
            catch {
                logger.error("\(error)")
                completion()
                return
            }
            if let activity,
                let googleId = maps.logicalToGoogle[leaderboardID],
                let timeSpan = Self.pgsTimeSpan(timeScope),
                let collection = Self.pgsCollection(playerScope),
                let client = PlayGames.getLeaderboardsClient(activity),
                let task: GmsTask<Intent> = client.getLeaderboardIntent(googleId, timeSpan, collection),
                let intent = try? await gmsTaskResult(task) {
                await presentPlayGamesIntent(intent)
            }
            completion()
        }
    }

    open func trigger(player: GKPlayer, handler: (() -> Void)? = nil) {
        let completion = handler ?? {}
        let playerId = player.gamePlayerID
        guard !playerId.isEmpty else {
            completion()
            return
        }
        Task { @MainActor in
            if let activity,
                let client = PlayGames.getPlayersClient(activity),
                let task: GmsTask<Intent> = client.getCompareProfileIntent(playerId),
                let intent = try? await gmsTaskResult(task) {
                await presentPlayGamesIntent(intent)
            }
            completion()
        }
    }

    @available(*, unavailable)
    open func trigger(achievementID: String, handler: (() -> Void)? = nil) { fatalError() }

    @available(*, unavailable)
    open func trigger(leaderboardSetID: String, handler: (() -> Void)? = nil, unusedp: Nothing? = nil) { fatalError() }

    @available(*, unavailable)
    public func triggerForPlayTogether(handler: @escaping @Sendable () -> Void) { fatalError() }

    @available(*, unavailable)
    public func triggerForPlayTogether() async { fatalError() }

    @available(*, unavailable)
    public func triggerForChallenges(handler: @escaping @Sendable () -> Void) { fatalError() }

    @available(*, unavailable)
    public func triggerForChallenges() async { fatalError() }

    // Omitted on Skip: JVM signature would match `trigger(leaderboardSetID:handler:unusedp:)` (Kotlin does not overload on parameter labels).
    // @available(*, unavailable)
    // public func trigger(challengeDefinitionID: String, handler: @escaping @Sendable () -> Void) { fatalError() }

    @available(*, unavailable)
    public func trigger(challengeDefinitionID: String) async { fatalError() }

    // Omitted on Skip: JVM signature would match `trigger(achievementID:handler:)` (Kotlin does not overload on parameter labels).
    // @available(*, unavailable)
    // public func trigger(gameActivityDefinitionID: String, handler: @escaping @Sendable () -> Void) { fatalError() }

    @available(*, unavailable)
    public func trigger(gameActivityDefinitionID: String) async { fatalError() }

    @available(*, unavailable)
    open func trigger(gameActivity: GKGameActivity, handler: @escaping @Sendable () -> Void) { fatalError() }

    @available(*, unavailable)
    open func trigger(gameActivity: GKGameActivity) async { fatalError() }

    @available(*, unavailable)
    public func triggerForFriending(handler: @escaping @Sendable () -> Void) { fatalError() }

    @available(*, unavailable)
    public func triggerForFriending() async { fatalError() }

    @available(*, unavailable)
    public func triggerForArcade(handler: @escaping @Sendable () -> Void) { fatalError() }

    @available(*, unavailable)
    public func triggerForArcade() async { fatalError() }
}

#endif
#endif
