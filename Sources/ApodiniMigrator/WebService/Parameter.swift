import Foundation

/** ParameterType from Apodini*/

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
    /// Parameters contained in the HTTP headers of a request.
    case header
}

extension ParameterType: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

/** Necessity from Apodini*/
/// Defines the necessity of a `Parameter`
public enum Necessity: String, Value {
    /// `.required` necessity describes parameters which require a value in any case.
    case required
    /// `.optional` necessity describes parameters which do not necessarily require a value.
    /// This does not necessarily translate to `nil` being a valid value.
    case optional
}

/// Represents a parameter of an endpoint
public struct Parameter: Value {
    /// Name of the parameter
    public let name: String
    /// The reference of the `typeInformation` of the parameter
    public var typeInformation: TypeInformation
    
    /// Indicates whether the parameter has a default value
    public let hasDefaultValue: Bool

    /// Parameter type
    public let parameterType: ParameterType
    
    /// Indicates whether `nil` is a valid value, equavalent of `typeInformation` being optional
    public var nilIsValidValue: Bool {
        typeInformation.isOptional
    }
    
    /// The necessity of the parameter
    public var necessity: Necessity {
        nilIsValidValue ? .optional : hasDefaultValue ? .optional : .required
    }
    
    public init(
        parameterName: String,
        typeInformation: TypeInformation,
        hasDefaultValue: Bool,
        parameterType: ParameterType
    ) {
        self.name = parameterName
        self.typeInformation = typeInformation
        self.hasDefaultValue = hasDefaultValue
        self.parameterType = parameterType
    }
    
    mutating func dereference(in typeStore: inout TypesStore) {
        typeInformation = typeStore.construct(from: typeInformation)
    }
    
    mutating func reference(in typeStore: inout TypesStore) {
        typeInformation = typeStore.store(typeInformation)
    }
}

extension Parameter: DeltaIdentifiable {
    public var deltaIdentifier: DeltaIdentifier { .init(name) }
}

extension Parameter {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case parameterName, typeInformation = "type", hasDefaultValue, parameterType = "kind"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .parameterName)
        try container.encode(typeInformation, forKey: .typeInformation)
        try container.encode(hasDefaultValue, forKey: .hasDefaultValue)
        try container.encode(parameterType, forKey: .parameterType)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .parameterName)
        typeInformation = try container.decode(TypeInformation.self, forKey: .typeInformation)
        hasDefaultValue = try container.decode(Bool.self, forKey: .hasDefaultValue)
        parameterType = try container.decode(ParameterType.self, forKey: .parameterType)
    }
}
