// swift-tools-version:5.1

import PackageDescription

let packageName = "FixFlex"

let package = Package(
    name: packageName,
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .tvOS(.v12),
    ],
    products: [
        .library(
            name: packageName,
            targets: [packageName]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: packageName,
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: packageName + "Tests",
            dependencies: [Target.Dependency(stringLiteral: packageName)]
        ),
    ]
)
