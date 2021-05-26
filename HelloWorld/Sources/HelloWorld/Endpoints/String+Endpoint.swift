//
//  String+Endpoint.swift
//
//  Created by ApodiniMigrator on 26.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension String {
    // MARK: - greetMe
    /// API call for TraditionalGreeter at: /v1/greet
    static func greetMe(age: Int, name: String?, surname: String) -> ApodiniPublisher<String> {
        var parameters: Parameters = [:]
        parameters.set(surname, forKey: "surname")
        parameters.set(age, forKey: "age")
        parameters.set(name, forKey: "name")
        
        var headers: HTTPHeaders = [:]
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<String>(
            path: "/v1/greet",
            httpMethod: .get,
            parameters: parameters,
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - helloSwiftFiveDotThree
    /// API call for Text at: /v1/swift/5/3
    static func helloSwiftFiveDotThree() -> ApodiniPublisher<String> {
        var headers: HTTPHeaders = [:]
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<String>(
            path: "/v1/swift/5/3",
            httpMethod: .get,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - placeBid
    /// API call for Auction at: /v1/auction
    static func placeBid(bid: UInt) -> ApodiniPublisher<String> {
        var parameters: Parameters = [:]
        parameters.set(bid, forKey: "bid")
        
        var headers: HTTPHeaders = [:]
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<String>(
            path: "/v1/auction",
            httpMethod: .get,
            parameters: parameters,
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - sayHelloToSwift
    /// API call for Text at: /v1/swift
    static func sayHelloToSwift() -> ApodiniPublisher<String> {
        var headers: HTTPHeaders = [:]
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<String>(
            path: "/v1/swift",
            httpMethod: .get,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - sayHelloWorld
    /// API call for Text at: /v1
    static func sayHelloWorld() -> ApodiniPublisher<String> {
        var headers: HTTPHeaders = [:]
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<String>(
            path: "/v1",
            httpMethod: .get,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
}
