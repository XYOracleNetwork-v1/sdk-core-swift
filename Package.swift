// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sdk-core-swift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "sdk-core-swift",
            targets: ["sdk-core-swift"])
    ],
    dependencies: [
        .package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "sdk-core-swift",
            dependencies: ["secp256k1"])
        .testTarget(
            name: "sdk-core-swiftTests",
            dependencies: ["sdk-core-swift"])
    ]
)
