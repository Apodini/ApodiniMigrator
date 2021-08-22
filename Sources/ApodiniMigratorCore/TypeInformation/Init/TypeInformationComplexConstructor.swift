//
//  TypeInformationComplexConstructor.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

protocol TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation
}

extension Optional: TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation {
        .optional(wrappedValue: try .of(Wrapped.self, with: T.self))
    }
}

extension Array: TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation {
        .repeated(element: try .of(Element.self, with: T.self))
    }
}

extension Set: TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation {
        .repeated(element: try .of(Element.self, with: T.self))
    }
}

extension Dictionary: TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation {
        guard let primitiveKey = PrimitiveType(Key.self) else {
            throw TypeInformation.TypeInformationError.notSupportedDictionaryKeyType
        }
        return .dictionary(key: primitiveKey, value: try .of(Value.self, with: T.self))
    }
}
