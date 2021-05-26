//
//  User+Endpoint.swift
//
//  Created by ApodiniMigrator on 26.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension User {
    // MARK: - getAuthenticatedUser
    /// API call for AuthenticatedUserHandler at: authenticated
    static func getAuthenticatedUser() -> ApodiniPublisher<User> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<User>(
            path: "authenticated",
            httpMethod: .get,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - getUserById
    /// API call for UserHandler at: user/{userId}
    static func getUserById(userId: Int) -> ApodiniPublisher<User> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<User>(
            path: "user/\(userId)",
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
