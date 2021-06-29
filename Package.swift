// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let enumSupport = false
let runtime: Package.Dependency = enumSupport
    ? .package(url: "https://github.com/PSchmiedmayer/Runtime.git", .revision("b810847a466ecd1cf65e7f39e6e715734fdc672c"))
    : .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.2.2")

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
        runtime,
        .package(url: "https://github.com/kylef/PathKit.git", .exact("0.9.2")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/omochi/FineJSON.git", .exact("1.14.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ApodiniMigratorCore",
            dependencies: [
                .target(name: "ApodiniMigratorShared"),
                .product(name: "Runtime", package: "Runtime")
            ]),
        .target(
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
                .process("Templates/Package.md"),
                .process("Templates/Readme.md"),
                .process("Templates/HTTP/ApodiniError.md"),
                .process("Templates/HTTP/HTTPAuthorization.md"),
                .process("Templates/HTTP/HTTPHeaders.md"),
                .process("Templates/HTTP/HTTPMethod.md"),
                .process("Templates/HTTP/Parameters.md"),
                .process("Templates/Networking/Handler.md"),
                .process("Templates/Networking/NetworkingService.md"),
                .process("Templates/Utils/Utils.md"),
                .process("Templates/Tests/TestFile.md"),
                .process("Templates/Tests/XCTestManifests.md"),
                .process("Templates/Tests/LinuxMain.md")
            ]),
        .target(
            name: "ApodiniMigratorShared",
            dependencies: [
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "FineJSON", package: "FineJSON")
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
            ])
    ]
)
