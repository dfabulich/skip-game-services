# SkipGameServices

This module provides a compatibility API corresponding to Apple's [GameKit](https://developer.apple.com/documentation/gamekit) framework, using [Google Play Games Services](https://developer.android.com/games/pgs/overview).

Currently, SkipGameServices can:
* Log the user in to Game Center/Play Games
* Report achievement progress
* Submit leaderboard scores
* Save, restore, and delete saved games

## Table of Contents

* [Setting up for Game Center / Play Games Services](#setting-up-for-game-center--play-games-services)
* [Authentication](#authentication)
    * `SkipGameServices.shared.refreshAuthentication()`
    * `SkipGameServices.shared.authenticate()`
    * `@Bindable private var gameServices = SkipGameServices.shared`
        * `gameServices.isAuthenticated`
* [Achievements](#achievements)
    * `GKAchievement.registerAchievementIdentifiers(:)` for Android/iOS compatibility
    * [`GKAchievment.report(:)`](https://developer.apple.com/documentation/gamekit/gkachievement/report(_:withcompletionhandler:))
    * [`GKAchievement.loadAchievements()`](https://developer.apple.com/documentation/gamekit/gkachievement/loadachievements(completionhandler:))
    * [`GKAchievement.loadAchievementDescriptions()`](https://developer.apple.com/documentation/gamekit/gkachievementdescription/loadachievementdescriptions(completionhandler:))
* [Leaderboards](#leaderboards)
    * `GKLeaderboard.registerLeaderboardIdentifiers(:)` for Android/iOS compatibility
    * [`GKLeaderboard.loadLeaderboards(IDs:)`](https://developer.apple.com/documentation/gamekit/gkleaderboard/loadleaderboards(ids:completionhandler:))
    * [`leaderboard.submitScore(_:context:player:)`](https://developer.apple.com/documentation/gamekit/gkleaderboard/submitscore(_:context:player:completionhandler:))
* [Displaying Achievements and Leaderboards](#displaying-achievements-and-leaderboards)
    * [`GKAccessPoint.shared.trigger(handler:)`](https://developer.apple.com/documentation/gamekit/gkaccesspoint/trigger(handler:))
* [Saved Games](#saved-games)
    * [`GKLocalPlayer.local.fetchSavedGames()`](https://developer.apple.com/documentation/gamekit/gklocalplayer/fetchsavedgames(completionhandler:))
    * [`GKLocalPlayer.local.saveGameData(_:withName:)`](https://developer.apple.com/documentation/gamekit/gklocalplayer/savegamedata(_:withname:completionhandler:))
    * Register to handle conflicts with [`GKLocalPlayer.local.register(_:)`](https://developer.apple.com/documentation/gamekit/gklocalplayer/register(_:))
        * Implement [`GKSavedGameListener`](https://developer.apple.com/documentation/gamekit/gksavedgamelistener)'s  method [`player(_:hasConflictingSavedGames:)`](https://developer.apple.com/documentation/gamekit/gksavedgamelistener/player(_:hasconflictingsavedgames:))
        * Call [`GKLocalPlayer.local.resolveConflictingSavedGames(_:with:)`](https://developer.apple.com/documentation/gamekit/gklocalplayer/resolveconflictingsavedgames(_:with:completionhandler:))



## Setting up for Game Center / Play Games Services

It can be _very_ tricky to get your app set up properly if you've never done it before. It requires finicky work in App Store Connect, in the Google Play Console, in your Xcode project settings, and in your `AndroidManifest.xml`.

There is no way to provide sample code that works "out of the box," because you'd have to set things up in the consoles first, and copy and paste ID numbers and settings to exactly the right place.

**For your first attempt at using GameKit/PGS, we recommend setting up a "Hello, World" app in a non-Skip native Swift app and a non-Skip native Kotlin app first.** Once you kinda sorta know how to use these libraries in isolation, you can use SkipGameServices to write your achievement, leaderboard, and cloud-save code once in Swift and run it on iOS and Android.

Follow the documentation here:

* [Initializing and configuring Game Center](https://developer.apple.com/documentation/gamekit/initializing-and-configuring-game-center)
    * Enable the Game Center capability in your Xcode project (this will require a registered development team in App Store Connect with provisioning set up)
    * Create a `GameCenterResources.gamekit` file defining your achievements and leaderboards
    * Configure your project scheme to "Enable Debug Mode" in the "Run Configuration" section.
    * **Launch your app on a physical device.** (No simulators allowed!)
    * Use the "Debug > GameKit > Manage Game Progress" menu to access local game progress.
* [Set up Google Play Games Services](https://developer.android.com/games/pgs/console/setup)
    * Sign in to the Google Play Console with a valid developer account
    * Create a Google Cloud Project
    * "Grow users > Play Games Services > Setup and management > Configuration" and select your Google Cloud Project
    * Fill out properties
        * Consider enabling Saved Games
    * Define achievements and leaderboards
    * Generate an OAuth 2.0 client ID
    * Enable testing
    * Add the PGS numeric application ID to your `AndroidManifest.xml` https://developer.android.com/games/pgs/android/android-signin
    * Test on a physical device or an emulator with the Google Play Store enabled
    * [Troubleshooting Play Games Services in Android games](https://developer.android.com/games/pgs/android/troubleshooting)

## Authentication

* [Authenticating a player with Game Center](https://developer.apple.com/documentation/gamekit/authenticating-a-player)
    * [`GKLocalPlayer`](https://developer.apple.com/documentation/gamekit/gklocalplayer)
* [Platform authentication for Android games](https://developer.android.com/games/pgs/android/android-signin)
    * [`GamesSignInClient`](https://developers.google.com/android/reference/com/google/android/gms/games/GamesSignInClient)

The authentication flow for both GameKit and Play Games Services is quite similar. The platform requires you to first check whether the user is authenticated, which you'd normally do at launch, via `SkipGameServices.shared.refreshAuthentication()`.

In GameKit, you use `GKLocalPlayer.local.isAuthenticated` to detect if the user is authenticated, and you can read the current user's name with `GKLocalPlayer.local.displayName`.

The `SkipGameServices.shared` object is a singleton marked `@Observable`, so you can add it to your SwiftUI/SkipUI app like this, and have your UI automatically update when `isAuthenticated` changes.

```swift
import SwiftUI
import SkipGameServices

struct ContentView: View {
    @Bindable private var gameServices = SkipGameServices.shared
    var body: some View {
        VStack {
            Text("Authenticated: \(gameServices.isAuthenticated ? "Yes" : "No")")
            if gameServices.isAuthenticated {
                Text("Hello, \(GKLocalPlayer.local.displayName)")
            } else {
                Button("Sign in") {
                    Task {
                        try? await gameServices.authenticate()
                    }
                }
            }
        }
        .task {
            try? await gameServices.refreshAuthentication()
        }
    }
}
```

When you first refresh authentication, GameKit/PGS may show a full-screen sign-in prompt. If the user dismisses the prompt, GameKit/PGS won't show it again. You can call `SkipGameServices.shared.authenticate()` to sign in after the user dismisses the prompt.

(GameKit doesn't actually offer an API to request sign in after dismissing the prompt. On iOS, `authenticate()` opens Game Center in the iOS Settings app.)

## Achievements

> [!IMPORTANT]
> Requires special configuration on Android

* [Rewarding players with achievements](https://developer.apple.com/documentation/gamekit/rewarding-players-with-achievements)
    * [`GKAchievement`](https://developer.apple.com/documentation/gamekit/gkachievement)
    * [`GKAchievementDescription`](https://developer.apple.com/documentation/gamekit/gkachievementdescription)
* [Achievements for Android games](https://developer.android.com/games/pgs/android/achievements)
    * [`AchievementsClient`](https://developers.google.com/android/reference/com/google/android/gms/games/AchievementsClient)
    * [`Achievement`](https://developers.google.com/android/reference/com/google/android/gms/games/achievement/Achievement)

### Registering Android Achievement IDs

Above and beyond just defining your achievements in the Google Play Console, there's a crucial difference between achievements on Google Play Games Services and achievemnets on App Store Connect.

App Store Connect lets you specify a logical "Achievement ID", e.g. `dragonslayer`, which becames the [`identifier`](https://developer.apple.com/documentation/gamekit/gkachievement/identifier) property of the `GKAchievement` object. In addition, you can specify a non-translated "Reference Name" (used only internally) and set the display name in any number of localizations.

Play Games Services randomly generates an ID number for every achievement, like this: `CgkI7_2_yPQFEAIQAQ`. If you want to use a logical identifier for your achievement, Google recommends adding a `strings.xml` file mapping arbitrary names to Google's randomized achievement IDs.

`SkipGameServices` provides a custom static extension method, `GKAchievement.registerAchievementIdentifiers(:)`, which you can use to register your Google Play Services opaque IDs by their logical IDs, matching iOS.

```swift
try GKAchievement.registerAchievementIdentifiers([
    "dragonslayer": "CgkI7_2_yPQFEAIQAQ",
    "flawless": "CgkIx4Hzt8oGEAIQGQ",
    "tycoon": "CgkIx4Hzt8oGEAIQCw",
])
```

### Reporting Achievement Progress

Use [`GKAchievement.report(:)`](https://developer.apple.com/documentation/gamekit/gkachievement/report(_:withcompletionhandler:)) to report achievement progress.

```swift
try GKAchievement.registerAchievementIdentifiers([
    "dragonslayer": "CgkI7_2_yPQFEAIQAQ",
])
let achievement = GKAchievement(identifier: "dragonslayer")
achievement.percentComplete = 100.0
try await GKAchievement.report([achievement])
```

### Loading and Displaying Achievements

Use [`GKAchievemnt.loadAchievements()`](https://developer.apple.com/documentation/gamekit/gkachievement/loadachievements(completionhandler:)) to load achievements, like this:

```swift
import SwiftUI
import SkipGameServices

struct ContentView: View {
    @Bindable private var gameServices = SkipGameServices.shared
    @State private var isLoading = true
    @State private var achievements: [GKAchievement] = []
    @State private var achievementDescriptions: [String: GKAchievementDescription] = [:]

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                if isLoading {
                    ProgressView()
                } else if achievements.isEmpty {
                    Text("No achievements loaded")
                } else {
                    ForEach(achievements, id: \.identifier) { achievement in
                        Text(achievementDescriptions[achievement.identifier]!.title)
                    }
                }
            }
        }
        .task {
            try? await gameServices.refreshAuthentication()
        }
        .onChange(of: gameServices.isAuthenticated, initial: true) {
            isLoading = true
            defer { isLoading = false }
            try GKAchievement.registerAchievementIdentifiers([
                "dragonslayer": "CgkI7_2_yPQFEAIQAQ",
            ])
            async let achievementsPromise = try await GKAchievement.loadAchievements()
            async let descriptionsPromise = try await GKAchievementDescription.loadAchievementDescriptions()
            achievements = try? await achievementsPromise ?? []
            for description in try? await descriptionsPromise ?? [] {
                achievementDescription[description.identifier] = description
            }
        }
    }
}
```

## Leaderboards

> [!IMPORTANT]
> Requires special configuration on Android

* [Encourage progress and competition with leaderboards](https://developer.apple.com/documentation/gamekit/encourage-progress-and-competition-with-leaderboards)
    * [`GKLeaderboard`](https://developer.apple.com/documentation/gamekit/gkleaderboard)
    * [`GKLeaderboardScore`](https://developer.apple.com/documentation/gamekit/gkleaderboardscore)
        * Deprecated, unsupported in `SkipGameServices`: [`GKScore`](https://developer.apple.com/documentation/gamekit/gkscore)
* [Leaderboards in Android games](https://developer.android.com/games/pgs/android/leaderboards)
    * [`LeaderboardsClient`](https://developers.google.com/android/reference/com/google/android/gms/games/LeaderboardsClient)
    * [`Leaderboard`](https://developers.google.com/android/games_v1/reference/com/google/android/gms/games/leaderboard/Leaderboard)
    * [`LeaderboardScore`](https://developers.google.com/android/games_v1/reference/com/google/android/gms/games/leaderboard/LeaderboardScore)

Like achievements, leaderboard identifiers differ between App Store Connect and Play Games Services.

On iOS, you use your logical leaderboard ID (for example, `highscore`) when calling `GKLeaderboard` APIs.
On Android, Play Games uses randomized opaque IDs like `CgkI7_2_yPQFEAIQAg`.

To use the same logical IDs on both platforms, register a mapping before loading leaderboards or submitting leaderboard scores:

```swift
try GKLeaderboard.registerLeaderboardIdentifiers([
    "highscore": "CgkI7_2_yPQFEAIQAg",
])

let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: ["highscore"])
if let leaderboard = leaderboards.first {
    try await leaderboard.submitScore(12_345, context: 0, player: GKLocalPlayer.local)
}
```

## Displaying Achievements and Leaderboards

* [Adding an access point to your game](https://developer.apple.com/documentation/gamekit/adding-an-access-point-to-your-game)
    * [`GKAccessPoint`](https://developer.apple.com/documentation/gamekit/gkaccesspoint)
    * Deprecated, unsupported in `SkipGameServices`: [Displaying the Game Center dashboard](https://developer.apple.com/documentation/gamekit/displaying-the-game-center-dashboard)
        * [`GKGameCenterViewController`](https://developer.apple.com/documentation/gamekit/gkgamecenterviewcontroller) (uses UIKit, which doesn't work in SkipUI)
* Play Games Services
    * [Display Achievements](https://developer.android.com/games/pgs/android/achievements#display_achievements)
        * [`AchievementsClient.getAchievementsIntent()`](https://developers.google.com/android/reference/com/google/android/gms/games/AchievementsClient#public-abstract-taskintent-getachievementsintent)
    * [Display a leaderboard](https://developer.android.com/games/pgs/android/leaderboards#display-leaderboard)
        * [`LeaderboardsClient.getLeaderboardIntent()`](https://developers.google.com/android/reference/com/google/android/gms/games/LeaderboardsClient#getLeaderboardIntent(java.lang.String))

```swift
// The GKAccessPoint.trigger() function accepts a non-optional `handler:` callback
// (You probably just want to leave it blank)
GKAccessPoint.shared.trigger(.achievements) {}
GKAccessPoint.shared.trigger(.leaderboards) {}

// This API requires you to call GKLeaderboard.registerLeaderboardIdentifiers() first
GKAccessPoint.shared.trigger(
    leaderboardID: "highscore",
    playerScope: .global, // or .friendsOnly
    timeScope: .allTime // or .today, or .week
) {}
```

## Saved Games

* [Saving the player’s game data to an iCloud account](https://developer.apple.com/documentation/gamekit/saving-the-player-s-game-data-to-an-icloud-account)
    * [`GKSavedGame`](https://developer.apple.com/documentation/gamekit/gksavedgame)
    * [`GKSavedGameListener`](https://developer.apple.com/documentation/gamekit/gksavedgamelistener)
* [Cloud save](https://developer.android.com/games/pgs/savedgames)
    * [`SnapshotsClient`](https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient)
        * [`DataOrConflict`](https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient.DataOrConflict)
        * [`SnapshotConflict`](https://developers.google.com/android/reference/com/google/android/gms/games/SnapshotsClient.SnapshotConflict)
    * [`Snapshot`](https://developers.google.com/android/games_v1/reference/com/google/android/gms/games/snapshot/Snapshot)
    * [`SnapshotMetadata`](https://developers.google.com/android/games_v1/reference/com/google/android/gms/games/snapshot/SnapshotMetadata)
    * [`SnapshotContents`](https://developers.google.com/android/games_v1/reference/com/google/android/gms/games/snapshot/SnapshotContents)

Load saved games with [`GKLocalPlayer.local.fetchSavedGames()`](https://developer.apple.com/documentation/gamekit/gklocalplayer/fetchsavedgames(completionhandler:)).

```swift
import SwiftUI
import SkipGameServices

struct ContentView: View {
    @Bindable private var gameServices = SkipGameServices.shared
    @State private var isLoading = true
    @State private var savedGames: [GKSavedGame] = []

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if savedGames.isEmpty {
                Text("No saved games loaded")
            } else {
                List(savedGames, id: \.name) { savedGame in
                    Text(savedGame.name!)
                }
            }
        }
        .task {
            try? await gameServices.refreshAuthentication()
        }
        .onChange(of: gameServices.isAuthenticated, initial: true) {
            isLoading = true
            defer { isLoading = false }
            savedGames = try? await GKLocalPlayer.local.fetchSavedGames() ?? []
        }
    }
}
```

Save a game by name with [`GKLocalPlayer.local.saveGameData(_:withName:)`](https://developer.apple.com/documentation/gamekit/gklocalplayer/savegamedata(_:withname:completionhandler:)).

```swift
let data = Data("example".utf8)
try await GKLocalPlayer.local.saveGameData(data, withName: "test")
```

Register to handle save conflicts.

```swift
class MySaveConflictListener: GKSavedGameListener {
    func player( _ player: GKPlayer, hasConflictingSavedGames savedGames: [GKSavedGame]) {
        Task {
            guard let data = try? await savedGames.first?.loadData() else { return }
            try? await GKLocalPlayer.local.resolveConflictingSaves(savedGames, with: data)
        }
    }
}
listener = MySaveConflictListener()
GKLocalPlayer.local.register(listener)
```

## Building

This project is a Swift Package Manager module that uses the
[Skip](https://skip.dev) plugin to build the package for both iOS and Android.

## Testing

The module can be tested using the standard `swift test` command
or by running the test target for the macOS destination in Xcode,
which will run the Swift tests as well as the transpiled
Kotlin JUnit tests in the Robolectric Android simulation environment.

Parity testing can be performed with `skip test`,
which will output a table of the test results for both platforms.

## License

This software is licensed under the
[Mozilla Public License 2.0](https://www.mozilla.org/MPL/).
