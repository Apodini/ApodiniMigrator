//
//  JSONStringBuilder.swift
//  ApodiniMigratorClientSupport
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation
import ApodiniMigratorCore

/// Builds a valid JSON string with values empty strings, 0 for numbers, empty Data, date of today, and random UUID
/// by means of a `typeInformation` object
public struct JSONStringBuilder {
   /// `TypeInformation` of the type that is used as template for JSONString
    private let typeInformation: TypeInformation
    /// `JSONEncoder` used to encode the value of the type
    private let encoder: JSONEncoder
    
    /// Initializes `self` with an `Any` type and a JSONEncoder
    init(_ type: Any.Type, encoder: JSONEncoder = .init()) throws {
        self.init(try TypeInformation(type: type), encoder: encoder)
    }
    
    /// Private initializer for `json` string builder of an empty instance
    private init(_ typeInformation: TypeInformation, encoder: JSONEncoder = .init()) {
        self.typeInformation = typeInformation
        self.encoder = encoder
    }
    
    /// Initializes `self` with a `typeInformation` property and an `EncoderConfiguration` object
    init(_ typeInformation: TypeInformation, with configuration: EncoderConfiguration) {
        self.init(typeInformation, encoder: JSONEncoder().configured(with: configuration))
    }
    
    /// Dictionaries are encoded either with curly brackes `{ "key" : value }` if the key is String or Int,
    /// or as an array containing keys and values interchangeably e.g. [key, value] for keys of other types
    private func requiresCurlyBrackets(_ primitiveType: PrimitiveType) -> Bool {
        [.string, .int].contains(primitiveType)
    }

    /// Builds and returns a valid JSON string from the `typeInformation`
    private func build() -> String {
        switch typeInformation {
        case let .scalar(primitiveType):
            return primitiveType.jsonString(with: encoder)
        case .repeated:
            return "[]"
        case let .dictionary(key, _):
            return requiresCurlyBrackets(key) ? "{}" : "[]"
        case .optional:
            return "null"
        case let .enum(_, rawValueType, cases):
            if rawValueType == .int {
                return PrimitiveType.int.jsonString(with: encoder)
            }
            return cases.first?.name.doubleQuoted ?? "{}"
        case let .object(_, properties):
            let sorted = properties.sorted(by: \.name)
            return "{\(String.lineBreak)\(sorted.map { $0.name.doubleQuoted + " : \(Self($0.type, encoder: encoder).build())" }.joined(separator: ",\(String.lineBreak)"))\(String.lineBreak)}"
        default: return "{}"
        }
    }
    
    static func jsonString(_ type: Any.Type) throws -> String {
        try Self(type).build()
    }
    
    /// Returns a json string representation of an instance out of the typeinformation
    public static func jsonString(_ typeInformation: TypeInformation, with encoderConfiguration: EncoderConfiguration) -> String {
        Self(typeInformation, with: encoderConfiguration).build()
    }
    
    /// Initializes an instance out of a `ApodiniMigratorCodable` type.
    static func instance<C: ApodiniMigratorCodable>(_ type: C.Type) throws -> C {
        try C.decode(from: try Self(C.self, encoder: C.encoder).build())
    }
}

fileprivate extension Encodable {
    func jsonString(with encoder: JSONEncoder) -> String {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = (try? encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}

fileprivate extension PrimitiveType {
    func jsonString(with encoder: JSONEncoder) -> String {
        swiftType.jsonString(with: encoder)
    }
}

fileprivate extension DefaultInitializable {
    static func jsonString(with encoder: JSONEncoder) -> String {
        `default`.jsonString(with: encoder)
    }
}
