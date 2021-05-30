//
//  Residence+Endpoint.swift
//
//  Created by ApodiniMigrator on 30.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension Residence {
    // MARK: - createResidence
    /// API call for CreateResidence at: residencies
    public static func createResidence(residence: Residence) -> ApodiniPublisher<Residence> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Residence>(
            path: "residencies",
            httpMethod: .post,
            parameters: [:],
            headers: headers,
            content: NetworkingService.encode(residence),
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - getResidenceWithId
    /// API call for GetResidence at: residencies/{residenceId}
    public static func getResidenceWithId(residenceId: UUID) -> ApodiniPublisher<Residence> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Residence>(
            path: "residencies/\(residenceId)",
            httpMethod: .get,
            parameters: [:],
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
    
    // MARK: - getResidencies
    /// API call for GetResidencies at: residencies
    public static func getResidencies() -> ApodiniPublisher<[Residence]> {
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<[Residence]>(
            path: "residencies",
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
