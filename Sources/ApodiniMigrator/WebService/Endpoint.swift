import Foundation

/// A typealias of an array of `Parameter`
public typealias EndpointInput = [Parameter]

/// Represents an endpoint
public struct Endpoint: Value, DeltaIdentifiable {
    /// Name of the handler
    public let handlerName: String

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
    
    /// Errors
    public let errors: [ErrorCode]
    
    /// Initializes a new endpoint instance
    public init(
        handlerName: String,
        deltaIdentifier: String,
        operation: Operation,
        absolutePath: String,
        parameters: EndpointInput,
        response: TypeInformation,
        errors: [ErrorCode]
    ) {
        self.handlerName = handlerName
        self.deltaIdentifier = .init(deltaIdentifier)
        self.operation = operation
        self.path = .init(absolutePath)
        self.parameters = parameters
        self.response = response.replaceEmptyIfNeeded()
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

// MARK: - TypeInformation: Apodini.Empty
fileprivate extension TypeInformation {
    static let apodiniEmpty: TypeInformation = .object(name: .init(name: "Empty", definedIn: "Apodini"), properties: [])
    static let statusEnum: TypeInformation = .enum(
        name: .init(name: "Status", definedIn: "Apodini"),
        cases: [.init("ok"), .init("created"), .init("noContent")]
    )
    
    func replaceEmptyIfNeeded() -> TypeInformation {
        self == Self.apodiniEmpty ? Self.statusEnum : self
    }
}
