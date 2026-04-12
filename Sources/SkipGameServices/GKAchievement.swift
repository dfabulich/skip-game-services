// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation
import SkipUI
import androidx.activity.ComponentActivity
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.AchievementsClient
import com.google.android.gms.games.AnnotatedData
import com.google.android.gms.games.achievement.AchievementBuffer

extension com.google.android.gms.games.achievement.Achievement {
    /// `true` when ``getType()`` is ``TYPE_STANDARD`` (Play Games Services javadoc).
    var isStandard: Bool {
        getType() == com.google.android.gms.games.achievement.Achievement.TYPE_STANDARD
    }

    /// `true` when ``getType()`` is ``TYPE_INCREMENTAL``.
    var isIncremental: Bool {
        getType() == com.google.android.gms.games.achievement.Achievement.TYPE_INCREMENTAL
    }

    /// `true` when ``getState()`` is ``STATE_UNLOCKED``.
    var isUnlocked: Bool {
        getState() == com.google.android.gms.games.achievement.Achievement.STATE_UNLOCKED
    }
}

/// Loads all achievement definitions from Play Games Services; releases the buffer before returning.
internal func _skip_loadPGSAchievementDefinitions() async throws -> [com.google.android.gms.games.achievement.Achievement] {
    let activity: ComponentActivity = UIApplication.shared.androidActivity!
    let client: AchievementsClient = PlayGames.getAchievementsClient(activity)
    let task: GmsTask<AnnotatedData<AchievementBuffer>> = client.load(false)
    let annotated: AnnotatedData<AchievementBuffer> = try await gmsTaskResult(task)
    guard let buffer: AchievementBuffer = annotated.get() else {
        throw NSError(
            domain: "GKAchievement",
            code: 5,
            userInfo: [NSLocalizedDescriptionKey: "Play Games achievement data was unavailable"]
        )
    }
    defer { buffer.release() }
    let count: Int = Int(buffer.getCount())
    var out: [com.google.android.gms.games.achievement.Achievement] = []
    for i in 0..<count {
        out.append(buffer.get(Int32(i)))
    }
    return out
}

open class GKAchievement: NSObject {
    open var identifier: String = ""

    /// Required, Percentage of achievement complete.
    open var percentComplete: Double = 0

    private var _lastReportedDate: Date = Date(timeIntervalSince1970: 0)

    /// Set to NO until percentComplete = 100.
    open var isCompleted: Bool { percentComplete >= 100.0 }

    /// Date the achievement was last reported. Read-only. Created at initialization
    open var lastReportedDate: Date { _lastReportedDate }

    /// Designated initializer
    public init(identifier: String) {
        self.identifier = identifier
        self.percentComplete = 0
        self._lastReportedDate = Date(timeIntervalSince1970: 0)
        super.init()
    }

    private init(pgsAchievement: com.google.android.gms.games.achievement.Achievement) {
        let id = pgsAchievement.getAchievementId() ?? ""
        let percent: Double
        if pgsAchievement.isStandard {
            percent = pgsAchievement.isUnlocked ? 100.0 : 0.0
        } else if pgsAchievement.isIncremental {
            let current = Int(pgsAchievement.getCurrentSteps())
            let total = Int(pgsAchievement.getTotalSteps())
            percent = total > 0 ? min(100.0, Double(current) / Double(total) * 100.0) : 0.0
        } else {
            percent = 0.0
        }
        let ms = pgsAchievement.getLastUpdatedTimestamp()
        let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
        self.identifier = id
        self.percentComplete = percent
        self._lastReportedDate = date
        super.init()
    }

    /// Asynchronously load all achievements for the local player
    open class func loadAchievements() async throws -> [GKAchievement] {
        let pgs = try await _skip_loadPGSAchievementDefinitions()
        return pgs.map { GKAchievement(pgsAchievement: $0) }
    }

    /// Report an array of achievements to the server.
    open class func report(_ achievements: [GKAchievement]) async throws {
        let definitions = try await _skip_loadPGSAchievementDefinitions()
        var defById: [String: com.google.android.gms.games.achievement.Achievement] = [:]
        for d in definitions {
            let id = d.getAchievementId()
            if !id.isEmpty { defById[id] = d }
        }

        let client: AchievementsClient = PlayGames.getAchievementsClient(UIApplication.shared.androidActivity!)

        for gk in achievements {
            let id = gk.identifier
            let def = defById[id]
            let percent = gk.percentComplete

            if def?.isStandard ?? true {
                if percent >= 100.0 {
                    let task = client.unlockImmediate(id)
                    try await gmsTaskResult(task)
                }
                continue
            }

            if let def, def.isIncremental {
                let totalSteps = Int(def.getTotalSteps() ?? 0)
                guard totalSteps > 0 else { continue }
                if percent <= 0 { continue }
                let targetSteps: Int
                if percent >= 100.0 {
                    targetSteps = totalSteps
                } else {
                    let raw = (percent / 100.0) * Double(totalSteps)
                    var rounded = Int(raw.rounded())
                    rounded = max(1, min(totalSteps, rounded))
                    targetSteps = rounded
                }
                let task: GmsTask<Bool> = client.setStepsImmediate(id, Int32(targetSteps))
                try await gmsTaskResult(task)
            }
        }
    }

    @available(*, unavailable)
    open class func loadAchievements(completionHandler: (@Sendable ([GKAchievement]?, (any Error)?) -> Void)? = nil) {
        fatalError()
    }

    @available(*, unavailable)
    open class func resetAchievements(completionHandler: (@Sendable ((any Error)?) -> Void)? = nil) {
        fatalError()
    }

    @available(*, unavailable)
    open class func resetAchievements() async throws {
        fatalError()
    }

    @available(*, unavailable)
    open class func report(_ achievements: [GKAchievement], withCompletionHandler completionHandler: (@Sendable ((any Error)?) -> Void)? = nil) {
        fatalError()
    }

    public init(identifier: String, player: GKPlayer) {
        fatalError()
    }

    open var showsCompletionBanner: Bool {
        get { fatalError() }
        set { fatalError() }
    }

    open var player: GKPlayer { fatalError() }
}

extension GKAchievement {
    @available(*, unavailable)
    public init(identifier: String?, forPlayer playerID: String) {
        fatalError()
    }

    open var playerID: String? { fatalError() }
}

#endif
#endif
