// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
#if SKIP
import Foundation
import SkipUI
import androidx.activity.ComponentActivity
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.SnapshotsClient
import com.google.android.gms.games.AnnotatedData
import com.google.android.gms.games.snapshot.Snapshot
import com.google.android.gms.games.snapshot.SnapshotContents
import com.google.android.gms.games.snapshot.SnapshotMetadata
import com.google.android.gms.games.snapshot.SnapshotMetadataBuffer
import com.google.android.gms.games.snapshot.SnapshotMetadataChange

/// Coalesces overlapping ``SnapshotsClient`` `commit`/`resolve`/`delete` work per unique snapshot name.
/// Concurrent writes for different names run in parallel.
/// Concurrent saves for the *same* name from one device otherwise surface as spurious conflicts (see Play Games snapshots).
internal actor SnapshotWritingActor {
    static let shared = SnapshotWritingActor()
    private var previousTaskByName: [String: Task<Void, Never>] = [:]

    func perform<T: Sendable>(_ uniqueName: String, operation: @escaping @Sendable () async throws -> T) async throws -> T {
        let previous = previousTaskByName[uniqueName]
        return try await withCheckedThrowingContinuation { continuation in
            let next = Task {
                if let previous {
                    await previous.value
                }
                do {
                    let value = try await operation()
                    continuation.resume(returning: value)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            previousTaskByName[uniqueName] = next
        }
    }
}

/// Class representing a saved game for the local player, or a version of a saved game when in conflict
open class GKSavedGame: NSObject/*, NSCopying */ {
    internal let snapshotMetadata: SnapshotMetadata
    /// Set only for instances built from a Play Games ``SnapshotConflict`` (see ``GKLocalPlayer/resolveConflictingSavedGames(_:with:)``).
    internal let snapshotConflict: SnapshotsClient.SnapshotConflict?

    internal init(snapshotMetadata: SnapshotMetadata, snapshotConflict: SnapshotsClient.SnapshotConflict? = nil) {
        self.snapshotMetadata = snapshotMetadata
        self.snapshotConflict = snapshotConflict
        super.init()
    }

    open var name: String? { snapshotMetadata.getUniqueName() }

    open var deviceName: String? { snapshotMetadata.getDeviceName() }

    open var modificationDate: Date? {
        let ms = snapshotMetadata.getLastModifiedTimestamp()
        return Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
    }

    @available(*, unavailable)
    open func loadData(completionHandler handler: (@Sendable (Data?, (any Error)?) -> Void)) {
        fatalError()
    }

    open func loadData() async throws -> Data {
        // While a Play Games conflict is unresolved, open(MANUAL) returns the same conflict again (see requireSnapshotAfterOpen).
        // GKSavedGame instances from SnapshotConflict.toSavedGames() carry snapshotConflict; read bytes from that branch's Snapshot.
        if let conflict = snapshotConflict {
            let myId = snapshotMetadata.getSnapshotId()
            let base: Snapshot = conflict.getSnapshot()
            let other: Snapshot = conflict.getConflictingSnapshot()
            let branch: Snapshot
            if base.getMetadata().getSnapshotId() == myId {
                branch = base
            } else if other.getMetadata().getSnapshotId() == myId {
                branch = other
            } else {
                throw GKError("Saved game metadata did not match either conflict branch")
            }
            let contents: SnapshotContents = branch.getSnapshotContents()
            let bytes = try contents.readFully()
            return Data(platformValue: bytes)
        }

        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let client: SnapshotsClient = PlayGames.getSnapshotsClient(activity)
        let task: GmsTask<SnapshotsClient.DataOrConflict<Snapshot>> = client.open(
            snapshotMetadata,
            SnapshotsClient.RESOLUTION_POLICY_MANUAL
        )
        let dataOrConflict: SnapshotsClient.DataOrConflict<Snapshot> = try await gmsTaskResult(task)
        let snapshot: Snapshot = try await GKSavedGame.requireSnapshotAfterOpen(dataOrConflict)
        let contents: SnapshotContents = snapshot.getSnapshotContents()
        let bytes = try contents.readFully()
        return Data(platformValue: bytes)
    }

    // MARK: - Internals

    /// Returns the opened snapshot, or notifies ``GKSavedGameListener`` of conflicts and throws (manual resolution required).
    internal static func requireSnapshotAfterOpen(_ dataOrConflict: SnapshotsClient.DataOrConflict<Snapshot>) async throws -> Snapshot {
        if dataOrConflict.isConflict() {
            guard let conflict: SnapshotsClient.SnapshotConflict = dataOrConflict.getConflict() else {
                throw GKError("Play Games snapshot conflict details were unavailable")
            }
            let group = conflict.toSavedGames()
            if !group.isEmpty {
                await GKLocalPlayer.local.notifySavedGameConflicts(group)
            }
            throw GKError("Saved game conflict must be resolved with resolveConflictingSavedGames(_:with:)")
        }
        guard let snapshot: Snapshot = dataOrConflict.getData() else {
            throw GKError("Play Games snapshot data was unavailable")
        }
        return snapshot
    }
}

extension SnapshotsClient.SnapshotConflict {
    /// Builds ``GKSavedGame`` list for ``GKSavedGameListener/player(_:hasConflictingSavedGames:)`` from this Play Games conflict.
    func toSavedGames() -> [GKSavedGame] {
        let conflicts: [Snapshot] = [getSnapshot(), getConflictingSnapshot()]
        return conflicts.map {
            GKSavedGame(snapshotMetadata: $0.getMetadata(), snapshotConflict: self)
        }
    }
}

extension GKLocalPlayer: GKSavedGameListener {}

extension GKLocalPlayer {

    @available(*, unavailable)
    open func fetchSavedGames(completionHandler handler: (@Sendable ([GKSavedGame]?, (any Error)?) -> Void)?) {
        fatalError()
    }

    open func fetchSavedGames() async throws -> [GKSavedGame] {
        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let client: SnapshotsClient = PlayGames.getSnapshotsClient(activity)
        let task: GmsTask<AnnotatedData<SnapshotMetadataBuffer>> = client.load(false)
        let annotated: AnnotatedData<SnapshotMetadataBuffer> = try await gmsTaskResult(task)
        let metas: [SnapshotMetadata] = try collectFrozenRowsFromAnnotatedData(annotated)
        return metas.map { GKSavedGame(snapshotMetadata: $0) }
    }

    @available(*, unavailable)
    open func saveGameData(_ data: Data, withName name: String, completionHandler handler: (@Sendable (GKSavedGame?, (any Error)?) -> Void)) {
        fatalError()
    }

    open func saveGameData(_ data: Data, withName name: String) async throws -> GKSavedGame {
        try await SnapshotWritingActor.shared.perform(name) {
            let activity: ComponentActivity = UIApplication.shared.androidActivity!
            let client: SnapshotsClient = PlayGames.getSnapshotsClient(activity)
            let openTask: GmsTask<SnapshotsClient.DataOrConflict<Snapshot>> = client.open(
                name,
                true,
                SnapshotsClient.RESOLUTION_POLICY_MANUAL
            )
            let dataOrConflict: SnapshotsClient.DataOrConflict<Snapshot> = try await gmsTaskResult(openTask)
            let snapshot: Snapshot = try await GKSavedGame.requireSnapshotAfterOpen(dataOrConflict)
            let contents: SnapshotContents = snapshot.getSnapshotContents()
            let bytes = data.platformValue
            guard contents.writeBytes(bytes) else {
                throw GKError("Failed to write saved game bytes")
            }
            let commitTask: GmsTask<SnapshotMetadata> = client.commitAndClose(snapshot, SnapshotMetadataChange.EMPTY_CHANGE)
            let committed: SnapshotMetadata = try await gmsTaskResult(commitTask)
            return GKSavedGame(snapshotMetadata: committed)
        }
    }

    @available(*, unavailable)
    open func deleteSavedGames(withName name: String, completionHandler handler: (@Sendable ((any Error)?) -> Void)) {
        fatalError()
    }

    open func deleteSavedGames(withName name: String) async throws {
        try await SnapshotWritingActor.shared.perform(name) {
            let activity: ComponentActivity = UIApplication.shared.androidActivity!
            let client: SnapshotsClient = PlayGames.getSnapshotsClient(activity)
            let all = try await fetchSavedGames()
            for game in all.filter({ $0.name == name }) {
                let delTask: GmsTask<String> = client.delete(game.snapshotMetadata)
                _ = try await gmsTaskResult(delTask)
            }
        }
    }

    @available(*, unavailable)
    open func resolveConflictingSavedGames(
        _ conflictingSavedGames: [GKSavedGame],
        with data: Data,
        completionHandler handler: (@Sendable ([GKSavedGame]?, (any Error)?) -> Void)
    ) {
        fatalError()
    }

    /// Picks the single ``SnapshotConflict`` carried on the array (same conflict id on every entry).
    private func unifiedSnapshotConflict(from games: [GKSavedGame]) throws -> SnapshotsClient.SnapshotConflict {
        guard let unified: SnapshotsClient.SnapshotConflict = games.first(where: { $0.snapshotConflict != nil })?.snapshotConflict else {
            throw GKError("Pass the GKSavedGame instances from player(_:hasConflictingSavedGames:); they carry required conflict state")
        }
        let unifiedId: String = unified.getConflictId()
        for game in games {
            guard let c: SnapshotsClient.SnapshotConflict = game.snapshotConflict else {
                throw GKError("Every conflicting save must carry conflict state from hasConflictingSavedGames")
            }
            let cid: String = c.getConflictId()
            guard cid == unifiedId else {
                throw GKError("All conflicting saves must refer to the same Play Games conflict")
            }
        }
        return unified
    }

    open func resolveConflictingSavedGames(_ conflictingSavedGames: [GKSavedGame], with data: Data) async throws -> [GKSavedGame] {
        let conflict: SnapshotsClient.SnapshotConflict = try unifiedSnapshotConflict(from: conflictingSavedGames)
        let metadata: SnapshotMetadata = conflict.getSnapshot().getMetadata()
        let snapshotId: String = metadata.getSnapshotId()
        let name: String = metadata.getUniqueName()
        
        let resolutionContents: SnapshotContents = conflict.getResolutionSnapshotContents()
        let bytes = data.platformValue
        guard resolutionContents.writeBytes(bytes) else {
            throw GKError("Failed to write merged bytes to resolution snapshot contents")
        }

        return try await SnapshotWritingActor.shared.perform(name) {
            let activity: ComponentActivity = UIApplication.shared.androidActivity!

            let client: SnapshotsClient = PlayGames.getSnapshotsClient(activity)
            let resolveTask: GmsTask<SnapshotsClient.DataOrConflict<Snapshot>> = client.resolveConflict(
                conflict.getConflictId(),
                snapshotId,
                SnapshotMetadataChange.EMPTY_CHANGE,
                resolutionContents
            )
            let dataOrConflict: SnapshotsClient.DataOrConflict<Snapshot> = try await gmsTaskResult(resolveTask)
            if dataOrConflict.isConflict() {
                guard let next: SnapshotsClient.SnapshotConflict = dataOrConflict.getConflict() else {
                    throw GKError("Play Games returned a nested conflict without details")
                }
                return next.toSavedGames()
            }
            return []
        }
    }
}

#endif
#endif
