//
//  Contact+Endpoint.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension Contact {
    // MARK: - createContact
    /// API call for CreateContact at: contacts
    public static func createContact(contact: Contact) -> ApodiniPublisher<Contact> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Contact>(
            path: "contacts",
            httpMethod: .post,
            parameters: [:],
            headers: headers,
            content: NetworkingService.encode(contact),
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - getContact
    /// API call for GetContact at: contacts/{contactId}
    public static func getContact(contactId: UUID) -> ApodiniPublisher<Contact> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Contact>(
            path: "contacts/\(contactId)",
            httpMethod: .get,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - getContacts
    /// API call for GetContacts at: contacts
    public static func getContacts() -> ApodiniPublisher<[Contact]> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<[Contact]>(
            path: "contacts",
            httpMethod: .get,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - updateContact
    /// API call for UpdateContact at: contacts/{contactId}
    public static func updateContact(contactId: UUID, mediator: ContactMediator) -> ApodiniPublisher<Contact> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Contact>(
            path: "contacts/\(contactId)",
            httpMethod: .put,
            parameters: [:],
            headers: headers,
            content: NetworkingService.encode(mediator),
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
}
