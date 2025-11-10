// swift-tools-version: 6.1

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
    dependencies: [],
    targets: [
        .target(
            name: "KomojuSDK",
//            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .target(
            name: "KomojuSDKUI",
            dependencies: ["KomojuSDK"],
        ),
        .testTarget(
            name: "KomojuSDKTests",
            dependencies: ["KomojuSDK"],
        ),
        .testTarget(
            name: "KomojuSDKUITests",
            dependencies: [
                "KomojuSDK",
                "KomojuSDKUI"
            ],
        ),
    ]
)
