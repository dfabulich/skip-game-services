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

/// Class representing a saved game for the local player, or a version of a saved game when in conflict
open class GKSavedGame: NSObject/*, NSCopying */ {
    internal let _skip_metadata: SnapshotMetadata
    /// Set only for instances built from a Play Games ``SnapshotConflict`` (see ``GKLocalPlayer/resolveConflictingSavedGames(_:with:)``).
    internal let _skip_snapshotConflict: SnapshotsClient.SnapshotConflict?

    internal init(snapshotMetadata: SnapshotMetadata, snapshotConflict: SnapshotsClient.SnapshotConflict? = nil) {
        self._skip_metadata = snapshotMetadata
        self._skip_snapshotConflict = snapshotConflict
        super.init()
    }

    open var name: String? { _skip_metadata.getUniqueName() }

    open var deviceName: String? { _skip_metadata.getDeviceName() }

    open var modificationDate: Date? {
        let ms = _skip_metadata.getLastModifiedTimestamp()
        return Date(timeIntervalSince1970: TimeInterval(ms) / 1000.0)
    }

    @available(*, unavailable)
    open func loadData(completionHandler handler: (@Sendable (Data?, (any Error)?) -> Void)? = nil) {
        fatalError()
    }

    open func loadData() async throws -> Data {
        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let client: SnapshotsClient = PlayGames.getSnapshotsClient(activity)
        let task: GmsTask<SnapshotsClient.DataOrConflict<Snapshot>> = client.open(
            _skip_metadata,
            SnapshotsClient.RESOLUTION_POLICY_MANUAL
        )
        let dataOrConflict: SnapshotsClient.DataOrConflict<Snapshot> = try await gmsTaskResult(task)
        let snapshot: Snapshot = try await GKSavedGame._skip_requireSnapshotAfterOpen(dataOrConflict)
        let contents: SnapshotContents = snapshot.getSnapshotContents()
        let bytes = try contents.readFully()
        return Data(platformValue: bytes)
    }

    // MARK: - Internals

    /// Returns the opened snapshot, or notifies ``GKSavedGameListener`` of conflicts and throws (manual resolution required).
    internal static func _skip_requireSnapshotAfterOpen(_ dataOrConflict: SnapshotsClient.DataOrConflict<Snapshot>) async throws -> Snapshot {
        if dataOrConflict.isConflict() {
            guard let conflict: SnapshotsClient.SnapshotConflict = dataOrConflict.getConflict() else {
                throw GKError("Play Games snapshot conflict details were unavailable")
            }
            let group = conflict.toSavedGames()
            if !group.isEmpty {
                await GKLocalPlayer.local._skip_notifySavedGameConflicts(group)
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
        guard let buffer: SnapshotMetadataBuffer = annotated.get() else {
            throw GKError("Play Games saved game list was unavailable")
        }
        defer { buffer.release() }
        let count = Int(buffer.getCount())
        var out: [GKSavedGame] = []
        for i in 0..<count {
            let meta: SnapshotMetadata = buffer.get(Int32(i))
            out.append(GKSavedGame(snapshotMetadata: meta))
        }
        return out
    }

    @available(*, unavailable)
    open func saveGameData(_ data: Data, withName name: String, completionHandler handler: (@Sendable (GKSavedGame?, (any Error)?) -> Void)? = nil) {
        fatalError()
    }

    open func saveGameData(_ data: Data, withName name: String) async throws -> GKSavedGame {
        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let client: SnapshotsClient = PlayGames.getSnapshotsClient(activity)
        let openTask: GmsTask<SnapshotsClient.DataOrConflict<Snapshot>> = client.open(
            name,
            true,
            SnapshotsClient.RESOLUTION_POLICY_MANUAL
        )
        let dataOrConflict: SnapshotsClient.DataOrConflict<Snapshot> = try await gmsTaskResult(openTask)
        let snapshot: Snapshot = try await GKSavedGame._skip_requireSnapshotAfterOpen(dataOrConflict)
        let contents: SnapshotContents = snapshot.getSnapshotContents()
        let bytes = data.platformValue
        guard contents.writeBytes(bytes) else {
            throw GKError("Failed to write saved game bytes")
        }
        let commitTask: GmsTask<SnapshotMetadata> = client.commitAndClose(snapshot, SnapshotMetadataChange.EMPTY_CHANGE)
        let committed: SnapshotMetadata = try await gmsTaskResult(commitTask)
        return GKSavedGame(snapshotMetadata: committed)
    }

    @available(*, unavailable)
    open func deleteSavedGames(withName name: String, completionHandler handler: (@Sendable ((any Error)?) -> Void)? = nil) {
        fatalError()
    }

    open func deleteSavedGames(withName name: String) async throws {
        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let client: SnapshotsClient = PlayGames.getSnapshotsClient(activity)
        let all = try await fetchSavedGames()
        for game in all.filter({ $0.name == name }) {
            let delTask: GmsTask<String> = client.delete(game._skip_metadata)
            _ = try await gmsTaskResult(delTask)
        }
    }

    @available(*, unavailable)
    open func resolveConflictingSavedGames(
        _ conflictingSavedGames: [GKSavedGame],
        with data: Data,
        completionHandler handler: (@Sendable ([GKSavedGame]?, (any Error)?) -> Void)? = nil
    ) {
        fatalError()
    }

    /// Picks the single ``SnapshotConflict`` carried on the array (same conflict id on every entry).
    private func _skip_unifiedSnapshotConflict(from games: [GKSavedGame]) throws -> SnapshotsClient.SnapshotConflict {
        guard let unified: SnapshotsClient.SnapshotConflict = games.first(where: { $0._skip_snapshotConflict != nil })?._skip_snapshotConflict else {
            throw GKError("Pass the GKSavedGame instances from player(_:hasConflictingSavedGames:); they carry required conflict state")
        }
        let unifiedId: String = unified.getConflictId()
        for game in games {
            guard let c: SnapshotsClient.SnapshotConflict = game._skip_snapshotConflict else {
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
        let activity: ComponentActivity = UIApplication.shared.androidActivity!
        let conflict: SnapshotsClient.SnapshotConflict = try _skip_unifiedSnapshotConflict(from: conflictingSavedGames)

        let resolutionContents: SnapshotContents = conflict.getResolutionSnapshotContents()
        let bytes = data.platformValue
        guard resolutionContents.writeBytes(bytes) else {
            throw GKError("Failed to write merged bytes to resolution snapshot contents")
        }

        guard let snapshotId: String = conflict.getSnapshot().getMetadata().getSnapshotId() else {
            throw GKError("Play Games server snapshot id was unavailable")
        }

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

#endif
#endif
