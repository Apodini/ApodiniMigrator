//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Categorization needed for certain interface exporters (e.g., HTTP-based).
public enum ParameterType: String, Value {
    /// Lightweight parameters are any parameters which are
    /// considered to be lightweight in some sort of way.
    /// This is the default parameter type for any primitive type properties.
    /// `LosslessStringConvertible` is a required protocol for such parameter types.
    case lightweight
    /// Parameters which transport some sort of more complex data.
    case content
    /// This parameter types represent parameters which are considered path parameters.
    /// Such parameters have a matching parameter in the `[EndpointPath]`.
    /// Such parameters are required to conform to `LosslessStringConvertible`.
    case path
}

/// Represents a parameter of an endpoint
public struct Parameter: Value {
    /// Name of the parameter
    public let name: String
    /// The reference of the `typeInformation` of the parameter
    public var typeInformation: TypeInformation
    /// Parameter type
    public let parameterType: ParameterType
    
    /// The necessity of the parameter
    public let necessity: Necessity
    
    /// Initializes a new parameter instance
    public init(
        name: String,
        typeInformation: TypeInformation,
        parameterType: ParameterType,
        isRequired: Bool
    ) {
        self.name = name
        self.typeInformation = typeInformation
        self.parameterType = parameterType
        self.necessity = isRequired ? .required : .optional
    }

    public mutating func reference(in typeStore: inout TypesStore) {
        typeInformation = typeStore.store(typeInformation)
    }

    public mutating func dereference(in typeStore: TypesStore) {
        typeInformation = typeStore.construct(from: typeInformation)
    }
    
    /// Returns a version of self where the typeInformation is a reference if a complex object or enum
    public func referencedType() -> Parameter {
        .init(
            name: name,
            typeInformation: typeInformation.asReference(),
            parameterType: parameterType,
            isRequired: necessity == .required
        )
    }
}

extension Parameter: DeltaIdentifiable {
    /// Delta identifier of the parameter instance
    public var deltaIdentifier: DeltaIdentifier { .init(name) }
}

extension Parameter {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case name, typeInformation = "type", parameterType = "kind", necessity
    }
    
    /// Encodes self into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(typeInformation, forKey: .typeInformation)
        try container.encode(parameterType, forKey: .parameterType)
        try container.encode(necessity, forKey: .necessity)
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        typeInformation = try container.decode(TypeInformation.self, forKey: .typeInformation)
        parameterType = try container.decode(ParameterType.self, forKey: .parameterType)
        necessity = try container.decode(Necessity.self, forKey: .necessity)
    }
}
