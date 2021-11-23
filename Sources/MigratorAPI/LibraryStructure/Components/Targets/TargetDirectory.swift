//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public protocol TargetDirectory: LibraryComponent {
    var path: [NameComponent] { get }
    var type: TargetType { get }
    var dependencies: [TargetDependency] { get set }

    // TODO add support for RESOURCES! (shall be done via containing directories?)

    func dependency(target: NameComponent...) -> Self
    func dependency(product: String, of package: String) -> Self
}

public extension TargetDirectory {
    func dependency(target: NameComponent...) -> Self {
        var copy = self
        copy.dependencies.append(LocalDependency(target: target))
        return copy
    }

    func dependency(product: String, of package: String) -> Self {
        var copy = self
        copy.dependencies.append(ProductDependency(product: product, package: package))
        return copy
    }
}
