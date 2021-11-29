//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

struct PackageTarget: RenderableBuilder {
    let type: TargetType
    let name: String
    let dependencies: [TargetDependency]
    let resources: [TargetResource]

    var fileContent: String {
        ".\(type.rawValue)("
        Indent {
            Joined(by: ",") {
                "name: \"\(name)\""

                if !dependencies.isEmpty {
                    "dependencies: ["
                    Indent {
                        dependencies
                            .map { $0.fileContent }
                            .joined(separator: ",")
                    }
                    "]"
                }

                if !resources.isEmpty {
                    "resources: ["
                    Indent {
                        resources
                            .map { $0.fileContent }
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

public protocol TargetDependency: RenderableBuilder {}

struct LocalDependency: TargetDependency {
    let target: [NameComponent]

    var fileContent: String {
        """
        .target(name: "\(target.nameString)")
        """
    }
}

struct ProductDependency: TargetDependency {
    let product: [NameComponent]
    let package: [NameComponent]

    var fileContent: String {
        """
        .product(name: "\(product.nameString)", package: "\(package.nameString)")
        """
    }
}


public enum ResourceType: String {
    case process
    case copy
}

public struct TargetResource: RenderableBuilder {
    let type: ResourceType
    let path: [NameComponent]

    public var fileContent: String {
        """
        .\(type.rawValue)("\(path.nameString)")
        """
    }
}
