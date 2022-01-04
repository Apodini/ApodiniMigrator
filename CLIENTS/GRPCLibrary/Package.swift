// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: GRPCLibrary,
    platforms: [
        .macOS(.v12), .iOS(.v14)
    ],
    products: [
        .library(name: "GRPCLibrary", targets: ["GRPCLibrary"])
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", .exact("1.6.1-async-await.1"))
    ],
    targets: [
        .target(
            name: "_PB_GENERATED",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift")
            ]
        ),
        .target(
            name: "_PB_FACADE",
            dependencies: [
                .target(name: "_PB_GENERATED")
            ]
        ),
        .target(
            name: "_GRPC_GENERATED",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift")
            ]
        ),
        .target(
            name: "_GRPC_FACADE",
            dependencies: [
                .target(name: "_GRPC_GENERATED")
            ]
        ),
        .target(
            name: "GRPCLibrary",
            dependencies: [
                .target(name: "_PB_FACADE"),.target(name: "_GRPC_FACADE"),.product(name: "GRPC", package: "grpc-swift")
            ]
        )
    ]
)
