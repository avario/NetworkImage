// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkImage",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "NetworkImage",
            targets: ["NetworkImage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "NetworkImage",
            dependencies: ["Nuke"])
    ]
)
