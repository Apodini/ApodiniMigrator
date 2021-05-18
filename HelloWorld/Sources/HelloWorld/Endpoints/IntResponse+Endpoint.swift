//
//  IntResponse+Endpoint
//
//  Created by ApodiniMigrator on 18.05.2021
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
extension IntResponse {
    /// API call for Random at: /v1/rand
    static func getRandomInt(number: Int) -> ApodiniPublisher<IntResponse> {
        var parameters: Parameters = [:]
        parameters.set(number, forKey: "number")
        
        var headers: HTTPHeaders = [:]
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<IntResponse>(
            path: "/v1/rand",
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
