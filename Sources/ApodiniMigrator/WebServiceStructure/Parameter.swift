//
//  File.swift
//  
//
//  Created by Eldi Cano on 22.03.21.
//

import Foundation

/// `Parameter` categorization needed for certain interface exporters (e.g., HTTP-based).
enum ParameterType: String, ComparableProperty {
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

/// Defines the necessity of a `Parameter`
enum Necessity: String, ComparableProperty {
    /// `.required` necessity describes parameters which require a valuer in any case.
    case required
    /// `.optional` necessity describes parameters which does not necessarily require a value.
    /// This does not necessarily translate to `nil` being a valid value.
    case optional
}

class ParameterName: PropertyValueWrapper<String> {}
class NilIsValidValue: PropertyValueWrapper<Bool> {}

/// Represents a parameter of an endpoint
struct Parameter {
    /// Name of the parameter
    let parameterName: ParameterName

    /// The necessity of the parameter
    let necessity: Necessity

    /// Parameter type
    let type: ParameterType

    /// Indicates whether `nil` is a valid value
    let nilIsValidValue: NilIsValidValue

    /// Schema name of the type of the parameter
    let schemaName: SchemaName
}

// MARK: - ComparableObject
extension Parameter: ComparableObject {
    var deltaIdentifier: DeltaIdentifier {
        .init(parameterName.value)
    }

    func compare(to other: Parameter) -> ChangeContextNode {
        ChangeContextNode()
            .register(compare(\.parameterName, with: other), for: ParameterName.self)
            .register(compare(\.necessity, with: other), for: Necessity.self)
            .register(compare(\.type, with: other), for: ParameterType.self)
            .register(compare(\.nilIsValidValue, with: other), for: NilIsValidValue.self)
            .register(compare(\.schemaName, with: other), for: SchemaName.self)
    }

    func evaluate(result: ChangeContextNode, embeddedInCollection: Bool) -> Change? {
        guard let context = context(from: result, embeddedInCollection: embeddedInCollection) else {
            return nil
        }

        let changes = [
            parameterName.change(in: context),
            necessity.change(in: context),
            type.change(in: context),
            nilIsValidValue.change(in: context),
            schemaName.change(in: context)
        ].compactMap { $0 }

        guard !changes.isEmpty else {
            return nil
        }

        return .compositeChange(location: Self.changeLocation, changes: changes)
    }
}
