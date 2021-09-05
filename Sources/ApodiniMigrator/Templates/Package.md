// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "___PACKAGE_NAME___",
    platforms: [
        .macOS(.v12), .iOS(.v14)
    ],
    products: [
            .library(name: "___PACKAGE_NAME___", targets: ["___PACKAGE_NAME___"])
    ],
    dependencies: [
            .package(url: "https://github.com/Apodini/ApodiniMigrator.git", .branch("develop"))
    ],
    targets: [
        .target(
            name: "___PACKAGE_NAME___",
            dependencies: [
                .product(name: "ApodiniMigratorClientSupport", package: "ApodiniMigrator")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "___PACKAGE_NAME___Tests",
            dependencies: ["___PACKAGE_NAME___"])
    ]
)
