//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
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
    let target: Name

    var renderableContent: String {
        """
        .target(name: "\(target.description)")
        """
    }
}

struct ProductDependency: TargetDependency {
    let product: Name
    let package: Name

    var renderableContent: String {
        """
        .product(name: "\(product.description)", package: "\(package.description)")
        """
    }
}


public enum ResourceType: String {
    case process
    case copy
}

public struct TargetResource: SourceCodeRenderable {
    let type: ResourceType
    let path: Name

    public var renderableContent: String {
        """
        .\(type.rawValue)("\(path.description)")
        """
    }
}
