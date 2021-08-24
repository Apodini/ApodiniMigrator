//
//  TypeInformation+FileRenderable.swift
//  ApodiniMigratorCore
//
//  Created by Andreas Bauer on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import ApodiniTypeInformation

public extension TypeInformation {
    /// Returns unique enum and object types defined in `self`
    /// ```swift
    /// // MARK: - Code example
    /// struct Student {
    ///     let name: String
    ///     let surname: String
    ///     let uni: Uni
    /// }
    ///
    /// struct Uni {
    ///     let city: String
    ///     let name: String
    ///     let chairs: [Chair]
    /// }
    ///
    /// enum Chair {
    ///     case ls1
    ///     case other
    /// }
    ///
    /// ```
    /// Applied on `Student`, the functions returns `[.object(Student), .object(Uni), .enum(Chair)]`, respectively with
    /// the corresponding object properties and enum cases.
    func fileRenderableTypes() -> [TypeInformation] {
        filter(\.isEnumOrObject)
    }
}

public extension Array where Element == TypeInformation {
    /// Computes the file renderable types of all the contained TypeInformation instances.
    func fileRenderableTypes() -> Self {
        flatMap { $0.fileRenderableTypes() }.unique()
    }
}
