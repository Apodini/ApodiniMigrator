//
//  Created by ApodiniMigrator on 06.12.21
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

// MARK: - API
public enum API {}

// MARK: - Endpoints
public extension API {
    /// API call for Greeter at: 
    static func greeter_greetName(
        name: String,
        authorization: String? = nil,
        httpHeaders: HTTPHeaders = [:]
    ) -> ApodiniPublisher<Greeting> {
        Greeting.greeter_greetName(
            name: name,
            authorization: authorization,
            httpHeaders: httpHeaders
        )
    }
}
