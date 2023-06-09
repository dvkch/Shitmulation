// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shitmulation",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "Shitmulation",
            targets: ["Shitmulation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
    ],
    targets: [
        .executableTarget(
            name: "Shitmulation",
            dependencies: [
                "ShitmulationC",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "ShitmulationC",
            dependencies: []
        ),
        .testTarget(
            name: "ShitmulationTests",
            dependencies: ["Shitmulation", "ShitmulationC"]),
    ]
)
