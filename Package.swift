// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
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
        .library(name: "ApodiniMigratorShared", targets: ["ApodiniMigratorShared"]),
        .library(name: "ApodiniMigratorCore", targets: ["ApodiniMigratorCore"]),
        .library(name: "ApodiniMigratorClientSupport", targets: ["ApodiniMigratorClientSupport"]),
        .library(name: "ApodiniMigratorExporterSupport", targets: ["ApodiniMigratorExporterSupport"]),
        .library(name: "ApodiniMigratorCompare", targets: ["ApodiniMigratorCompare"]),
        .library(name: "ApodiniMigrator", targets: ["ApodiniMigrator"]),
        .library(name: "RESTMigrator", targets: ["RESTMigrator"]),
        .library(name: "gRPCMigrator", targets: ["gRPCMigrator"]),
        .executable(name: "migrator", targets: ["ApodiniMigratorCLI"]),
        .executable(name: "protoc-gen-grpc-migrator", targets: ["protoc-gen-grpc-migrator"])
    ],
    dependencies: [
        .package(url: "https://github.com/Apodini/MetadataSystem.git", .upToNextMinor(from: "0.1.2")),
        .package(url: "https://github.com/Apodini/ApodiniTypeInformation.git", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/omochi/FineJSON.git", from: "1.14.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),

        // gRPC
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.18.0"),

        // testing runtime crashes
        .package(url: "https://github.com/norio-nomura/XCTAssertCrash.git", from: "0.2.0")
    ],
    targets: [
        // The lowest level ApodiniMigrator package providing common API used across several targets, including
        // common file extensions, encoding and decoding strategies and output formatting
        .target(
            name: "ApodiniMigratorShared",
            dependencies: [
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "FineJSON", package: "FineJSON"),
                .product(name: "Yams", package: "Yams")
            ]
        ),

        // This target provides any necessary interfaces for Apodini exporters.
        .target(
            name: "ApodiniMigratorExporterSupport",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "ApodiniContext", package: "MetadataSystem")
            ]
        ),

        // The core ApodiniMigrator package. It provides access to the TypeInformation framework and introduces
        // the generalized API document.
        .target(
            name: "ApodiniMigratorCore",
            dependencies: [
                .target(name: "ApodiniMigratorShared"),
                .target(name: "ApodiniMigratorExporterSupport"),
                .product(name: "ApodiniTypeInformation", package: "ApodiniTypeInformation"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ]
        ),

        // This target provides any necessary interfaces for the generated client libraries!
        .target(
            name: "ApodiniMigratorClientSupport",
            dependencies: [
                .target(name: "ApodiniMigratorCore")
            ]
        ),
        // The Compare target builds upon the Core package containing the generalized MigrationGuide
        // and all the necessary utilities for the comparison algorithms.
        .target(
            name: "ApodiniMigratorCompare",
            dependencies: [
                .target(name: "ApodiniMigratorClientSupport")
            ]
        ),

        // The Migrator package provides the Migrator Interface. So everything which is required
        // to build your own Migrator. LibraryStructure generation, Source Code generation, ...
        .target(
            name: "ApodiniMigrator",
            dependencies: [
                .target(name: "ApodiniMigratorCompare"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),

        // This target packages the REST client library generator and migrator.
        // Further it contain the template files for the REST client library.
        .target(
            name: "RESTMigrator",
            dependencies: [
                .target(name: "ApodiniMigrator"),
                .target(name: "ApodiniMigratorCompare"),
                .target(name: "ApodiniMigratorClientSupport"),
                .product(name: "Logging", package: "swift-log")
            ],
            resources: [
                .process("Resources")
            ]
        ),

        // This target packages the gRPC client library generator and migrator.
        .target(
            name: "gRPCMigrator",
            dependencies: [
                .target(name: "ApodiniMigrator"),
                .product(name: "SwiftProtobufPluginLibrary", package: "swift-protobuf")
            ],
            resources: [
                .process("Resources")
            ]
        ),

        // This target implements the command line interface of the ApodiniMigrator utility.
        // It offers command to generate and migrate client libraries and a sub command
        // to compare API documents.
        .executableTarget(
            name: "ApodiniMigratorCLI",
            dependencies: [
                .target(name: "RESTMigrator"),
                .target(name: "gRPCMigrator"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),

        .executableTarget(
            name: "protoc-gen-grpc-migrator",
            dependencies: [
                .target(name: "ApodiniMigrator"),
                .product(name: "SwiftProtobufPluginLibrary", package: "swift-protobuf"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ]
        ),

        // The unified test target.
        .testTarget(
            name: "ApodiniMigratorTests",
            dependencies: [
                "ApodiniMigratorCore",
                "RESTMigrator",
                "ApodiniMigratorCompare",
                "ApodiniMigratorClientSupport",
                .product(name: "XCTAssertCrash", package: "XCTAssertCrash", condition: .when(platforms: [.macOS]))
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
