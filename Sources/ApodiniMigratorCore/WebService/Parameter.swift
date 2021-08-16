//
//  Parameter.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
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

extension ParameterType: CustomStringConvertible {
    /// A string representation of self
    public var description: String {
        rawValue
    }
}

/// Represents distinct cases of necessities for parameters or properties of an object
public enum Necessity: String, Value {
    /// `.required` necessity describes parameters or properties which require a value in any case.
    case required
    /// `.optional` necessity describes parameters or properties which do not necessarily require a value.
    case optional
}

/// Represents a parameter of an endpoint
public struct Parameter: Value {
    /// Adjusted name for multiple content parameter types wrapped into one object
    static let wrappedContentParameter = "wrappedContentParameter"
    /// Name of the parameter
    public let name: String
    /// The reference of the `typeInformation` of the parameter
    public var typeInformation: TypeInformation
    /// Parameter type
    public let parameterType: ParameterType
    
    /// The necessity of the parameter
    public let necessity: Necessity
    
    /// Multiple content type parameters are wrapped into one single object, where each of its properties
    /// has the name and the typeInformation of the corresponding parameter. The wrapped content parameter in that
    /// case is considered to have a default value if all content parameters have one default value. The wrapped content
    /// parameter is considered to accept `nil` as valid value if all content parameters accept it.
    /// This property indicates if `self` name is `wrappedContentParameter`, name of typeInformation has `WrappedContent` as suffix,
    /// and the parameter type is `.content`
    public var isWrapped: Bool {
        name == Self.wrappedContentParameter
            && typeInformation.typeName.name.hasSuffix("WrappedContent")
            && parameterType == .content
    }
    
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
    
    mutating func dereference(in typeStore: inout TypesStore) {
        typeInformation = typeStore.construct(from: typeInformation)
    }
    
    mutating func reference(in typeStore: inout TypesStore) {
        typeInformation = typeStore.store(typeInformation)
    }
    
    static func wrappedContentParameterTypeName(from handlerName: String) -> TypeName {
        .init(name: handlerName.without("Handler") + "WrappedContent")
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
