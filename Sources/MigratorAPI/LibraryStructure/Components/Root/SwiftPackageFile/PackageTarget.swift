//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

struct PackageTarget: SourceCodeRenderable {
    let type: TargetType
    let name: String
    let dependencies: [TargetDependency]
    let resources: [TargetResource]

    var renderableContent: String {
        ".\(type.rawValue)("
        Indent {
            Joined(by: ",") {
                "name: \"\(name)\""

                if !dependencies.isEmpty {
                    "dependencies: ["
                    Indent {
                        dependencies
                            .map { $0.renderableContent }
                            .joined(separator: ",")
                    }
                    "]"
                }

                if !resources.isEmpty {
                    "resources: ["
                    Indent {
                        resources
                            .map { $0.renderableContent }
                            .joined(separator: ",")
                    }
                    "]"
                }
            }
        }
        ")"
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

public protocol TargetDependency: SourceCodeRenderable {}

struct LocalDependency: TargetDependency {
    let target: [NameComponent]

    var renderableContent: String {
        """
        .target(name: "\(target.nameString)")
        """
    }
}

struct ProductDependency: TargetDependency {
    let product: [NameComponent]
    let package: [NameComponent]

    var renderableContent: String {
        """
        .product(name: "\(product.nameString)", package: "\(package.nameString)")
        """
    }
}


public enum ResourceType: String {
    case process
    case copy
}

public struct TargetResource: SourceCodeRenderable {
    let type: ResourceType
    let path: [NameComponent]

    public var renderableContent: String {
        """
        .\(type.rawValue)("\(path.nameString)")
        """
    }
}
