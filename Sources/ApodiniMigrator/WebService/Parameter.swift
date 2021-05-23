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
    /// `.required` necessity describes parameters which require a valuer in any case.
    case required
    /// `.optional` necessity describes parameters which does not necessarily require a value.
    /// This does not necessarily translate to `nil` being a valid value.
    case optional
    
    public init(_ hasDefaultValue: HasDefaultValue) {
        self = hasDefaultValue.value ? .optional : .required
    }
}

public class ParameterName: PropertyValueWrapper<String> {}
public class NilIsValidValue: PropertyValueWrapper<Bool> {}
public class HasDefaultValue: PropertyValueWrapper<Bool> {}

/// Represents a parameter of an endpoint
public struct Parameter: Value {
    /// Name of the parameter
    public let parameterName: ParameterName
    /// The reference of the `typeInformation` of the parameter
    public var typeInformation: TypeInformation
    
    /// Indicates whether the parameter has a default value
    public let hasDefaultValue: HasDefaultValue

    /// Parameter type
    public let parameterType: ParameterType
    
    /// Indicates whether `nil` is a valid value, equavalent of `typeInformation` beeing optional
    public var nilIsValidValue: NilIsValidValue {
        .init(typeInformation.isOptional)
    }
    
    /// The necessity of the parameter
    public var necessity: Necessity {
        nilIsValidValue.value ? .optional : .init(hasDefaultValue)
    }
    
    public init(
        parameterName: String,
        typeInformation: TypeInformation,
        hasDefaultValue: Bool,
        parameterType: ParameterType
    ) {
        self.parameterName = .init(parameterName)
        self.typeInformation = typeInformation
        self.hasDefaultValue = .init(hasDefaultValue)
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
    public var deltaIdentifier: DeltaIdentifier { .init(parameterName.value) }
}

//// MARK: - ComparableObject
//extension Parameter: ComparableObject {
//    var deltaIdentifier: DeltaIdentifier {
//        .init(parameterName.value)
//    }
//
//    func compare(to other: Parameter) -> ChangeContextNode {
//        ChangeContextNode()
//    }
//
//    func evaluate(result: ChangeContextNode, embeddedInCollection: Bool) -> Change? {
//        nil
//    }
//}
//
extension Parameter {
    // MARK: Private Inner Types
    private enum CodingKeys: String, CodingKey {
        case parameterName, typeInformation, hasDefaultValue, parameterType//, nilIsValid, necessity
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(parameterName, forKey: .parameterName)
        try container.encode(typeInformation, forKey: .typeInformation)
        try container.encode(hasDefaultValue, forKey: .hasDefaultValue)
        try container.encode(parameterType, forKey: .parameterType)
//        try container.encode(nilIsValidValue, forKey: .nilIsValid)
//        try container.encode(necessity, forKey: .necessity)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        parameterName = try container.decode(ParameterName.self, forKey: .parameterName)
        typeInformation = try container.decode(TypeInformation.self, forKey: .typeInformation)
        hasDefaultValue = try container.decode(HasDefaultValue.self, forKey: .hasDefaultValue)
        parameterType = try container.decode(ParameterType.self, forKey: .parameterType)
    }
}
