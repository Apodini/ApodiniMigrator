// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import PackageDescription

let package = Package(
    name: "ApodiniMigrator",
    platforms: [
        .macOS(.v11),
        .iOS(.v13)
    ],
    products: [
        .library(name: "ApodiniMigratorCore", targets: ["ApodiniMigratorCore"]),
        .library(name: "RESTMigrator", targets: ["RESTMigrator"]),
        .library(name: "ApodiniMigratorShared", targets: ["ApodiniMigratorShared"]),
        .library(name: "ApodiniMigratorClientSupport", targets: ["ApodiniMigratorClientSupport"]),
        .library(name: "ApodiniMigratorCompare", targets: ["ApodiniMigratorCompare"]),
        .executable(name: "migrator", targets: ["ApodiniMigratorCLI"]),

        .executable(name: "protoc-gen-apodini-migrator", targets: ["protoc-gen-apodini-migrator"])
    ],
    dependencies: [
        .package(url: "https://github.com/Apodini/ApodiniTypeInformation.git", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.2"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/omochi/FineJSON.git", from: "1.14.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),

        // gRPC
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.18.0")
    ],
    targets: [
        /*
        .target(name: "Utils"),

        .target(name: "CodingUtils"),

        .target(name: "IOUtils"),
        */

        .target(
            name: "ApodiniMigratorCore",
            dependencies: [
                .target(name: "ApodiniMigratorShared"),
                .product(name: "ApodiniTypeInformation", package: "ApodiniTypeInformation"),
                .product(name: "Yams", package: "Yams")
            ]
        ),
        .executableTarget(
            name: "ApodiniMigratorCLI",
            dependencies: [
                .target(name: "RESTMigrator"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .executableTarget(
            name: "MigratorBoostrap",
            dependencies: [
                .target(name: "RESTMigrator"),
                .target(name: "gRPCMigrator")
            ]
        ),
        .executableTarget(
            name: "protoc-gen-apodini-migrator",
            dependencies: [
                .product(name: "SwiftProtobufPluginLibrary", package: "swift-protobuf"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),

        // Target providing any interfaces required for the Client libraries!
        .target(
            name: "ApodiniMigratorClientSupport",
            dependencies: [
                .target(name: "ApodiniMigratorCore")
            ]
        ),

        .target(
            name: "RESTMigrator",
            dependencies: [
                .target(name: "MigratorAPI"),
                .target(name: "ApodiniMigratorCompare"),
                .target(name: "ApodiniMigratorClientSupport"),
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [
                .process("Resources")
            ]
        ),

        .target(
            name: "MigratorAPI",
            dependencies: [
                .target(name: "ApodiniMigratorCompare"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),

        .target(
            name: "gRPCMigrator",
            dependencies: [
                .target(name: "MigratorAPI"),
                .product(name: "SwiftProtobufPluginLibrary", package: "swift-protobuf")
            ],
            resources: [
                .process("Resources")
            ]
        ),

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
                "RESTMigrator",
                "ApodiniMigratorCompare",
                "ApodiniMigratorClientSupport"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
