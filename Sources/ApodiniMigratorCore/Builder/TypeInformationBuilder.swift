//
//  TypeInformationBuilder.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A builder protocol where `Result` is `TypeInformation`
public protocol TypeInformationBuilder: Builder where Input == Any.Type, Result == TypeInformation {}

// MARK: - TypeInformation
public extension TypeInformation {
    /// Returns a `TypeInformation` instance built with `builderType`
    static func of<B: TypeInformationBuilder>(_ type: Any.Type, with builderType: B.Type) throws -> TypeInformation {
        try builderType.init(type).build()
    }
}
