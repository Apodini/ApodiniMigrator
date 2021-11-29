//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public class SwiftPackageFile: GeneratedFile {
    public var fileName: [NameComponent] = ["Package.swift"]

    var swiftToolsVersion: String
    var platforms: [String] = []
    var products: [PackageProduct] = []
    var dependencies: [PackageDependency] = []

    var targets: [PackageTarget] = []

    public init(swiftTools: String) {
        self.swiftToolsVersion = swiftTools
    }

    public func platform(_ platforms: String...) -> Self {
        self.platforms.append(contentsOf: platforms)
        return self
    }


    public func dependency(name: String? = nil, url: String, _ requirementString: String) -> Self {
        dependencies.append(PackageDependency(name: name, url: url, requirementString: requirementString))
        return self
    }


    public func product(library name: NameComponent..., targets: [[NameComponent]]) -> Self { // TODO double array
        products.append(PackageProduct(type: .library, name: name, targets: targets))
        return self
    }

    public func product(executable name: NameComponent..., targets: [[NameComponent]]) -> Self {
        products.append(PackageProduct(type: .executable, name: name, targets: targets))
        return self
    }

    public func product(plugin name: NameComponent..., targets: [[NameComponent]]) -> Self {
        products.append(PackageProduct(type: .plugin, name: name, targets: targets))
        return self
    }

    public var fileContent: String {
        """
        // swift-tools-version:\(swiftToolsVersion)
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
        """
        Indent {
            Joined(by: ",") {
                "name: \(GlobalPlaceholder.$packageName)"

                if !platforms.isEmpty {
                    "platforms: ["
                    Indent {
                        platforms.joined(separator: ",")
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
