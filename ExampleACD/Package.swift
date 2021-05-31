// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExampleACD",
    platforms: [
        .macOS(.v11), .iOS(.v14)
    ],
    products: [
        .library(name: "ExampleACD", targets: ["ExampleACD"])
    ],
    dependencies: [
        .package(url: "https://github.com/Apodini/ApodiniMigrator.git", .branch("apodini-model-migrator"))
    ],
    targets: [
        .target(
            name: "ExampleACD",
            dependencies: [
                .product(name: "ApodiniMigratorClientSupport", package: "ApodiniMigrator")
            ]),
        .testTarget(
            name: "ExampleACDTests",
            dependencies: ["ExampleACD"])
    ]
)
