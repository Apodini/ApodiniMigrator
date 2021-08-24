// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApodiniMigrator",
    platforms: [
        .macOS(.v10_15), .iOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "ApodiniMigratorCore", targets: ["ApodiniMigratorCore"]),
        .library(name: "ApodiniMigrator", targets: ["ApodiniMigrator"]),
        .library(name: "ApodiniMigratorShared", targets: ["ApodiniMigratorShared"]),
        .library(name: "ApodiniMigratorClientSupport", targets: ["ApodiniMigratorClientSupport"]),
        .library(name: "ApodiniMigratorCompare", targets: ["ApodiniMigratorCompare"]),
        .executable(name: "migrator", targets: ["ApodiniMigratorCLI"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Apodini/ApodiniTypeInformation.git", .upToNextMinor(from: "0.1.1")),
        .package(url: "https://github.com/kylef/PathKit.git", .exact("0.9.2")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/omochi/FineJSON.git", .exact("1.14.0")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ApodiniMigratorCore",
            dependencies: [
                .target(name: "ApodiniMigratorShared"),
                .product(name: "ApodiniTypeInformation", package: "ApodiniTypeInformation"),
                .product(name: "Yams", package: "Yams")
            ]),
        .executableTarget(
            name: "ApodiniMigratorCLI",
            dependencies: [
                .target(name: "ApodiniMigrator"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(
            name: "ApodiniMigratorClientSupport",
            dependencies: [
                .target(name: "ApodiniMigratorCore")
            ]),
        .target(
            name: "ApodiniMigrator",
            dependencies: [
                .target(name: "ApodiniMigratorCompare"),
                .target(name: "ApodiniMigratorClientSupport"),
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [
                .process("Templates")
            ]),
        .target(
            name: "ApodiniMigratorShared",
            dependencies: [
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "FineJSON", package: "FineJSON"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        
        .target(
            name: "ApodiniMigratorCompare",
            dependencies: [
                .target(name: "ApodiniMigratorClientSupport")
            ]
        ),
        .testTarget(
            name: "ApodiniMigratorTests",
            dependencies: [
                "ApodiniMigratorCore",
                "ApodiniMigrator",
                "ApodiniMigratorCompare",
                "ApodiniMigratorClientSupport"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
