// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ApodiniMigrator",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "ApodiniMigrator", targets: ["ApodiniMigrator"]),
        .library(name: "ApodiniMigratorGenerator", targets: ["ApodiniMigratorGenerator"]),
        .library(name: "ApodiniMigratorShared", targets: ["ApodiniMigratorShared"]),
        .library(name: "ApodiniMigratorClientSupport", targets: ["ApodiniMigratorClientSupport"]),
        .library(name: "ApodiniMigratorCompare", targets: ["ApodiniMigratorCompare"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.2.2"),
        .package(url: "https://github.com/kylef/PathKit.git", .exact("0.9.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ApodiniMigrator",
            dependencies: [
                .target(name: "ApodiniMigratorShared"),
                .product(name: "Runtime", package: "Runtime")
            ]),
        .target(
            name: "ApodiniMigratorClientSupport",
            dependencies: [
                .target(name: "ApodiniMigrator")
            ]),
        .target(
            name: "ApodiniMigratorGenerator",
            dependencies: [
                .target(name: "ApodiniMigrator")
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
                .product(name: "PathKit", package: "PathKit")
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
                "ApodiniMigrator",
                "ApodiniMigratorGenerator",
                "ApodiniMigratorCompare",
                "ApodiniMigratorClientSupport"
            ])
    ]
)
