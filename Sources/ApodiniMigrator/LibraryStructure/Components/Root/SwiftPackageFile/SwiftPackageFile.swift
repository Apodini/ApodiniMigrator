//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The `Package.swift` file of a swift package.
public class SwiftPackageFile: GeneratedFile {
    public var fileName: Name = "Package.swift"

    var swiftToolsVersion: String
    var platforms: [String] = []
    var products: [PackageProduct] = []
    var dependencies: [PackageDependency] = []

    var targets: [PackageTarget] = []

    /// Initialize a new `SwiftPackageFile`.
    /// - Parameter swiftTools: The `swift-tools-version` version string used for the package file.
    public init(swiftTools: String) {
        self.swiftToolsVersion = swiftTools
    }

    /// Configure the platforms for the swift package.
    /// - Parameter platforms: The platform strings (e.g. `.macOS(.v12)`)
    /// - Returns: Returns self for chaining.
    public func platform(_ platforms: String...) -> Self {
        self.platforms.append(contentsOf: platforms)
        return self
    }

    /// Configure a dependency for the swift package.
    /// - Parameters:
    ///   - name: Optionally the name of the swift dependency.
    ///   - url: The git url to the dependency
    ///   - requirementString: The requirement string (e.g. `.branch("someBranch")`, `.upToNextMinor(from: "0.1.0")`)
    /// - Returns: Returns self for chaining.
    public func dependency(name: String? = nil, url: String, _ requirementString: String) -> Self {
        dependencies.append(PackageDependency(name: name, url: url, requirementString: requirementString))
        return self
    }


    /// Configure a library product of the swift package.
    /// - Parameters:
    ///   - name: The name of the product.
    ///   - targets: The targets which are part of the product.
    /// - Returns: Returns self for chaining.
    public func product(library name: Name, targets: Name...) -> Self {
        products.append(PackageProduct(type: .library, name: name, targets: targets))
        return self
    }

    /// Configure a executable product of the swift package.
    /// - Parameters:
    ///   - name: The name of the product.
    ///   - targets: The targets which are part of the product.
    /// - Returns: Returns self for chaining.
    public func product(executable name: Name, targets: Name...) -> Self {
        products.append(PackageProduct(type: .executable, name: name, targets: targets))
        return self
    }

    /// Configure a plugin product of the swift package.
    /// - Parameters:
    ///   - name: The name of the product.
    ///   - targets: The targets which are part of the product.
    /// - Returns: Returns self for chaining.
    public func product(plugin name: Name, targets: Name...) -> Self {
        products.append(PackageProduct(type: .plugin, name: name, targets: targets))
        return self
    }

    public var renderableContent: String {
        """
        // swift-tools-version:\(swiftToolsVersion)
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
        """
        Indent {
            Joined(by: ",") {
                "name: \"\(Placeholder.packageName)\""

                if !platforms.isEmpty {
                    "platforms: ["
                    Indent {
                        platforms.joined(separator: ", ")
                    }
                    "]"
                }

                if !products.isEmpty {
                    "products: ["
                    Indent {
                        Joined(by: ",") {
                            products
                        }
                    }
                    "]"
                }

                if !dependencies.isEmpty {
                    "dependencies: ["
                    Indent {
                        Joined(by: ",") {
                            dependencies
                        }
                    }
                    "]"
                }

                if !targets.isEmpty {
                    "targets: ["
                    Indent {
                        Joined(by: ",") {
                            targets
                        }
                    }
                    "]"
                }
            }
        }

        ")"
    }
}
