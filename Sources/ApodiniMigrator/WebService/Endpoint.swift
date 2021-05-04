

import Foundation

class Path: PropertyValueWrapper<String> {}
class HandlerName: PropertyValueWrapper<String> {}
class PallidorOperationName: PropertyValueWrapper<String> {}
class PallidorEndpointName: PropertyValueWrapper<String> {}

/// Represents an endpoint
struct Endpoint {
    /// Name of the handler
    let handlerName: HandlerName

    /// Identifier of the handler
    let deltaIdentifier: DeltaIdentifier

    /// The operation of the endpoint
    let operation: Operation

    /// The absolute path string of the endpoint
    let absolutePath: Path

    /// Parameters of the endpoint
    let parameters: [Parameter]

    /// The reference of the type descriptor of the response
    let response: TypeDescriptor
    
    /// Name of the operation specified via `.pallidor(_:)` modified
    let operationName: PallidorOperationName
    
    /// The first path component of the endpoint after dropping the version
    /// e.g. `/v1/users` -> `users`. Used in Pallidor to group endpoints in one file
    let endpointName: PallidorEndpointName

    init(
        handlerName: String,
        deltaIdentifier: DeltaIdentifier,
        operation: Operation,
        absolutePath: String,
        parameters: [Parameter],
        response: TypeDescriptor,
        operationName: String,
        endpointName: PallidorEndpointName
    ) {
        self.handlerName = .init(handlerName)
        self.deltaIdentifier = deltaIdentifier
        self.operation = operation
        self.absolutePath = .init(absolutePath)
        self.parameters = parameters
        self.response = response
        self.operationName = .init(operationName)
        self.endpointName = endpointName
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
            parameters.evaluate(node: context),
            operationName.change(in: context),
            endpointName.change(in: context)
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
            .register(compare(\.absolutePath, with: other), for: Path.self)
            .register(result: compare(\.parameters, with: other), for: Parameter.self)
            .register(compare(\.operationName, with: other), for: PallidorOperationName.self)
            .register(compare(\.endpointName, with: other), for: PallidorEndpointName.self)
    }
}
