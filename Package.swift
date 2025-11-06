// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "KomojuSDK",
    products: [
        .library(
            name: "KomojuSDK",
            targets: ["KomojuSDK"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.62.2")
    ],
    targets: [
        .target(
            name: "KomojuSDK",
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "KomojuSDKTests",
            dependencies: ["KomojuSDK"]
        ),
    ]
)
