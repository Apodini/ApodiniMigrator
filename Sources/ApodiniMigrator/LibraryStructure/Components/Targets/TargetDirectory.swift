//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public protocol TargetDirectory: LibraryComponent {
    var path: [NameComponent] { get }
    var type: TargetType { get }
    var dependencies: [TargetDependency] { get set }
    var resources: [TargetResource] { get set }

    func dependency(target: NameComponent...) -> Self
    func dependency(product: NameComponent..., of package: NameComponent...) -> Self
}

public extension TargetDirectory {
    func dependency(target: NameComponent...) -> Self {
        var copy = self
        copy.dependencies.append(LocalDependency(target: target))
        return copy
    }

    func dependency(product: NameComponent..., of package: NameComponent...) -> Self {
        var copy = self
        copy.dependencies.append(ProductDependency(product: product, package: package))
        return copy
    }
}

public extension TargetDirectory {
    func resource(type: ResourceType, path: NameComponent...) -> Self {
        var copy = self
        copy.resources.append(TargetResource(type: type, path: path))
        return copy
    }
}
