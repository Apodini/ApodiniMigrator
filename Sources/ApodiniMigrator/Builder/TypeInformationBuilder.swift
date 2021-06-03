//
//  File.swift
//  
//
//  Created by Eldi Cano on 03.06.21.
//

import Foundation

/// A type information builder protocol where `Input` is `Any.Type` and `Result` is `TypeInformation`
public protocol TypeInformationBuilder: Builder where Input == Any.Type, Result == TypeInformation {}

// MARK: - TypeInformationBuilder
public extension TypeInformationBuilder {
    /// Builds a typeinformation instance with `Self`
    static func typeInformation(of type: Input) throws -> Result {
        try Self(type).build()
    }
}

// MARK: - TypeInformation
public extension TypeInformation {
    /// Builds a type information instance of `type` with the specified `builderType`
    static func typeInformation<B: TypeInformationBuilder>(
        of type: Any.Type,
        with builderType: B.Type
    ) throws -> TypeInformation {
        try builderType.init(type).build()
    }
}
