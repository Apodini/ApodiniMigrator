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
        .package(url: "https://github.com/Apodini/ApodiniMigrator.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/grpc/grpc-swift.git", .exact("1.4.1-async-await.3"))
    ],
    targets: [
        .target(
            name: "___PACKAGE_NAME___",
            dependencies: [
                .product(name: "ApodiniMigratorClientSupport", package: "ApodiniMigrator"),
                .product(name: "GRPC", package: "grpc-swift"),
                .target(name: "PB.SWIFT"),
                .target(name: "GRPC.SWIFT")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "PB.SWIFT",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift")
            ]
        ),
        .target(
            name: "GRPC.SWIFT",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift")
            ]
        ),
        .testTarget(
            name: "___PACKAGE_NAME___Tests",
            dependencies: ["___PACKAGE_NAME___"])
    ]
)
