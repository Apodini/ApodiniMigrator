//
//  Created by ApodiniMigrator on 06.12.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - Endpoints
public extension Greeting {
    /// API call for Greeter at: 
    static func greeter_greetName(
        name: String,
        authorization: String? = nil,
        httpHeaders: HTTPHeaders = [:]
    ) -> ApodiniPublisher<Greeting> {
        var parameters = Parameters()
        parameters.set(name, forKey: "name")
        
        var headers = httpHeaders
        headers.setContentType(to: "application/json")
        
        var errors: [ApodiniError] = []
        errors.addError(401, message: "Unauthorized")
        errors.addError(403, message: "Forbidden")
        errors.addError(404, message: "Not found")
        errors.addError(500, message: "Internal server error")
        
        let handler = Handler<Greeting>(
            path: "",
            httpMethod: .get,
            parameters: parameters,
            headers: headers,
            content: nil,
            authorization: authorization,
            errors: errors
        )
        
        return NetworkingService.trigger(handler)
    }
}
