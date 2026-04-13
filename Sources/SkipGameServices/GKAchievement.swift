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

// MARK: - Achievement ID registration (logical GameKit id ↔ Play Games opaque id)

@MainActor
internal enum _SkipAchievementIdentifierRegistration {
    struct Maps: Sendable {
        let logicalToGoogle: [String: String]
        let googleToLogical: [String: String]
    }

    private(set) static var maps: Maps?

    static func register(logicalToGoogle: [String: String]) throws {
        var googleToLogical: [String: String] = [:]
        for (logical, google) in logicalToGoogle {
            if let existingLogical = googleToLogical[google], existingLogical != logical {
                throw GKError(
                    "Duplicate Play Games achievement id '\(google)': mapped from both '\(existingLogical)' and '\(logical)'"
                )
            }
            googleToLogical[google] = logical
        }
        maps = Maps(logicalToGoogle: logicalToGoogle, googleToLogical: googleToLogical)
    }
}

/// Ensures achievement id registration ran; returns the maps from the main actor.
internal func _skip_requireRegisteredAchievementMaps() async throws -> _SkipAchievementIdentifierRegistration.Maps {
    try await MainActor.run {
        guard let maps = _SkipAchievementIdentifierRegistration.maps else {
            throw GKError(
                "Achievement identifiers not registered; call GKAchievement.registerAchievementIdentifiers(_:) before using Play Games achievement APIs."
            )
        }
        return maps
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

    /// Play Games achievement id when this instance came from PGS; `nil` when created with ``init(identifier:)`` (opaque id comes from the registration map via ``opaqueIdentifier``).
    private var _backingOpaquePlayGamesId: String? = nil

    /// Set to NO until percentComplete = 100.
    open var isCompleted: Bool { percentComplete >= 100.0 }

    /// Date the achievement was last reported. Read-only. Created at initialization
    open var lastReportedDate: Date { _lastReportedDate }

    /// Play Games Services achievement id, when applicable; `nil` on Apple GameKit.
    @MainActor
    public var opaqueIdentifier: String? {
        if let id = _backingOpaquePlayGamesId, !id.isEmpty { return id }
        return _SkipAchievementIdentifierRegistration.maps?.logicalToGoogle[identifier]
    }

    /// Registers logical achievement ids (matching iOS Game Center) to Play Games opaque ids. Required before ``loadAchievements()``, ``report(_:)``, and ``GKAchievementDescription/loadAchievementDescriptions()``. Call from the main actor; later calls replace the mapping.
    @MainActor
    open class func registerAchievementIdentifiers(_ map: [String: String]) throws {
        try _SkipAchievementIdentifierRegistration.register(logicalToGoogle: map)
    }

    /// Designated initializer
    public init(identifier: String) {
        self.identifier = identifier
        self.percentComplete = 0
        self._lastReportedDate = Date(timeIntervalSince1970: 0)
        self._backingOpaquePlayGamesId = nil
        super.init()
    }

    private init(pgsAchievement: com.google.android.gms.games.achievement.Achievement, maps: _SkipAchievementIdentifierRegistration.Maps) throws {
        let googleId = pgsAchievement.getAchievementId() ?? ""
        guard let logical = maps.googleToLogical[googleId] else {
            throw GKError("Unmapped Play Games achievement id '\(googleId)'")
        }
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
        self.identifier = logical
        self.percentComplete = percent
        self._lastReportedDate = date
        self._backingOpaquePlayGamesId = googleId.isEmpty ? nil : googleId
        super.init()
    }

    /// Asynchronously load all achievements for the local player
    open class func loadAchievements() async throws -> [GKAchievement] {
        let maps = try await _skip_requireRegisteredAchievementMaps()
        let pgs = try await _skip_loadPGSAchievementDefinitions()
        return try pgs.map { try GKAchievement(pgsAchievement: $0, maps: maps) }
    }

    /// Report an array of achievements to the server.
    open class func report(_ achievements: [GKAchievement]) async throws {
        let maps = try await _skip_requireRegisteredAchievementMaps()
        let definitions = try await _skip_loadPGSAchievementDefinitions()
        var defById: [String: com.google.android.gms.games.achievement.Achievement] = [:]
        for d in definitions {
            let id = d.getAchievementId()
            if !id.isEmpty { defById[id] = d }
        }

        let client: AchievementsClient = PlayGames.getAchievementsClient(UIApplication.shared.androidActivity!)

        for gk in achievements {
            guard let googleId = maps.logicalToGoogle[gk.identifier] else {
                throw GKError("No Play Games mapping for achievement '\(gk.identifier)'")
            }
            let def = defById[googleId]
            let percent = gk.percentComplete

            if def?.isStandard ?? true {
                if percent >= 100.0 {
                    let task = client.unlockImmediate(googleId)
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
                let task: GmsTask<Bool> = client.setStepsImmediate(googleId, Int32(targetSteps))
                try await gmsTaskResult(task)
            }
        }
    }

    @available(*, unavailable)
    open class func loadAchievements(completionHandler: (@Sendable ([GKAchievement]?, (any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open class func resetAchievements(completionHandler: (@Sendable ((any Error)?) -> Void)) {
        fatalError()
    }

    @available(*, unavailable)
    open class func resetAchievements() async throws {
        fatalError()
    }

    @available(*, unavailable)
    open class func report(_ achievements: [GKAchievement], withCompletionHandler completionHandler: (@Sendable ((any Error)?) -> Void)) {
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
        self.init(identifier: identifier ?? "")
    }

    open var playerID: String? { fatalError() }
}

#endif
#endif
