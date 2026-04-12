// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
import Foundation
import Observation
import OSLog

#if SKIP
import SkipUI
import androidx.activity.ComponentActivity
import com.google.android.gms.games.PlayGames
import com.google.android.gms.games.GamesSignInClient
import com.google.android.gms.games.AuthenticationResult
import com.google.android.gms.games.Player
import com.google.android.gms.games.PlayersClient
#endif

#if !SKIP
@_exported import GameKit
#if canImport(UIKit)
import UIKit
public typealias PlatformViewController = UIViewController
#elseif canImport(AppKit)
import AppKit
public typealias PlatformViewController = NSViewController
#endif
#endif

let logger: Logger = Logger(subsystem: "skip.game.services", category: "SkipGameServices")

@Observable @MainActor
public final class SkipGameServices {
    public static let shared = SkipGameServices()

    /// Whether the user is signed in to Game Center (Apple) or Play Games Services (Android). Updated when you call ``refreshAuthentication()`` / ``authenticate()`` and (on Apple) when GameKit’s authentication handler runs.
    public private(set) var isAuthenticated: Bool = false

    private init() {
        isAuthenticated = GKLocalPlayer.local.isAuthenticated
    }

    #if !SKIP
    /// View controller from the latest ``GKLocalPlayer`` `authenticateHandler` callback
    public private(set) var authenticationViewController: PlatformViewController?

    /// Increments when ``authenticate()`` requests interactive presentation; used to re-open the Game Center sheet.
    public private(set) var interactivePresentationGeneration: Int = 0

    private var authenticateHandlerInstalled = false
    private var pendingRefreshContinuation: CheckedContinuation<Bool, any Error>?
    private var inFlightRefresh: Task<Bool, any Error>?
    #endif

    /// Refreshes authentication state and returns whether the user is signed in.
    public func refreshAuthentication() async throws -> Bool {
        let signedIn: Bool
        #if SKIP
        signedIn = try await androidRefreshAuthentication()
        #else
        signedIn = try await appleRefreshAuthentication()
        #endif
        isAuthenticated = GKLocalPlayer.local.isAuthenticated
        return signedIn
    }

    /// Interactive sign-in.
    public func authenticate() async throws {
        #if SKIP
        try await androidAuthenticate()
        #else
        try await appleAuthenticate()
        #endif
        isAuthenticated = GKLocalPlayer.local.isAuthenticated
    }
}

#if !SKIP
extension SkipGameServices {
    private func ensureAuthenticateHandlerInstalled() {
        guard !authenticateHandlerInstalled else { return }
        authenticateHandlerInstalled = true
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                guard let self else { return }
                self.authenticationViewController = viewController
                defer { self.isAuthenticated = GKLocalPlayer.local.isAuthenticated }
                guard let continuation = self.pendingRefreshContinuation else { return }
                self.pendingRefreshContinuation = nil
                if let error {
                    logger.error("GameKit authenticateHandler failed: \(error.localizedDescription, privacy: .public)")
                    continuation.resume(throwing: error)
                    return
                }
                if viewController != nil {
                    self.interactivePresentationGeneration &+= 1
                }
                let isAuthenticated = GKLocalPlayer.local.isAuthenticated
                logger.info("GameKit refreshAuthentication completed: isAuthenticated=\(isAuthenticated)")
                continuation.resume(returning: isAuthenticated)
            }
        }
    }

    fileprivate func appleRefreshAuthentication() async throws -> Bool {
        guard !GKLocalPlayer.local.isAuthenticated else {
            logger.info("GameKit refreshAuthentication skipped (already signed in): isAuthenticated=true")
            return true
        }
        if let inFlightRefresh {
            return try await inFlightRefresh.value
        }
        let task = Task { @MainActor in
            try await withCheckedThrowingContinuation { continuation in
                self.pendingRefreshContinuation = continuation
                self.ensureAuthenticateHandlerInstalled()
            }
        }
        inFlightRefresh = task
        defer { inFlightRefresh = nil }
        return try await task.value
    }

    fileprivate func appleAuthenticate() async throws {
        interactivePresentationGeneration &+= 1
    }
}
#else

typealias GmsTask<T> = com.google.android.gms.tasks.Task<T>
/// Play Games Services: suspends on `com.google.android.gms.tasks.Task` via `addOnCompleteListener` and `withCheckedThrowingContinuation`.
internal func gmsTaskResult<T>(_ task: GmsTask<T>) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
        task.addOnCompleteListener { completed in
            if completed.isSuccessful {
                continuation.resume(returning: completed.getResult())
            } else {
                continuation.resume(throwing: ErrorException(cause: completed.getException()))
            }
        }
    }
}

extension SkipGameServices {
    private func androidRefreshAuthentication() async throws -> Bool {
        guard let activity: ComponentActivity = UIApplication.shared.androidActivity else {
            logger.info("Play Games refreshAuthentication: no activity, isAuthenticated=false")
            GKLocalPlayer._skip_applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            return false
        }
        do {
            let authed = try await playGamesRefreshAuthentication(activity: activity)
            logger.info("Play Games refreshAuthentication completed: isAuthenticated=\(authed)")
            return authed
        } catch {
            logger.error("Play Games refreshAuthentication failed: \(error.localizedDescription)")
            GKLocalPlayer._skip_applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            return false
        }
    }

    private func androidAuthenticate() async throws {
        guard let activity: ComponentActivity = UIApplication.shared.androidActivity else {
            GKLocalPlayer._skip_applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            return
        }
        _ = (try? await playGamesAuthenticate(activity: activity)) ?? false
    }

    /// Play Games Services v2: suspends on Google Play `com.google.android.gms.tasks.Task` via `addOnCompleteListener` and `withCheckedThrowingContinuation`.
    private func playGamesRefreshAuthentication(activity: ComponentActivity) async throws -> Bool {
        let client: GamesSignInClient = PlayGames.getGamesSignInClient(activity)
        let task: GmsTask<AuthenticationResult> = client.isAuthenticated()
        let result: AuthenticationResult = try await gmsTaskResult(task)
        return await syncGKLocalPlayerWithPlayGames(activity: activity, authResult: result)
    }

    private func playGamesAuthenticate(activity: ComponentActivity) async throws -> Bool {
        let client: GamesSignInClient = PlayGames.getGamesSignInClient(activity)
        let task: GmsTask<AuthenticationResult> = client.signIn()
        let result: AuthenticationResult = try await gmsTaskResult(task)
        return await syncGKLocalPlayerWithPlayGames(activity: activity, authResult: result)
    }

    /// Fills ``GKLocalPlayer/local`` before returning so ``GKLocalPlayer/isAuthenticated`` and IDs are consistent with the auth result.
    private func syncGKLocalPlayerWithPlayGames(activity: ComponentActivity, authResult: AuthenticationResult) async -> Bool {
        if !authResult.isAuthenticated {
            GKLocalPlayer._skip_applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            return false
        }
        let players: PlayersClient = PlayGames.getPlayersClient(activity)
        let playerTask: GmsTask<Player> = players.getCurrentPlayer()
        do {
            let player: Player = try await gmsTaskResult(playerTask)
            GKLocalPlayer._skip_applyPlayGamesState(isAuthenticated: true, playGamesPlayer: player)
            return true
        } catch {
            logger.error("Play Games getCurrentPlayer failed after auth: \(error.localizedDescription, privacy: .public)")
            GKLocalPlayer._skip_applyPlayGamesState(isAuthenticated: true, playGamesPlayer: nil)
            return true
        }
    }
}
#endif

#endif