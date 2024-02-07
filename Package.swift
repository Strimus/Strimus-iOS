// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MACH-SPS",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MACH-SPS",
            targets: ["MACH-SPS"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
                url: "https://github.com/shogo4405/HaishinKit.swift",
                from: "1.5.1"
                ),
        .package(url: "https://github.com/AgoraIO/AgoraRtcEngine_iOS.git",
                 from: "4.2.1"),
        .package(url: "https://github.com/daltoniam/Starscream.git",
                 from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MACH-SPS",
            dependencies: ["AmazonIVSPlayer",
                           "AmazonIVSBroadcast",
                           .product(name: "HaishinKit", package: "HaishinKit.swift"),
                           .product(name: "RtcBasic", package: "AgoraRtcEngine_iOS")]),
        .testTarget(
            name: "MACH-SPSTests",
            dependencies: ["MACH-SPS"]),
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.18.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "1b50c62c49f2ceb6eb78c276d798fe6fdfa41b8982f8ad369eebe14bfacbdb5f"
        ),
        .binaryTarget(
            name: "AmazonIVSBroadcast",
            url: "https://broadcast.live-video.net/1.8.1/AmazonIVSBroadcast.xcframework.zip",
            checksum: "7206e7e992db10dd0b995cb14db60c2f7f97376df97c39e38fb019262d29e81d"
        )
    ]
)
