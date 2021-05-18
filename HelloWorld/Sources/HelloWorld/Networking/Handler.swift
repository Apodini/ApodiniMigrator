//
//  Handler.swift
//
//  Created by ApodiniMigrator on 18.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An object that represents a `Handler` of Apodini DSL.
/// Encapsulates all neccessary properties, in order to establish a communication with the correspoding `Handler` of the web service
struct Handler<D: Decodable> {
    /// The sub path of the handler, e.g. `v1/users/{id}`
    let path: String
    /// The corresponding `HTTPMethod` of an `Apodini` operation
    let httpMethod: HTTPMethod
    /// Lightweight / query `Parameters` of the `Handler`
    let parameters: Parameters
    /// `.header` parameter types of the handler
    var headers: HTTPHeaders
    /// Encoded data of `.content` parameter types in an Apodini `Handler`
    /// - Note: multiple `.content` params are wrapped into one single object, where each param represents a field of the wrapped object
    let content: Data?
    /// Optional `HTTPAuthorization` required to establish the communication with the handler
    let authorization: HTTPAuthorization?
    /// Errors that an `Apodini` `Handler` can throw (`@Throws`)
    let errors: [ApodiniError]
    /// Full sub path of the `Handler` including `query` parameters, e.g. `v1/users/42?name=John`
    var fullPath: String {
        "\(path)\(parameters.string())"
    }
    
    /// Initializes a new `Handler` instance
    /// - Parameters:
    ///    - path: the sub path of the handler, e.g. `v1/users/{id}`
    ///    - httpMethod: the corresponding `HTTPMethod` of an `Apodini` operation
    ///    - parameters: lightweight / query `Parameters` of the `Handler`
    ///    - headers: `.header` parameter types of the handler
    ///    - content: encoded data of `.content` parameter types in an Apodini `Handler`.
    ///    Multiple `.content` params are wrapped into one single object, where each param represents a field of the wrapped object
    ///    - authorization: optional `HTTPAuthorization` required to establish the communication with the handler
    ///    - errors: errors that an `Apodini` `Handler` can throw (`@Throws`)
    init(
        path: String,
        httpMethod: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders,
        content: Data?,
        authorization: HTTPAuthorization?,
        errors: [ApodiniError]
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.parameters = parameters
        self.headers = headers
        self.content = content
        self.authorization = authorization
        self.errors = errors
    }
    
    /// A function to retrieve an associated `ApodiniError`
    /// - Parameters:
    ///    - code: `statusCode` of the error
    /// - Returns: an `ApodiniError` if already contained in `errors`, otherwise `nil`
    func error(with code: Int) -> ApodiniError? {
        errors.first { $0.code == code }
    }
}

/// URLRequest extension support for `Handler`
extension URLRequest {
    /// Initializes a new `URLRequest`
    /// - Parameters:
    ///    - handler: handler instance, for which the request should be created
    ///    - basePath: string of the base path (server url)
    init<D: Decodable>(for handler: Handler<D>, with basePath: String) {
        let urlString = "\(NSString(string: basePath).appendingPathComponent(handler.fullPath))"
        guard let url = URL(string: urlString) else {
            fatalError("Encountered an invalid path for the handler of \(D.self): \(urlString)")
        }
        
        self.init(url: url)
        
        httpMethod = handler.httpMethod.string
        var headers = handler.headers
        
        if let authorization = handler.authorization {
            switch authorization.location {
                case .cookie, .header:
                authorization.inject(into: &headers)
                case .query:
                let query = "\(url.query != nil ? "&" : "?")\(authorization.query)"
                self.url?.appendPathComponent(query)
            }
        }
        
        set(headers)
        
        httpBody = handler.content
    }
}

