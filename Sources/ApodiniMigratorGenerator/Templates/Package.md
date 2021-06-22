// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "___PACKAGE_NAME___",
    platforms: [
        .macOS(.v10_15), .iOS(.v14)
    ],
    products: [
            .library(name: "___PACKAGE_NAME___", targets: ["___PACKAGE_NAME___"])
    ],
    dependencies: [
            .package(url: "https://github.com/Apodini/ApodiniMigrator.git", .revision("6d9e708d480857ecc50e053a6770db8f5936e868"))
    ],
    targets: [
        .target(
            name: "___PACKAGE_NAME___",
            dependencies: [
                .product(name: "ApodiniMigratorClientSupport", package: "ApodiniMigrator")
            ],
            resources: [
                .process("Resources/js-convert-scripts.json"),
                .process("Resources/json-values.json")
            ]),
        .testTarget(
            name: "___PACKAGE_NAME___Tests",
            dependencies: ["___PACKAGE_NAME___"])
    ]
)
