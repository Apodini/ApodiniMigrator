//
//  File.swift
//
//
//  Created by Eldi Cano on 05.06.21.
//

import Foundation

/// A builder protocol where `Result` is `TypeInformation`
public protocol TypeInformationBuilder: Builder where Input == Any.Type, Result == TypeInformation {}

// MARK: - TypeInformationBuilder
public extension TypeInformationBuilder {
    /// Builds a typeinformation instance with `Self`
    static func result(of input: Input) throws -> Result {
        try Self(input).build()
    }
}

// MARK: - TypeInformation
public extension TypeInformation {
    /// Returns a `TypeInformation` instance built with `builderType`
    static func of<B: TypeInformationBuilder>(_ type: Any.Type, with builderType: B.Type) throws -> TypeInformation {
        try builderType.init(type).build()
    }
}
