//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

struct PackageTarget {
    let type: TargetType
    let name: String
    let dependencies: [TargetDependency]
    let resources: [TargetResource]
}

extension PackageTarget {
    func description(with context: MigrationContext) -> String { // TODO fix ident
        """
        .\(type.rawValue)(
                    name: \"\(name)\",
                    resources: [
                        \(resources.map({ $0.description(with: context) }).joined(separator: ",\n        "))
                    ],
                    dependencies: [
                        \(dependencies.map({ $0.description(with: context) }).joined(separator: ",\n         "))
                    ]
                )
        """
    }
}

extension TargetDirectory {
    func targetDescription(with context: MigrationContext) -> PackageTarget {
        PackageTarget(type: type, name: path.description(with: context), dependencies: dependencies, resources: resources)
    }
}


public enum TargetType: String {
    case test = "testTarget"
    case regular = "target"
    case executable = "executableTarget"
}

public protocol TargetDependency {
    func description(with context: MigrationContext) -> String
}

struct LocalDependency: TargetDependency {
    func description(with context: MigrationContext) -> String {
        """
        .target(name: \"\(target.description(with: context))\")
        """
    }

    let target: [NameComponent]
}

struct ProductDependency: TargetDependency {
    func description(with context: MigrationContext) -> String {
        """
        .product(name: \"\(product.description(with: context))\", package: \"\(package.description(with: context))\")
        """
    }

    let product: [NameComponent]
    let package: [NameComponent]
}


public enum ResourceType: String {
    case process
    case copy
}

public struct TargetResource {
    let type: ResourceType
    let path: [NameComponent]
}

extension TargetResource {
    func description(with context: MigrationContext) -> String {
        """
        .\(type.rawValue)(\"\(path.description(with: context))\")
        """
    }
}