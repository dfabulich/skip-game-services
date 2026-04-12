// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "skip-game-services",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SkipGameServices", type: .dynamic, targets: ["SkipGameServices"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.8.5"),
        .package(url: "https://source.skip.tools/skip-ui.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "SkipGameServices", dependencies: [
            .product(name: "SkipUI", package: "skip-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
        .testTarget(name: "SkipGameServicesTests", dependencies: [
            "SkipGameServices",
            .product(name: "SkipTest", package: "skip")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
