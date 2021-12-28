//
//  Handler.swift
//
//  Created by ApodiniMigrator on 14.11.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// An object that represents a `Handler` of Apodini DSL.
/// Encapsulates all neccessary properties, in order to establish a communication with the correspoding `Handler` of the web service
public struct Handler<D: Decodable> {
    /// The sub path of the handler, e.g. `v1/users/{id}`
    public let path: String
    /// The corresponding `HTTPMethod` of an `Apodini` operation
    public let httpMethod: HTTPMethod
    /// Lightweight / query `Parameters` of the `Handler`
    public let parameters: Parameters
    /// `.header` parameter types of the handler
    public let headers: HTTPHeaders
    /// Encoded data of `.content` parameter types in an Apodini `Handler`
    /// - Note: multiple `.content` params are wrapped into one single object, where each param represents a field of the wrapped object
    public let content: Data?
    /// Optional `HTTPAuthorization` required to establish the communication with the handler
    public let authorization: HTTPAuthorization?
    /// Errors that an `Apodini` `Handler` can throw (`@Throws`)
    public let errors: [ApodiniError]
    /// Full sub path of the `Handler` including `query` parameters, e.g. `v1/users/42?name=John`
    public var fullPath: String {
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
    public init(
        path: String,
        httpMethod: HTTPMethod,
        parameters: Parameters,
        headers: HTTPHeaders,
        content: Data?,
        authorization: String?,
        errors: [ApodiniError]
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.parameters = parameters
        self.headers = headers
        self.content = content
        self.authorization = .authorization(authorization) ?? .networkingService()
        self.errors = errors
    }
    
    /// A function to retrieve an associated `ApodiniError`
    /// - Parameters:
    ///    - code: `statusCode` of the error
    /// - Returns: an `ApodiniError` if already contained in `errors`, otherwise `nil`
    public func error(with code: Int) -> ApodiniError? {
        errors.first { $0.code == code }
    }
}

/// URLRequest extension support for `Handler`
extension URLRequest {
    /// Initializes a new `URLRequest`
    /// - Parameters:
    ///    - handler: handler instance, for which the request should be created
    ///    - baseURL: base url of the web service
    init<D: Decodable>(for handler: Handler<D>, with baseURL: URL) {
        self.init(url: baseURL.appendingPathComponent(handler.fullPath))
        
        httpMethod = handler.httpMethod.string
        var headers = handler.headers
        
        if let authorization = handler.authorization {
            switch authorization.location {
            case .cookie, .header:
                authorization.inject(into: &headers)
            case .query:
                let query = "\(url?.query != nil ? "&" : "?")\(authorization.query)"
                url?.appendPathComponent(query)
            }
        }
        
        set(headers)
        
        httpBody = handler.content
    }
}
