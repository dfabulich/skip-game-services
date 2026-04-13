// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation
import SkipUI
import androidx.activity.ComponentActivity
import com.google.android.gms.games.AnnotatedData
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.AchievementsClient
import com.google.android.gms.games.achievement.AchievementBuffer

/// GKAchievementDescription is a full description of the achievement as defined in Play Console (Play Games Services).
open class GKAchievementDescription: NSObject {
    private let _identifier: String
    private let _opaquePlayGamesId: String
    private let _title: String
    private let _achievedDescription: String

    open var identifier: String { _identifier }

    /// Play Games Services achievement id when loaded from PGS; `nil` on Apple GameKit.
    @MainActor
    public var opaqueIdentifier: String? {
        _opaquePlayGamesId.isEmpty ? nil : _opaquePlayGamesId
    }

    /// The title of the achievement.
    open var title: String { _title }

    /// The description for an unachieved achievement (Apple header naming; Play Games exposes a single description string).
    open var achievedDescription: String { _achievedDescription }

    fileprivate init(logicalIdentifier: String, opaquePlayGamesId: String, title: String, achievedDescription: String) {
        self._identifier = logicalIdentifier
        self._opaquePlayGamesId = opaquePlayGamesId
        self._title = title
        self._achievedDescription = achievedDescription
        super.init()
    }

    /// Asynchronously load all achievement descriptions
    open class func loadAchievementDescriptions() async throws -> [GKAchievementDescription] {
        let maps = try await _skip_requireRegisteredAchievementMaps()
        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let client: AchievementsClient = PlayGames.getAchievementsClient(activity)
        let task: GmsTask<AnnotatedData<AchievementBuffer>> = client.load(false)
        let annotated: AnnotatedData<AchievementBuffer> = try await gmsTaskResult(task)
        let frozen: [com.google.android.gms.games.achievement.Achievement] = try _skip_collectFrozenRowsFromAnnotatedData(annotated)
        var out: [GKAchievementDescription] = []
        for p in frozen {
            let googleId = p.getAchievementId() ?? ""
            guard let logical = maps.googleToLogical[googleId] else {
                throw GKError("Unmapped Play Games achievement id '\(googleId)'")
            }
            out.append(GKAchievementDescription(
                logicalIdentifier: logical,
                opaquePlayGamesId: googleId,
                title: p.getName(),
                achievedDescription: p.getDescription()
            ))
        }
        return out
    }

    @available(*, unavailable)
    open class func loadAchievementDescriptions(completionHandler: (@Sendable ([GKAchievementDescription]?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open var groupIdentifier: String? { fatalError() }

    /// The description for an achieved achievement.
    @available(*, unavailable)
    open var unachievedDescription: String { fatalError() }

    @available(*, unavailable)
    open var maximumPoints: Int { fatalError() }

    @available(*, unavailable)
    open var isHidden: Bool { fatalError() }

    @available(*, unavailable)
    open var isReplayable: Bool { fatalError() }

    @available(*, unavailable)
    open var releaseState: GKReleaseState { fatalError() }

    @available(*, unavailable)
    open var activityIdentifier: String { fatalError() }

    @available(*, unavailable)
    open var activityProperties: [String: String] { fatalError() }
}

extension GKAchievementDescription {
    @available(*, unavailable)
    public var rarityPercent: Double? { fatalError() }
}

extension GKAchievementDescription {
    @available(*, unavailable)
    open func loadImage(completionHandler: (@Sendable (UIImage?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open func loadImage() async throws -> UIImage {
        fatalError()
    }

    @available(*, unavailable)
    open class func incompleteAchievementImage() -> UIImage {
        fatalError()
    }

    @available(*, unavailable)
    open class func placeholderCompletedAchievementImage() -> UIImage {
        fatalError()
    }
}

#endif
#endif
