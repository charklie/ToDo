// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "todo",
    dependencies: [
        .package(
            url: "https://github.com/JanGorman/Table",
            from: "1.0.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "todo",
            dependencies: ["Table"])
    ]
)
