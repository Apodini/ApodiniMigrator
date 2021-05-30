//
//  Status+Endpoint.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension Status {
    // MARK: - deleteContact
    /// API call for DeleteContact at: contacts/{contactId}
    public static func deleteContact(contactId: UUID) -> ApodiniPublisher<Status> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Status>(
            path: "contacts/\(contactId)",
            httpMethod: .delete,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - deleteResidence
    /// API call for DeleteResidence at: residencies/{residenceId}
    public static func deleteResidence(residenceId: UUID) -> ApodiniPublisher<Status> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Status>(
            path: "residencies/\(residenceId)",
            httpMethod: .delete,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
}
