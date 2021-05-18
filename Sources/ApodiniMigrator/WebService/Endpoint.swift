import Foundation

class EndpointPath: PropertyValueWrapper<String> {}
class HandlerName: PropertyValueWrapper<String> {}

public typealias EndpointInput = [Parameter]

/// Represents an endpoint
public struct Endpoint {
    /// Name of the handler
    let handlerName: HandlerName

    /// Identifier of the handler
    let deltaIdentifier: DeltaIdentifier

    /// The operation of the endpoint
    let operation: Operation

    /// The absolute path string of the endpoint
    let absolutePath: EndpointPath

    /// Parameters of the endpoint
    public var parameters: EndpointInput

    /// The reference of the `typeInformation` of the response
    public var response: TypeInformation
    
    public var restResponse: TypeInformation {
        response.asRESTResponse
    }
    
    /// Errors
    let errors: [ErrorCode]
    
    public init(
        handlerName: String,
        deltaIdentifier: String,
        operation: Operation,
        absolutePath: String,
        parameters: EndpointInput,
        response: TypeInformation,
        errors: [ErrorCode]
    ) {
        self.handlerName = .init(handlerName)
        self.deltaIdentifier = .init(deltaIdentifier)
        self.operation = operation
        self.absolutePath = .init(absolutePath)
        self.parameters = parameters
        self.response = response
        self.errors = errors
    }
    
    mutating func dereference(in typeStore: inout TypesStore) {
        response = typeStore.construct(from: response)
        self.parameters = parameters.map {
            var param = $0
            param.dereference(in: &typeStore)
            return param
        }
    }
}

// MARK: - ComparableObject
extension Endpoint: ComparableObject {
    func evaluate(result: ChangeContextNode, embeddedInCollection: Bool) -> Change? {
        guard let context = context(from: result, embeddedInCollection: embeddedInCollection) else {
            return nil
        }

        let changes = [
            handlerName.change(in: context),
            operation.change(in: context),
            absolutePath.change(in: context),
            parameters.evaluate(node: context)
        ].compactMap { $0 }

        guard !changes.isEmpty else {
            return nil
        }

        return .compositeChange(location: Self.changeLocation, changes: changes)
    }

    func compare(to other: Endpoint) -> ChangeContextNode {
        ChangeContextNode()
            .register(compare(\.handlerName, with: other), for: HandlerName.self)
            .register(compare(\.operation, with: other), for: Operation.self)
            .register(compare(\.absolutePath, with: other), for: EndpointPath.self)
            .register(result: compare(\.parameters, with: other), for: Parameter.self)
    }
}
