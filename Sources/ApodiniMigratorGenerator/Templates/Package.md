// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "___PACKAGE_NAME___",
    platforms: [
        .macOS(.v11), .iOS(.v14)
    ],
    products: [
            .library(name: "___PACKAGE_NAME___", targets: ["___PACKAGE_NAME___"])
    ],
    dependencies: [
            .package(url: "https://github.com/Apodini/ApodiniMigrator.git", .branch("apodini-model-migrator"))
    ],
    targets: [
        .target(
            name: "___PACKAGE_NAME___",
            dependencies: [
                .product(name: "ApodiniMigratorClientSupport", package: "ApodiniMigrator")
            ]),
        .testTarget(
            name: "___PACKAGE_NAME___Tests",
            dependencies: ["___PACKAGE_NAME___"])
    ]
)
