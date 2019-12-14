// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-objdump",
    dependencies: [
        .package(url: "git@github.com:kateinoigakukun/MachOParser.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "swift-objdump",
            dependencies: ["MachOParser"]),
        .target(
            name: "SwiftRuntime",
            dependencies: []),
        .testTarget(
            name: "SwiftRuntimeTests",
            dependencies: ["SwiftRuntime"]),
    ]
)
