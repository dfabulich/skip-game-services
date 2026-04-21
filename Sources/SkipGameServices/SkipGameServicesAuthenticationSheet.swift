// Licensed under the Mozilla Public License 2.0
// SPDX-License-Identifier: MPL-2.0
#if !SKIP_BRIDGE
import SwiftUI

#if !SKIP
import GameKit
#endif

extension View {
    /// Installs SkipGameServices authentication UI: Game Center in a ``View/sheet`` on iOS and macOS, and automatic
    /// ``SkipGameServices/refreshAuthentication()`` when the scene becomes active. On Android, Play Games Services
    /// typically presents sign-in UI itself when needed.
    public func skipGameServicesAuthenticationSheet() -> some View {
        modifier(SkipGameServicesAuthenticationModifier())
    }
}

private struct SkipGameServicesAuthenticationModifier: ViewModifier {
    @Bindable private var gameServices = SkipGameServices.shared
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase, initial: true) { _, newPhase in
                if newPhase == .active {
                    Task {
                        _ = try? await gameServices.refreshAuthentication()
                    }
                }
            }
            #if !SKIP
            .sheet(item: $gameServices.authenticationViewControllerItem) {
                let _ = logger.debug("Presented Game Center authentication sheet")
                GameKitAuthenticationViewControllerRepresentable($0.viewController)
            }
            #endif
    }
}

#if !SKIP
#if canImport(UIKit)
import UIKit
typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
#elseif canImport(AppKit)
import AppKit
typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable
#else
#error("Unsupported platform for GameKit authentication presentation")
#endif

/// Presents the GameKit-supplied view controller from ``GKLocalPlayer/authenticateHandler`` inside SwiftUI (e.g. a ``View/sheet``).
@MainActor
public struct GameKitAuthenticationViewControllerRepresentable: PlatformViewControllerRepresentable {
    public let childViewController: PlatformViewController

    public init(_ childViewController: PlatformViewController) {
        self.childViewController = childViewController
    }

    #if canImport(UIKit)
    public func makeUIViewController(context: Context) -> UIViewController { childViewController }
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    #elseif canImport(AppKit)
    public func makeNSViewController(context: Context) -> NSViewController { childViewController }
    public func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
    #endif
}
#endif


#endif
