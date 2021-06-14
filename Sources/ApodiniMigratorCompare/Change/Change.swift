//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

enum ChangeType: String, Value {
    case addition
    case deletion
    case rename
    case valueChange
    case parameterChange
    case typeChange
}

protocol Change: Codable {
    var element: ChangeElement { get }
    var target: ChangeTarget { get }
    var type: ChangeType { get }
    var breaking: Bool { get }
    var solvable: Bool { get }
    var identifier: DeltaIdentifier { get }
}


// MARK: - Array
extension Array where Element == Change {
    
    func of<D: DeltaIdentifiable>(_ deltaIdentifiable: D) -> [Change] {
        filter { $0.element.deltaIdentifier == deltaIdentifiable.deltaIdentifier }
    }
    
    // needs endpoint as parameter
    func parameterChanges() -> [ParameterChange] {
        (filter { $0 is ParameterChange } as? [ParameterChange]) ?? []
    }
}

extension Change {
    var identifier: DeltaIdentifier { element.deltaIdentifier }
}

extension Change {
    func typed<C: Change>(_ type: C.Type) -> C {
        guard let self = self as? C else {
            fatalError("Failed to cast change to \(C.self)")
        }
        return self
    }
}

/// If deleted, fatalErrorBody, if added, create new with template without changes, otherwise below
struct MigratedEndpointRenderer {
    let endpoint: Endpoint
    var changes: [Change]
    
    init(for endpoint: Endpoint, changes: [Change]) {
        self.endpoint = endpoint
        self.changes = changes.of(endpoint)
    }
    
    /// no change to previous parameters, add only new ones with default values
    func signature() -> String {
        ""
    }
    
    
    func queryParametersBody() -> String {
        ""
    }
    
    func headerParametersBody() -> String {
        ""
    }
    
    func errorsBody() -> String {
        ""
    }
    
    func path() -> String {
        ""
    }
    
    func httpMethod() -> String {
        ""
    }
    
    func headers() -> String {
        ""
    }
    
    func content() -> String {
        ""
    }
    
    func authorization() -> String {
        ""
    }
    
    func errors() -> String {
        ""
    }
    
    /// check if deleted
    func endpointMethod() -> String {
        ""
    }
}
/*
public static func \(methodName)(\(endpoint.methodInputString())) -> ApodiniPublisher<\(responseString)> {
\(queryParametersString)var headers = HTTPHeaders()
headers.setContentType(to: "application/json")

var errors: [ApodiniError] = []
\(endpoint.errors.map { "errors.addError(\($0.code), message: \($0.message.asString))" }.lineBreaked)

let handler = Handler<\(responseString)>(
path: \(path.asString),
httpMethod: .\(endpoint.operation.asHTTPMethodString),
parameters: \(queryParametersString.isEmpty ? "[:]" : "parameters"),
headers: headers,
content: \(endpoint.contentParameterString),
authorization: \(endpoint.hasAuthorization ? ".authorization(authorization)" : "nil"),
errors: errors
)

return NetworkingService.trigger(handler)
}
"""
*/
