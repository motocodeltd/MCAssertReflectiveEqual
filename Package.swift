// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCAssertReflectiveEqual",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_10),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "MCAssertReflectiveEqual",
            targets: ["MCAssertReflectiveEqual"]
        ),
    ],
    dependencies: [
        // No external dependencies
    ],
    targets: [
        .target(
            name: "MCAssertReflectiveEqual",
            dependencies: [],
            path: "MCAssertReflectiveEqual/Classes"
        ),
        .testTarget(
            name: "MCAssertReflectiveEqualTests",
            dependencies: ["MCAssertReflectiveEqual"],
            path: "Tests"
        ),
    ]
)