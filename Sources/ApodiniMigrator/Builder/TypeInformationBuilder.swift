//
//  TypeInformationBuilder.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 27.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
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
