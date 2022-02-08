//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents any target in a swift package.
///
/// **The following target types are supported by default:**
/// * ``Target``: a standard swift sources target
/// * ``ExecutableTarget``: a swift executable target
/// * ``TestTarget``: a swift test target
public protocol TargetDirectory: LibraryComponent {
    /// The directory name.
    var path: Name { get }
    /// The ``TargetType``.
    var type: TargetType { get }
    /// Dependencies of the target.
    var dependencies: [TargetDependency] { get set }
    /// Optional resource declarations of the target.
    var resources: [TargetResource] { get set }

    /// Add a `.target` dependency to the target.
    /// - Parameter target: The name of the `.target` dependency.
    /// - Returns: Returns self for chaining.
    func dependency(target: Name) -> Self

    /// Add a `.product` dependency to the target.
    /// - Parameters:
    ///   - product: The `.product` which should be added as dependency.
    ///   - package: The package name in which the dependency resides in.
    /// - Returns: Returns self for chaining.
    func dependency(product: Name, of package: Name) -> Self

    /// Add a resource declaration to the target.
    /// - Parameters:
    ///   - type: The ``ResourceType``.
    ///   - path: The name of the resource folder.
    /// - Returns: Returns self for chaining.
    func resource(type: ResourceType, path: Name) -> Self
}

public extension TargetDirectory {
    /// Add a `.target` dependency to the target.
    /// - Parameter target: The name of the `.target` dependency.
    /// - Returns: Returns self for chaining.
    func dependency(target: Name) -> Self {
        var copy = self
        copy.dependencies.append(LocalDependency(target: target))
        return copy
    }

    /// Add a `.product` dependency to the target.
    /// - Parameters:
    ///   - product: The `.product` which should be added as dependency.
    ///   - package: The package name in which the dependency resides in.
    /// - Returns: Returns self for chaining.
    func dependency(product: Name, of package: Name) -> Self {
        var copy = self
        copy.dependencies.append(ProductDependency(product: product, package: package))
        return copy
    }
}

public extension TargetDirectory {
    /// Add a resource declaration to the target.
    /// - Parameters:
    ///   - type: The ``ResourceType``.
    ///   - path: The name of the resource folder.
    /// - Returns: Returns self for chaining.
    func resource(type: ResourceType, path: Name) -> Self {
        var copy = self
        copy.resources.append(TargetResource(type: type, path: path))
        return copy
    }
}
