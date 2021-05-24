import Foundation

//public class EndpointPath: PropertyValueWrapper<String> {}
public class HandlerName: PropertyValueWrapper<String> {}

public typealias EndpointInput = [Parameter]

/// Represents an endpoint
public struct Endpoint: Value, DeltaIdentifiable {
    /// Name of the handler
    public let handlerName: HandlerName

    /// Identifier of the handler
    public let deltaIdentifier: DeltaIdentifier

    /// The operation of the endpoint
    public let operation: Operation

    /// The path string of the endpoint
    public let path: EndpointPath

    /// Parameters of the endpoint
    public var parameters: EndpointInput

    /// The reference of the `typeInformation` of the response
    public var response: TypeInformation
    
    public var restResponse: TypeInformation {
        response.asRESTResponse
    }
    
    /// Errors
    public let errors: [ErrorCode]
    
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
        self.path = .init(absolutePath)
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
    
    mutating func reference(in typeStore: inout TypesStore) {
        response = typeStore.store(response)
        self.parameters = parameters.map {
            var param = $0
            param.reference(in: &typeStore)
            return param
        }
    }
}
