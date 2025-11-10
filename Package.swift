// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "KomojuSDK",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "KomojuSDK",
            targets: ["KomojuSDK"]
        ),
        .library(
            name: "KomojuSDKUI",
            targets: ["KomojuSDKUI"]
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
        .target(
            name: "KomojuSDKUI",
            dependencies: ["KomojuSDK"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "KomojuSDKTests",
            dependencies: ["KomojuSDK"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "KomojuSDKUITests",
            dependencies: [
                "KomojuSDK",
                "KomojuSDKUI"
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
    ]
)
