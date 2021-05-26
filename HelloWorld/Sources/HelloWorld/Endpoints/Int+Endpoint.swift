//
//  Int+Endpoint.swift
//
//  Created by ApodiniMigrator on 26.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension Int {
    // MARK: - getRandomInt
    /// API call for Random at: rand
    static func getRandomInt(number: Int) -> ApodiniPublisher<Int> {
        var parameters = Parameters()
        parameters.set(number, forKey: "number")
        
        var headers = HTTPHeaders()
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Int>(
            path: "rand",
            httpMethod: .get,
            parameters: parameters,
            headers: headers,
            content: nil,
            authorization: nil,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
}
