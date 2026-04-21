// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0

#if !SKIP_BRIDGE
import Foundation
import Observation
import OSLog

#if SKIP
import SkipUI
import androidx.activity.ComponentActivity
import android.app.Activity
import android.app.Application
import com.google.android.gms.common.data.AbstractDataBuffer
import com.google.android.gms.common.data.Freezable
import com.google.android.gms.games.AnnotatedData
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
#endif
#endif

let logger: Logger = Logger(subsystem: "skip.game.services", category: "SkipGameServices")

@Observable @MainActor
public final class SkipGameServices {
    public static let shared = SkipGameServices()

    /// When `true`, ``isAuthenticated`` stays `false`, ``refreshAuthentication()`` does nothing
    public var authenticationDisabled: Bool = false {
        didSet {
            if !authenticationDisabled {
                platformAuthenticated = GKLocalPlayer.local.isAuthenticated
                Task {
                    try? await refreshAuthentication()
                }
            }
        }
    }

    private var platformAuthenticated: Bool = false

    /// Whether the user is signed in to Game Center (Apple) or Play Games Services (Android). Updated when you call ``refreshAuthentication()`` / ``authenticate()`` and (on Apple) when GameKit’s authentication handler runs. Forced to `false` while ``authenticationDisabled`` is `true`.
    public var isAuthenticated: Bool { authenticationDisabled ? false : platformAuthenticated }
    public var refreshed = false

    private init() {
        platformAuthenticated = GKLocalPlayer.local.isAuthenticated
        #if !SKIP
        startAppleAuthenticationObservation()
        #else
        ensureAndroidLifecycleCallbacksRegistered()
        #endif
    }

    #if !SKIP
    private var authenticationDidChangeObserver: NSObjectProtocol?
    #else
    private var androidLifecycleCallbacks: Application.ActivityLifecycleCallbacks?
    #endif

    public var serviceDisplayName: String {
        #if SKIP
        return "Google Play Games"
        #else
        return "Game Center"
        #endif
    }

    /// Refreshes authentication state and returns whether the user is signed in.
    public func refreshAuthentication() async throws {
        guard !authenticationDisabled else { return }
        #if SKIP
        try await androidRefreshAuthentication()
        #else
        try await appleRefreshAuthentication()
        #endif
        platformAuthenticated = GKLocalPlayer.local.isAuthenticated
    }

    /// Interactive sign-in.
    public func authenticate() async throws {
        authenticationDisabled = false
        #if SKIP
        try await androidAuthenticate()
        #else
        try await appleAuthenticate()
        #endif
        platformAuthenticated = GKLocalPlayer.local.isAuthenticated
    }
}

#if !SKIP
extension SkipGameServices {
    private func ensureAuthenticateHandlerInstalled() {
        guard GKLocalPlayer.local.authenticateHandler == nil else { return }
        // Apple never calls this with a viewController since iOS 14
        // And they don't even guarantee that it will be called at all, even if not authenticated
        // We're registering this to signal that we want to authenticate, and just logging the result
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            Task { @MainActor in
                if let self {
                    self.platformAuthenticated = GKLocalPlayer.local.isAuthenticated
                    self.refreshed = true
                }
                if let error {
                    logger.error("GameKit authenticateHandler called: self=\(self != nil), viewController=\(viewController != nil), error=[\((error as NSError).code)] \(error.localizedDescription)")
                } else {
                    logger.debug("GameKit authenticateHandler called: self=\(self != nil), viewController=\(viewController != nil), error=false")
                }
            }
        }
    }

    private func waitForRefreshIfNeeded() async {
        if refreshed { return }
        for await _ in NotificationCenter.default.notifications(
            named: NSNotification.Name.GKPlayerAuthenticationDidChangeNotificationName
        ) {
            platformAuthenticated = GKLocalPlayer.local.isAuthenticated
            refreshed = true
            return
        }
    }

    private func startAppleAuthenticationObservation() {
        guard authenticationDidChangeObserver == nil else { return }
        authenticationDidChangeObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.GKPlayerAuthenticationDidChangeNotificationName,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                logger.debug("GameKit GKPlayerAuthenticationDidChangeNotificationName isAuthenticated=\(GKLocalPlayer.local.isAuthenticated)")
                self.platformAuthenticated = GKLocalPlayer.local.isAuthenticated
                self.refreshed = true
            }
            
        }
    }

    fileprivate func appleRefreshAuthentication() async throws {
        ensureAuthenticateHandlerInstalled()
        await waitForRefreshIfNeeded()
        let isAuthenticated = GKLocalPlayer.local.isAuthenticated
        logger.info("GameKit refreshAuthentication completed: isAuthenticated=\(isAuthenticated)")
        platformAuthenticated = isAuthenticated
    }

    fileprivate func appleAuthenticate() async throws {
        if !refreshed {        
            try await appleRefreshAuthentication()
        }
        guard !GKLocalPlayer.local.isAuthenticated else {
            logger.info("GameKit appleAuthenticate skipped (already signed in): isAuthenticated=true")
            return
        }
        #if canImport(UIKit)
        await UIApplication.shared.open(URL(string: "App-prefs:root=GAMECENTER")!)
        #endif
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
                let error = ErrorException(cause: completed.getException())
                logger.error("Play Games Services task failed: \(error)")
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Play Games `AnnotatedData` + `DataBuffer` → frozen rows

/// Rows from a data buffer are only valid until ``release()``; ``freeze()`` returns entities safe to retain after the buffer is released.
internal func collectFrozenRowsFromAnnotatedData<Element, Buffer: AbstractDataBuffer<Element>>(
    _ annotated: AnnotatedData<Buffer>
) throws -> [Element] where Element: Freezable<Element> {
    guard let buffer: Buffer = annotated.get() else {
        throw GKError("Play Games buffer was nil")
    }
    defer { buffer.release() }
    let n: Int = Int(buffer.getCount())
    var out: [Element] = []
    out.reserveCapacity(n)
    for i in 0..<n {
        out.append(buffer.get(Int32(i)).freeze())
    }
    return out
}

extension SkipGameServices {
    private final class AndroidGameServicesLifecycleCallbacks: Application.ActivityLifecycleCallbacks {
        let onResumed: (Activity) -> Void

        init(onResumed: @escaping (Activity) -> Void) {
            self.onResumed = onResumed
        }

        override func onActivityResumed(activity: Activity) {
            onResumed(activity)
        }

        override func onActivityCreated(activity: Activity, savedInstanceState: android.os.Bundle?) {}
        override func onActivityStarted(activity: Activity) {}
        override func onActivityPaused(activity: Activity) {}
        override func onActivityStopped(activity: Activity) {}
        override func onActivitySaveInstanceState(activity: Activity, outState: android.os.Bundle) {}
        override func onActivityDestroyed(activity: Activity) {}
    }

    private func ensureAndroidLifecycleCallbacksRegistered() {
        guard androidLifecycleCallbacks == nil else { return }
        guard let application = UIApplication.shared.androidActivity?.application else { return }
        let callbacks = AndroidGameServicesLifecycleCallbacks { [weak self] _ in
            Task { @MainActor in
                guard let self, !self.authenticationDisabled else { return }
                try? await self.androidRefreshAuthentication()
            }
        }
        application.registerActivityLifecycleCallbacks(callbacks)
        androidLifecycleCallbacks = callbacks
    }

    private func androidRefreshAuthentication() async throws {
        ensureAndroidLifecycleCallbacksRegistered()
        guard let activity: ComponentActivity = UIApplication.shared.androidActivity else {
            logger.info("Play Games refreshAuthentication: no activity, isAuthenticated=false")
            GKLocalPlayer.applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            return
        }
        logger.debug("refreshAuthentication starting authenticationDisabled=\(authenticationDisabled)")
        do {
            try await playGamesRefreshAuthentication(activity: activity)
            logger.info("Play Games refreshAuthentication completed: isAuthenticated=\(isAuthenticated)")
        } catch {
            logger.error("Play Games refreshAuthentication failed: \(error.localizedDescription)")
            GKLocalPlayer.applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            throw error
        }
    }

    private func androidAuthenticate() async throws {
        ensureAndroidLifecycleCallbacksRegistered()
        guard let activity: ComponentActivity = UIApplication.shared.androidActivity else {
            GKLocalPlayer.applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            return
        }
        try await playGamesAuthenticate(activity: activity)
    }

    /// Play Games Services v2: suspends on Google Play `com.google.android.gms.tasks.Task` via `addOnCompleteListener` and `withCheckedThrowingContinuation`.
    private func playGamesRefreshAuthentication(activity: ComponentActivity) async throws {
        let client: GamesSignInClient = PlayGames.getGamesSignInClient(activity)
        let task: GmsTask<AuthenticationResult> = client.isAuthenticated()
        let result: AuthenticationResult = try await gmsTaskResult(task)
        try await syncGKLocalPlayerWithPlayGames(activity: activity, authResult: result)
    }

    private func playGamesAuthenticate(activity: ComponentActivity) async throws {
        let client: GamesSignInClient = PlayGames.getGamesSignInClient(activity)
        let task: GmsTask<AuthenticationResult> = client.signIn()
        let result: AuthenticationResult = try await gmsTaskResult(task)
        try await syncGKLocalPlayerWithPlayGames(activity: activity, authResult: result)
    }

    /// Fills ``GKLocalPlayer/local`` before returning so ``GKLocalPlayer/isAuthenticated`` and IDs are consistent with the auth result.
    private func syncGKLocalPlayerWithPlayGames(activity: ComponentActivity, authResult: AuthenticationResult) async throws {
        guard authResult.isAuthenticated else {
            platformAuthenticated = false
            GKLocalPlayer.applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            return
        }
        let players: PlayersClient = PlayGames.getPlayersClient(activity)
        let playerTask: GmsTask<Player> = players.getCurrentPlayer()
        do {
            let player: Player = try await gmsTaskResult(playerTask)
            platformAuthenticated = true
            GKLocalPlayer.applyPlayGamesState(isAuthenticated: true, playGamesPlayer: player)
        } catch {
            logger.error("Play Games getCurrentPlayer failed after auth: \(error.localizedDescription)")
            platformAuthenticated = false
            GKLocalPlayer.applyPlayGamesState(isAuthenticated: false, playGamesPlayer: nil)
            throw error
        }
    }
}
#endif

#endif

