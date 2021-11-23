//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public class SwiftPackageFile: GeneratedFile {
    public var fileName: [NameComponent] = ["Package.swift"]

    var swiftToolsVersion: String
    // TODO platforms!
    var products: [PackageProduct] = []
    var dependencies: [PackageDependency] = []

    var targets: [PackageTarget] = []

    public init(swiftTools: String) {
        self.swiftToolsVersion = swiftTools
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

    public func render(with context: MigrationContext) -> String {
        // TODO multine products/dependencies/targets don't respect indent rules!
        """
        // swift-tools-version:\(swiftToolsVersion)
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        let package = Package(
            name: "\(context.placeholderValues[GlobalPlaceholder.$packageName] ?? "ERROR")",
            platforms: [
                .macOS(.v12), .iOS(.v14)
            ],
            products: [
                \(products.map { $0.description(with: context) }.joined(separator: ",\n        "))
            ],
            dependencies: [
                \(dependencies.map { $0.description }.joined(separator: ",\n        "))
            ],
            targets: [
                \(targets.map { $0.description(with: context) }.joined(separator: ",\n        "))
            ]
        )

        """
    }
}
