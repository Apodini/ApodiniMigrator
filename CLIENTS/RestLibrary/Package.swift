// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: RestLibrary,
    platforms: [
        .macOS(.v12), .iOS(.v14)
    ],
    products: [
        .library(name: "RestLibrary", targets: ["RestLibrary"])
    ],
    dependencies: [
        .package(url: "https://github.com/Apodini/ApodiniMigrator.git", .upToNextMinor(from: "0.1.0"))
    ],
    targets: [
        .target(
            name: "RestLibrary",
            dependencies: [
                .product(name: "ApodiniMigratorClientSupport", package: "ApodiniMigrator")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "RestLibraryTests",
            dependencies: [
                .target(name: "RestLibrary")
            ]
        )
    ]
)
